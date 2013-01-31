//
//  PhotoData.m
//  BeachComber
//  Data structure for storing photos and their meta data
//  includes functionality for writing and reading photo metadata to disk
//
//  Created by Jeff Proctor on 12-07-20.\
//

#import "PhotoData.h"
#import <CoreGraphics/CoreGraphics.h>
#import <ImageIO/CGImageSource.h>
#import <imageIO/CGImageProperties.h>
#import <ImageIO/CGImageDestination.h>
#include <CFNetwork/CFNetwork.h>
#define photoPlist @"photo.plist"


@implementation PhotoData

@synthesize photos, userID, photoNumber, agreedToTerms;

@synthesize imageFTPStream, imageInputStream, dataFTPStream, dataInputStream, dataBufferOffset, dataBufferLimit, imageBufferOffset, imageBufferLimit, uploadNotifyTarget, uploadSet, uploadSetIndex;
@synthesize imageStreamOpenCompleted, dataStreamOpenCompleted, connectionTimer;

- (uint8_t *)imageBuffer
{
    return self->_image_buffer;
}

- (uint8_t *)dataBuffer
{
    return self->_data_buffer;
}

- (id)init {
    self = [super init];
    if (self) {
        
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *fileError = [[NSError alloc] init];
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *plistPath = [docDir stringByAppendingPathComponent:PLIST_FILENAME];
        
        if ([fileManager fileExistsAtPath:plistPath]) {
            
            NSDictionary *appData = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:plistPath]
                                                                              options:NSPropertyListMutableContainers
                                                                               format:NULL
                                                                                error:&fileError];
            self.photos = [appData objectForKey:PHOTO_KEY];
            self.photoNumber = [[appData objectForKey:PHOTO_NUM_KEY] intValue];
            self.userID = [appData objectForKey:USER_ID_KEY];
            self.agreedToTerms = [[appData objectForKey:TERMS_AGREED_KEY] boolValue];
            if([fileError localizedFailureReason] != nil) {
                NSString *err = [fileError localizedFailureReason];
                NSLog(@"Error: %@",err);
            }
        } else {
            self.photos = [[NSMutableArray alloc] init];
            self.photoNumber = 0;
            self.userID = @"";
            self.agreedToTerms = NO;
        }
    }
    return self;
}

- (NSDictionary*) photoAtIndex: (NSInteger) index {
    return [self.photos objectAtIndex: index];
}


- (BOOL) removePhotoAtIndex: (NSInteger) index {
    if (index >= [self.photos count] || index < 0) {
        return NO;
    }
    NSMutableDictionary *entry = [self.photos objectAtIndex: index];
    NSString *imageFile = [entry objectForKey:IMAGE_FILE_KEY];
    NSString *thumb = [entry objectForKey:THUMB_FILE_KEY];
    
    NSFileManager *fileMgr = [[NSFileManager alloc] init];
    NSError *error = nil;
    [fileMgr removeItemAtPath:imageFile error:&error];
    if (error != nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not delete image" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
    }
    [fileMgr removeItemAtPath:thumb error:&error];
    if (error != nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not delete thumb" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
    }
    
    [self.photos removeObjectAtIndex:index];
    NSLog(@"Photo removed at index %d", index);
    return YES;
}

- (BOOL) removePhoto: (NSDictionary*) entry {
    NSString* entryFile = [entry objectForKey:IMAGE_FILE_KEY];
    for (int i = [self.photos count] - 1; i >= 0; i--) {
        NSDictionary* cursor = [self.photos objectAtIndex:i];
        NSString* cursorFile = [cursor objectForKey:IMAGE_FILE_KEY];
        if ([cursorFile isEqualToString:entryFile]) {
            return [self removePhotoAtIndex:i];
        }
    }
    return NO;
}


