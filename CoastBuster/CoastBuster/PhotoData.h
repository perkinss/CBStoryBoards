//
//  PhotoData.h
//  BeachComber
//
//  Created by Jeff Proctor on 12-07-20.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "constants.h"


enum {
    kSendBufferSize = 32768
};

@interface PhotoData : NSObject <NSStreamDelegate> {
    NSMutableArray *photos;
    NSInteger photoNumber;
    NSString* userID;
    BOOL agreedToTerms;
    
    NSOutputStream*     imageFTPStream;
    NSInputStream *     imageInputStream;
    uint8_t             _image_buffer[kSendBufferSize];
    size_t              imageBufferOffset;
    size_t              imageBufferLimit;
    BOOL                imageStreamOpenCompleted;
    
    NSOutputStream*     dataFTPStream;
    NSInputStream *     dataInputStream;
    uint8_t             _data_buffer[kSendBufferSize];
    size_t              dataBufferOffset;
    size_t              dataBufferLimit;
    BOOL                dataStreamOpenCompleted;
    
    NSTimer* connectionTimer;
    
    id uploadNotifyTarget;
    NSArray *uploadSet;
    NSInteger uploadSetIndex;
}

@property (nonatomic, retain) NSMutableArray *photos;
@property (nonatomic) NSInteger photoNumber;
@property (nonatomic, retain) NSString* userID;
@property (nonatomic) BOOL agreedToTerms;

@property (nonatomic, retain)   NSOutputStream *  imageFTPStream;
@property (nonatomic, retain)   NSInputStream *   imageInputStream;
@property (nonatomic, readonly) uint8_t *         imageBuffer;
@property (nonatomic, assign)   size_t            imageBufferOffset;
@property (nonatomic, assign)   size_t            imageBufferLimit;
@property (nonatomic) BOOL imageStreamOpenCompleted;

@property (nonatomic, retain)   NSOutputStream *  dataFTPStream;
@property (nonatomic, retain)   NSInputStream *   dataInputStream;
@property (nonatomic, readonly) uint8_t *         dataBuffer;
@property (nonatomic, assign)   size_t            dataBufferOffset;
@property (nonatomic, assign)   size_t            dataBufferLimit;
@property (nonatomic) BOOL dataStreamOpenCompleted;

@property (nonatomic, retain) NSTimer* connectionTimer;

@property (nonatomic, retain)   id                uploadNotifyTarget;
@property (nonatomic, retain)   NSArray *         uploadSet;
@property (nonatomic, assign)   NSInteger         uploadSetIndex;

- (void) saveData;
- (NSInteger) count;
- (NSString *) newFilename;
- (NSMutableDictionary* ) addPhoto:(UIImage*) image withLocation:(CLLocation*)location metadata: (NSDictionary*) metadata;
- (BOOL) renamePhotoFilesForEntry: (NSDictionary*) entry;

- (NSDictionary*) photoAtIndex: (NSInteger) index;
- (UIImage*) photoImageAtIndex: (NSInteger) index;
- (UIImage*) thumbImageAtIndex: (NSInteger) index;
- (BOOL) removePhotoAtIndex: (NSInteger) index;
- (BOOL) removePhoto: (NSDictionary*) entry;
- (BOOL) movePhotoAtIndex:(NSInteger)fromIndex to:(NSInteger)toIndex;
- (void) uploadPhotosInSet:(NSArray*) photoSet withObserver:(id)target;
- (UIImage*) makeThumb: (UIImage *) fullImage;

- (void)_startSendAtIndex:(NSInteger) index;
- (NSString*) getDataFileStringForIndex:(NSInteger) index;

@end