- (BOOL) renamePhotoFilesForEntry: (NSDictionary*) entry {
    NSString* photoFilePath = [entry objectForKey:IMAGE_FILE_KEY];
    NSString* thumbFilePath = [entry objectForKey:THUMB_FILE_KEY];
    NSString* photoDir = [photoFilePath stringByDeletingLastPathComponent];
    assert([photoDir isEqualToString:[thumbFilePath stringByDeletingLastPathComponent]]);
    
    NSString* photoFile = [photoFilePath lastPathComponent];
    NSString* thumbFile = [thumbFilePath lastPathComponent];
    
    if ([photoFile hasPrefix:@"_"] && [thumbFile hasPrefix:@"_"]) {
        NSString* newPhotoFilePath = [photoDir stringByAppendingPathComponent:[self.userID stringByAppendingString:photoFile]];
        NSString* newThumbFilePath = [photoDir stringByAppendingPathComponent:[self.userID stringByAppendingString:thumbFile]];
        
        NSFileManager *fileMgr = [[NSFileManager alloc] init];
        NSError *error;
        if ([fileMgr moveItemAtPath:photoFilePath toPath:newPhotoFilePath error:&error] == YES) {
            [entry setValue:newPhotoFilePath forKey:IMAGE_FILE_KEY];
        } else {
            NSLog(@"Unable to move file: %@", [error localizedDescription]);
            return NO;
        }
        
        if ([fileMgr moveItemAtPath:thumbFilePath toPath:newThumbFilePath error:&error] == YES) {
            [entry setValue:newThumbFilePath forKey:THUMB_FILE_KEY];
        } else {
            NSLog(@"Unable to move file: %@", [error localizedDescription]);
            return NO;
        }
        
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL) movePhotoAtIndex:(NSInteger)fromIndex to:(NSInteger)toIndex {
    if (fromIndex >= [self.photos count] || fromIndex < 0 || toIndex >= [self.photos count] || toIndex < 0 || fromIndex == toIndex) {
        return NO;
    }
    NSMutableDictionary *entry = [self.photos objectAtIndex:fromIndex];
    [self.photos removeObjectAtIndex:fromIndex];
    [self.photos insertObject:entry atIndex:toIndex];
    
    return YES;
}

- (NSInteger) count {
    return [photos count];
}

- (NSMutableDictionary* ) addPhoto:(UIImage*) image withLocation:(CLLocation*)location metadata: (NSDictionary*) metadata{
    
    NSMutableDictionary *newPhoto = [[NSMutableDictionary alloc] init];
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    //fileName: docDir/deviceid_photoNumber.png or .thumb.png
    NSString *baseName = [self newFilename];
    NSString *thumbName = [baseName stringByAppendingPathExtension: @"thumb"];
    NSString *fullFilename = [[docDir stringByAppendingPathComponent:baseName] stringByAppendingPathExtension: @"jpg"];
    NSString *thumbFilename = [[docDir stringByAppendingPathComponent:thumbName] stringByAppendingPathExtension: @"jpg"];
	NSData *imageData = [NSData dataWithData:UIImageJPEGRepresentation(image, 0.5)];
    
    // INSERT metadata into EXIF
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
    
    NSMutableDictionary *metadataAsMutable = [metadata mutableCopy];
    NSMutableDictionary *EXIFDictionary = [[metadataAsMutable objectForKey:(NSString *)kCGImagePropertyExifDictionary]mutableCopy];
    NSMutableDictionary *GPSDictionary = [[metadataAsMutable objectForKey:(NSString *)kCGImagePropertyGPSDictionary]mutableCopy];
    if(!EXIFDictionary) {
        //if the image does not have an EXIF dictionary (not all images do), then create one for us to use
        EXIFDictionary = [NSMutableDictionary dictionary];
    }
    if(!GPSDictionary) {
        GPSDictionary = [NSMutableDictionary dictionary];
    }
    
    NSDate* currentTime = [NSDate date];
    NSDateFormatter *dateFormatExif = [[NSDateFormatter alloc] init];
    [dateFormatExif setDateFormat:TIME_FORMAT_EXIF];
    
    [dateFormatExif setTimeZone:[NSTimeZone timeZoneWithAbbreviation:TIME_ZONE_UTC]];
    NSString* utcTime = [dateFormatExif stringFromDate:currentTime];
    
    [dateFormatExif setTimeZone:[NSTimeZone localTimeZone]];
    NSString* localTime = [dateFormatExif stringFromDate:currentTime];
    
    // modify desired fields
    [GPSDictionary setValue:[NSNumber numberWithFloat:fabs(location.coordinate.latitude)] forKey:(NSString*)kCGImagePropertyGPSLatitude];
    [GPSDictionary setValue:((location.coordinate.latitude >= 0) ? @"N" : @"S") forKey:(NSString*)kCGImagePropertyGPSLatitudeRef];
    [GPSDictionary setValue:[NSNumber numberWithFloat:fabs(location.coordinate.longitude)] forKey:(NSString*)kCGImagePropertyGPSLongitude];
    [GPSDictionary setValue:((location.coordinate.longitude >= 0) ? @"E" : @"W") forKey:(NSString*)kCGImagePropertyGPSLongitudeRef];
    [GPSDictionary setValue:[NSNumber numberWithFloat:fabs(location.altitude)] forKey:(NSString*)kCGImagePropertyGPSAltitude];
    [GPSDictionary setValue:[NSNumber numberWithInt:((location.altitude >= 0) ? 0 : 1)] forKey:(NSString*)kCGImagePropertyGPSAltitudeRef];
    [GPSDictionary setValue:utcTime forKey:(NSString*)kCGImagePropertyGPSTimeStamp];
    
    [EXIFDictionary setValue:localTime forKey:(NSString*)kCGImagePropertyExifDateTimeOriginal];
    [EXIFDictionary setValue:localTime forKey:(NSString*)kCGImagePropertyExifDateTimeDigitized];
    [metadataAsMutable setObject:GPSDictionary forKey:(NSString *)kCGImagePropertyGPSDictionary];
    [metadataAsMutable setObject:EXIFDictionary forKey:(NSString *)kCGImagePropertyExifDictionary];
    [metadataAsMutable setObject:[NSNumber numberWithInt:1] forKey:(NSString*)kCGImagePropertyOrientation];
    CFStringRef UTI = CGImageSourceGetType(source); //this is the type of image (e.g., public.jpeg)
    
    //this will be the data CGImageDestinationRef will write into
    NSMutableData *data = [NSMutableData data];
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)data,UTI,1,NULL);
    
    if(!destination)
    {
        NSLog(@"***Could not create image destination ***");
        return nil;
    }
    
    //add the image contained in the image source to the destination, overidding the old metadata with our modified metadata
    CGImageDestinationAddImageFromSource(destination,source,0, (__bridge CFDictionaryRef) metadataAsMutable);
    if(!CGImageDestinationFinalize(destination))
    {
        NSLog(@"***Could not create data from image destination ***");
        return nil;
    }
    
    [data writeToFile:fullFilename atomically:YES];
    
    UIImage* thumb = [self makeThumb:image];
    NSData *thumbData = [NSData dataWithData:UIImageJPEGRepresentation(thumb, 0.5)];
    [thumbData writeToFile:thumbFilename atomically:YES];
    
    [newPhoto setObject: thumbFilename forKey:THUMB_FILE_KEY];
    [newPhoto setObject: fullFilename forKey:IMAGE_FILE_KEY];
    [newPhoto setObject: @"" forKey:COMMENT_KEY];
    [newPhoto setObject: @"" forKey:CATEGORY_KEY];
    [newPhoto setObject: @"" forKey:COMPOSITION_KEY];
    [newPhoto setObject: @"" forKey:WIDTH_KEY];
    [newPhoto setObject: @"" forKey:LENGTH_KEY];
    [newPhoto setObject: @"" forKey:FROM_JAPAN_KEY];
    [newPhoto setObject: @"" forKey:HAZARDOUS_KEY];
    [newPhoto setObject: @"" forKey:STATUS_KEY];
    [newPhoto setObject: @"" forKey:CREATURE_KEY];
    NSString *latitudeString = @"";
    NSString *longitudeString = @"";
    if (location != nil) {
        latitudeString = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
        longitudeString = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
    }
    NSDateFormatter *dateFormatNEPTUNE = [[NSDateFormatter alloc] init];
    [dateFormatNEPTUNE setDateFormat:TIME_FORMAT_NEPTUNE];
    [dateFormatNEPTUNE setTimeZone:[NSTimeZone timeZoneWithAbbreviation:TIME_ZONE_UTC]];
    
    NSString* dateString = [dateFormatNEPTUNE stringFromDate:currentTime];
    [newPhoto setObject:latitudeString forKey:LATITUDE_KEY];
    [newPhoto setObject:longitudeString forKey:LONGITUDE_KEY];
    [newPhoto setObject:dateString forKey:TIMESTAMP_KEY];
    
    [self.photos addObject:newPhoto];
    return newPhoto;
}

- (void) saveData {
    
    NSNumber *photonum = [NSNumber numberWithInteger:photoNumber];
    NSDictionary *appData = [NSDictionary dictionaryWithObjectsAndKeys:
                             self.photos, PHOTO_KEY,
                             photonum, PHOTO_NUM_KEY,
                             userID, USER_ID_KEY,
                             [NSNumber numberWithBool: self.agreedToTerms], TERMS_AGREED_KEY,
                             nil];
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [docDir stringByAppendingPathComponent: PLIST_FILENAME];
    [appData writeToFile:plistPath atomically:YES];
}

- (UIImage*) photoImageAtIndex: (NSInteger) index {
    NSMutableDictionary* entry = [self.photos objectAtIndex:index];
    NSString* fileName = [entry objectForKey:IMAGE_FILE_KEY];
    UIImage* image = [[UIImage alloc] initWithContentsOfFile:fileName];
    return image;
}

- (UIImage*) thumbImageAtIndex: (NSInteger) index {
    NSMutableDictionary* entry = [self.photos objectAtIndex:index];
    NSString* fileName = [entry objectForKey:THUMB_FILE_KEY];
    UIImage* thumb = [[UIImage alloc] initWithContentsOfFile:fileName];
    return thumb;
}


- (UIImage*) makeThumb: (UIImage *) fullImage {
    CGSize imageSize = [fullImage size];
    int shortestEdge = MIN(imageSize.width, imageSize.height);
    
    CGRect rect = CGRectMake((imageSize.width - shortestEdge)/2, (imageSize.height - shortestEdge)/2, shortestEdge, shortestEdge);
    CGImageRef imageRef = CGImageCreateWithImageInRect([fullImage CGImage], rect);
    UIImage *thumb = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    CGSize thumbsize = CGSizeMake(180, 180);
    UIGraphicsBeginImageContext(thumbsize);
    [thumb drawInRect:CGRectMake(0, 0, thumbsize.width, thumbsize.height)];
    UIImage *scaledThumb = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledThumb;
}

- (NSString *)newFilename {
    photoNumber++;
    NSString* nameString = [NSString stringWithFormat:@"%@_%04d", self.userID, photoNumber];
    return nameString;
}


#pragma mark - Uploading Functions
/* ********************** UPLOADING FUNCTIONS  **************************/
// TODO: run uploading in separate run loop

- (void) uploadPhotosInSet:(NSArray*) photoSet withObserver:(id)target{
    self.uploadNotifyTarget = target;
    self.uploadSet = photoSet;
    self.uploadSetIndex = 0;
    
    if ([self.userID isEqualToString:@""]) {
        NSLog(@"fetching User id");
        [self getCoastbusterUserID];
    }
    else {
        NSInteger index = [[self.uploadSet objectAtIndex:self.uploadSetIndex] intValue];
        [self _startSendAtIndex: index];
    }
}

- (void) getCoastbusterUserID {
    NSLog(@"User ID web service: %@",USER_ID_URL);
    NSURL *userIDURL = [NSURL URLWithString:USER_ID_URL];
    NSURLRequest* request = [NSURLRequest requestWithURL:userIDURL];
    
    [NSURLConnection    sendAsynchronousRequest:request
                                          queue:[NSOperationQueue mainQueue]
                              completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                  
                                  if (error == nil) {
                                      NSString *webserviceValue = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                                      NSLog(@"User ID web service value: %@",webserviceValue);
                                      NSString *trimmedValue = [webserviceValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                      self.userID = trimmedValue;
                                      
                                      for (int i = 0; i < [self.photos count]; i++) {
                                          NSDictionary* entry = [self.photos objectAtIndex:i];
                                          if (![self renamePhotoFilesForEntry:entry]) {
                                              NSLog(@"Photo file not renamed correctly for entry %d", i);
                                          }
                                      }
                                      
                                      NSInteger index = [[self.uploadSet objectAtIndex:self.uploadSetIndex] intValue];
                                      [self _startSendAtIndex: index];
                                  }
                                  else {
                                      [self endWithStatus:@"Could not retrieve User ID"];
                                  }
                              }];
}



- (NSString*) getDataFileStringForIndex:(NSInteger) index {
    NSArray *keys = [NSArray arrayWithObjects:CATEGORY_KEY, COMPOSITION_KEY, COMMENT_KEY, LATITUDE_KEY, LONGITUDE_KEY, TIMESTAMP_KEY, WIDTH_KEY, LENGTH_KEY, FROM_JAPAN_KEY, HAZARDOUS_KEY, STATUS_KEY, CREATURE_KEY, nil];
    NSString *output = @"";
    NSDictionary *entry = [self.photos objectAtIndex:index];
    for (int i = 0; i < [keys count]; i++) {
        NSString *key = [keys objectAtIndex:i];
        NSString *value = [entry objectForKey:key];
        value = [value stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        output = [output stringByAppendingFormat:@"%@=%@\n", key, value];
    }
    
    output = [output stringByAppendingFormat:@"coastbusterid=%@\n", self.userID];
    return output;
}


- (void)_startSendAtIndex:(NSInteger) index
{
    
    NSLog(@"start send photo at index %d", index);
    NSDictionary *photoEntry = [self.photos objectAtIndex:index];
    NSString* imageFilePath = [photoEntry objectForKey:IMAGE_FILE_KEY];
    NSString* imageFile = [imageFilePath lastPathComponent];
    
    BOOL                    success;
    NSURL *                 url;
    CFWriteStreamRef        ftpStream;
    
    assert(imageFilePath != nil);
    assert([[NSFileManager defaultManager] fileExistsAtPath:imageFilePath]);
    assert( [imageFilePath.pathExtension isEqual:@"jpg"]);
    
    assert(self.imageFTPStream == nil);      // don't tap send twice in a row!
    assert(self.imageInputStream == nil);         // ditto
    
    
    // open image input
    self.imageInputStream = [NSInputStream inputStreamWithFileAtPath:imageFilePath];
    assert(self.imageInputStream != nil);
    [self.imageInputStream open];
    
    // open data input
    NSString* dataString = [self getDataFileStringForIndex:index];
    NSData* data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    self.dataInputStream = [NSInputStream inputStreamWithData:data];
    assert(self.dataInputStream != nil);
    [self.dataInputStream open];
    
    // open image output
    url = [NSURL URLWithString: [NSString stringWithFormat:@"%@/%@", FTP_URL, imageFile]];
    ftpStream = CFWriteStreamCreateWithFTPURL(NULL, (__bridge CFURLRef) url);
    assert(ftpStream != NULL);
    
    self.imageFTPStream = (__bridge_transfer NSOutputStream *) ftpStream;
    success = [self.imageFTPStream setProperty:FTP_USERNAME forKey:(id)kCFStreamPropertyFTPUserName];
    assert(success);
    success = [self.imageFTPStream setProperty:FTP_PASSWORD forKey:(id)kCFStreamPropertyFTPPassword];
    assert(success);
    
    
    self.imageFTPStream.delegate = self;
    [self.imageFTPStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.imageFTPStream open];
    self.imageStreamOpenCompleted = NO;
    
    // open data output
    NSString *dataFileName = [[imageFile stringByDeletingPathExtension] stringByAppendingPathExtension:@"txt"];
    url = [NSURL URLWithString: [NSString stringWithFormat:@"%@/%@", FTP_URL, dataFileName]];
    ftpStream = CFWriteStreamCreateWithFTPURL(NULL, (__bridge CFURLRef) url);
    assert(ftpStream != NULL);
    
    self.dataFTPStream = (__bridge_transfer NSOutputStream *)ftpStream;
    success = [self.dataFTPStream setProperty:FTP_USERNAME forKey:(id)kCFStreamPropertyFTPUserName];
    assert(success);
    success = [self.dataFTPStream setProperty:FTP_PASSWORD forKey:(id)kCFStreamPropertyFTPPassword];
    assert(success);
    
    self.dataFTPStream.delegate = self;
    [self.dataFTPStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.dataFTPStream open];
    self.dataStreamOpenCompleted = NO;
    
    self.connectionTimer = [NSTimer scheduledTimerWithTimeInterval:FTP_TIMEOUT_SECONDS target:self selector:@selector(connectionTimeout:) userInfo:nil repeats:NO];
}



- (void) terminateStream: (NSStream*) stream {
    if (stream != nil) {
        if (stream == self.imageFTPStream || stream == self.dataFTPStream) {
            [stream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            stream.delegate = nil;
        }
        [stream close];
        
        if (stream == self.imageFTPStream) {
            self.imageFTPStream = nil;
        }
        else if (stream == self.dataFTPStream) {
            self.dataFTPStream = nil;
        }
        else if (stream == self.imageInputStream) {
            self.imageInputStream = nil;
        }
        else if (stream == self.dataInputStream) {
            self.dataInputStream = nil;
        }
    }
}



- (void)_stopStream:(NSStream*) stream status:(NSString *)statusString
{
    if (statusString == nil) { // stream ended without error
        if (stream == self.imageFTPStream) {
            [self terminateStream:self.imageFTPStream];
            [self terminateStream:self.imageInputStream];
        }
        else if (stream == self.dataFTPStream) {
            [self terminateStream:self.dataFTPStream];
            [self terminateStream:self.dataInputStream];
        }
        else {
            assert(NO);
        }
        
        // when both image and data have finished:
        if (self.imageFTPStream == nil && self.dataFTPStream == nil) {
            NSLog(@"Finished upload for index");
            [self.connectionTimer invalidate];
            self.connectionTimer = nil;
            self.uploadSetIndex++;
            if (self.uploadSetIndex < [self.uploadSet count]) {
                // start the next upload if there is another
                NSInteger index = [[self.uploadSet objectAtIndex:self.uploadSetIndex] intValue];
                [self _startSendAtIndex: index];
            }
            else {
                [self endWithStatus:statusString];
            }
        }
    }
    else {      // stream ended with error. terminate all streams
        [self.connectionTimer invalidate];
        self.connectionTimer = nil;
        [self terminateStream:self.imageFTPStream];
        [self terminateStream:self.imageInputStream];
        [self terminateStream:self.dataFTPStream];
        [self terminateStream:self.dataInputStream];
        [self endWithStatus:statusString];
    }
}


- (void) connectionTimeout: (NSTimer*) timer {
    NSLog(@"Connection timeout");
    if ((!self.dataStreamOpenCompleted) || (!self.dataStreamOpenCompleted)) {
        [self terminateStream:self.imageFTPStream];
        [self terminateStream:self.imageInputStream];
        [self terminateStream:self.dataFTPStream];
        [self terminateStream:self.dataInputStream];
        [self endWithStatus:@"Connection timeout"];
    }
}


- (void)endWithStatus: (NSString*) statusString {
    self.uploadSet = nil;
    self.uploadSetIndex = 0;
    
    SEL didStopSelector = @selector(_sendDidStopWithStatus:);
    if ([self.uploadNotifyTarget respondsToSelector:didStopSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.uploadNotifyTarget performSelector:didStopSelector withObject:statusString];
#pragma clang diagnostic pop
    }
    self.uploadNotifyTarget = nil;
}


- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
// An NSStream delegate callback that's called when events happen on our
// network stream.
{
    switch (eventCode) {
        case NSStreamEventOpenCompleted: {
            if (aStream == self.imageFTPStream) {
                imageStreamOpenCompleted = YES;
            }
            else if (aStream == self.dataFTPStream) {
                dataStreamOpenCompleted = YES;
            }
            else {
                assert(NO);
            }
        } break;
        case NSStreamEventHasBytesAvailable: {
            assert(NO);     // should never happen for the output stream
        } break;
        case NSStreamEventHasSpaceAvailable: {
            NSInputStream *inputStream;
            NSOutputStream *outputStream;
            size_t buffer_offset_tmp;
            size_t buffer_limit_tmp;
            uint8_t *buffer_ref;
            if (aStream == self.imageFTPStream) {
                inputStream = self.imageInputStream;
                outputStream = self.imageFTPStream;
                buffer_offset_tmp = self.imageBufferOffset;
                buffer_limit_tmp = self.imageBufferLimit;
                buffer_ref = self.imageBuffer;
            }
            else if (aStream == self.dataFTPStream) {
                inputStream = self.dataInputStream;
                outputStream = self.dataFTPStream;
                buffer_offset_tmp = self.dataBufferOffset;
                buffer_limit_tmp = self.dataBufferLimit;
                buffer_ref = self.dataBuffer;
            }
            else {
                assert(NO);
            }
            
            // If we don't have any data buffered, go read the next chunk of data.
            if (buffer_offset_tmp == buffer_limit_tmp) {
                NSInteger   bytesRead;
                
                bytesRead = [inputStream read:buffer_ref maxLength:kSendBufferSize];
                
                if (bytesRead == -1) {
                    [self _stopStream: aStream status:@"File read error"];
                } else if (bytesRead == 0) {
                    [self _stopStream: aStream status:nil];
                } else {
                    buffer_offset_tmp = 0;
                    buffer_limit_tmp  = bytesRead;
                }
            }
            
            // If we're not out of data completely, send the next chunk.
            if (buffer_offset_tmp != buffer_limit_tmp) {
                NSInteger   bytesWritten;
                bytesWritten = [outputStream write:&buffer_ref[buffer_offset_tmp] maxLength:buffer_limit_tmp - buffer_offset_tmp];
                assert(bytesWritten != 0);
                if (bytesWritten == -1) {
                    [self _stopStream: aStream status:@"Network write error"];
                } else {
                    buffer_offset_tmp += bytesWritten;
                }
            }
            
            if (aStream == self.imageFTPStream) {
                self.imageBufferOffset = buffer_offset_tmp;
                self.imageBufferLimit = buffer_limit_tmp;
            }
            else if (aStream == self.dataFTPStream) {
                self.dataBufferOffset = buffer_offset_tmp;
                self.dataBufferLimit = buffer_limit_tmp;
            }
        } break;
        case NSStreamEventErrorOccurred: {
            NSError* error = [aStream streamError];
            
            NSLog(@"%@ (Code = %d)", [error localizedDescription], [error code]);
            [self _stopStream: aStream status:@"Transfer error"];
        } break;
        case NSStreamEventEndEncountered: {
            // ignore
        } break;
        default: {
            assert(NO);
        } break;
    }
}


@end
