//
//  BaseViewController.m
//  BeachComber
//  Root view controller that prompts user to select between taking a photo or viewing photos table
//
//  Created by Jeff Proctor on 12-07-22.
//

#import "BaseViewController.h"
#import "PhotoTableViewController.h"
#import "PhotoDetailViewController.h"
//#import "InfoViewController.h"
#import "PhotoData.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>

@implementation BaseViewController
@synthesize photos, locationManager, currentLocation;

@synthesize photoTableViewController, photoDetailViewController, infoViewController, userIDLabel, cameraController, sitesViewController;
@synthesize findingLocation, findLocationTimer, findingLocationView;
//need to take out the hard coded view here:
- (id)initWithPhotoData:(PhotoData*) photoData
{
    self = [super init];
    if (self) {
        self.photos = photoData;
        
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        
        self.photoTableViewController = nil;
        self.photoDetailViewController = nil;
        self.infoViewController = nil;
        self.sitesViewController = nil;
        
        self.findingLocation = NO;
        self.findLocationTimer = nil;
        self.findingLocationView = nil;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
- (IBAction) openCamera:(id)sender {
    
    [self presentViewController:cameraController animated:YES completion:nil];
    
}
#pragma mark - View lifecycle

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */
- (void)awakeFromNib
{
    
    [super awakeFromNib];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.cameraController = [[UIImagePickerController alloc] init] ;
    self.cameraController.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.cameraController.delegate = self;
    self.navigationController.navigationBarHidden = YES;
    [[self navigationItem] setTitle:APP_TITLE];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Back"
                                   style: UIBarButtonItemStyleBordered
                                   target: nil action: nil];
//
//    [self.navigationItem setBackBarButtonItem: backButton];
//    self.navigationItem.hidesBackButton = YES;
//    
//    photoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [photoButton setAlpha:0.8f];
//    [photoButton addTarget:self action:@selector(cameraButton) forControlEvents:UIControlEventTouchDown];
//    [photoButton setTitle:BUTTON_TEXT_CAMERA forState:UIControlStateNormal];
//    
//    tableButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [tableButton setAlpha:0.8f];
//    [tableButton addTarget:self action:@selector(dataButton) forControlEvents:UIControlEventTouchDown];
//    [tableButton setTitle:BUTTON_TEXT_GALLERY forState:UIControlStateNormal];
//    
//    infoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [infoButton setAlpha:0.8f];
//    [infoButton addTarget:self action:@selector(infoButton) forControlEvents:UIControlEventTouchDown];
//    [infoButton setTitle:BUTTON_TEXT_ABOUT forState:UIControlStateNormal];
//    
//    self.userIDLabel = [[UILabel alloc] init];
//    self.userIDLabel.textAlignment = UITextAlignmentCenter;
//    self.userIDLabel.text = @"";
//    [userIDLabel setBackgroundColor:[UIColor clearColor]];
//    userIDLabel.font = [UIFont boldSystemFontOfSize: 18.0f];
//    userIDLabel.textColor = USER_ID_LABEL_COLOR;
//    
//    bgImageView = [[UIImageView alloc] init];
//    
//    [self.view addSubview:bgImageView];
//    [self.view addSubview:photoButton];
//    [self.view addSubview:tableButton];
//    [self.view addSubview:infoButton];
//    [self.view addSubview:self.userIDLabel];
}

- (void) layoutViewsInOrientation:(UIInterfaceOrientation) orientation {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    int buttonWidth = 220;
    int buttonHeight = 45;
    float margin = 12.0f;
    float screenWidth = (UIInterfaceOrientationIsPortrait(orientation) ? screenRect.size.width : screenRect.size.height);
    float screenHeight = (UIInterfaceOrientationIsPortrait(orientation) ? screenRect.size.height : screenRect.size.width);
    
    if (UIInterfaceOrientationIsLandscape(orientation) && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        int buttonX = (screenWidth - buttonWidth)/2;
        float midwidth = screenWidth / 2;
        int currentY = 145;
        photoButton.frame = CGRectMake(midwidth - buttonWidth - margin/2, currentY, buttonWidth, buttonHeight);
        tableButton.frame = CGRectMake(midwidth + margin, currentY, buttonWidth, buttonHeight);
        currentY += buttonHeight + margin;
        infoButton.frame = CGRectMake(buttonX, currentY, buttonWidth, buttonHeight);
        
    }
    else {
        int currentY = screenHeight / 2; // initial value of this indicates top margin
        int buttonX = (screenWidth - buttonWidth)/2;
        
        photoButton.frame = CGRectMake(buttonX, currentY, buttonWidth, buttonHeight);
        currentY += buttonHeight + margin;
        
        tableButton.frame = CGRectMake(buttonX, currentY, buttonWidth, buttonHeight);
        currentY += buttonHeight + margin;
        
        infoButton.frame = CGRectMake(buttonX, currentY, buttonWidth, buttonHeight);
        currentY += buttonHeight + margin;
    }
    
    
    int labelY = screenHeight - buttonHeight - STATUS_BAR_HEIGHT;
    userIDLabel.frame = CGRectMake(0, labelY, screenWidth, buttonHeight);
    
    bgImageView.image = [self backgroundImageForOrientation:orientation];
    bgImageView.frame = CGRectMake(0,0, screenWidth, screenHeight - STATUS_BAR_HEIGHT);
}

- (UIImage*) backgroundImageForOrientation: (UIInterfaceOrientation) orientation {
    UIScreen *mainScreen = [UIScreen mainScreen];
    
    int effectiveHeight = [mainScreen bounds].size.height;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        if (effectiveHeight == 480) {
            return UIInterfaceOrientationIsPortrait(orientation) ? [UIImage imageNamed:@"main_3_5inch_portrait.jpg"] : [UIImage imageNamed:@"main_3_5inch_landscape.jpg"];
        }
        if (effectiveHeight == 568) {
            return UIInterfaceOrientationIsPortrait(orientation) ? [UIImage imageNamed:@"main_4inch_portrait.jpg"] : [UIImage imageNamed:@"main_4inch_landscape.jpg"];
        }
    }
    
    return UIInterfaceOrientationIsPortrait(orientation) ? [UIImage imageNamed:@"main_3_5inch_portrait@2x.jpg"] : [UIImage imageNamed:@"main_3_5inch_landscape@2x.jpg"];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self layoutViewsInOrientation:self.interfaceOrientation];
    [self.locationManager startUpdatingLocation];
//    
//    NSString* displayUserID = @"";
//    if ([self.photos.userID isEqualToString:@""]) {
//        displayUserID = PENDING_ID_STRING;
//    }
//    else {
//        displayUserID = self.photos.userID;
//    }
//    self.userIDLabel.text = [NSString stringWithFormat:@"Coastbuster ID: %@", displayUserID];
//    
}

- (void) viewWillDisappear:(BOOL)animated {
    [self.locationManager stopUpdatingLocation];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL) shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return SUPPORTED_ORIENTATION;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:duration];
    [self layoutViewsInOrientation:toInterfaceOrientation];
    [UIView commitAnimations];
}


# pragma mark - location and buttons
//  called when new location data is received
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    if ([self locationMeetsRequirements:newLocation]) {
        self.currentLocation = newLocation;
        if (self.findingLocation) {
            self.findingLocation = NO;
            [self.findLocationTimer invalidate];
            self.findLocationTimer = nil;
            
            [self.findingLocationView dismissWithClickedButtonIndex:0 animated:YES];
            
            [self showCamera];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Location manager failed with error: %@", error.description);
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation* location = [locations lastObject];
    
    if ([self locationMeetsRequirements:location]) {
        self.currentLocation = location;
        if (self.findingLocation) {
            self.findingLocation = NO;
            [self.findLocationTimer invalidate];
            self.findLocationTimer = nil;
            
            [self.findingLocationView dismissWithClickedButtonIndex:0 animated:YES];
            
            [self showCamera];
        }
    }
}

- (BOOL) locationMeetsRequirements: (CLLocation*) location {
    if (location == nil) {
        return NO;
    }
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    return (howRecent < MAX_SECONDS_ELAPSED_FOR_LOCATION && location.horizontalAccuracy >= 0 && location.horizontalAccuracy <= MAX_GPS_UNCERTAINTY);
}

- (void) findLocationTimeout: (NSTimer*) timer {
    self.findingLocation = NO;
    [self.findLocationTimer invalidate];
    self.findLocationTimer = nil;
    
    [self.findingLocationView dismissWithClickedButtonIndex:0 animated:YES];
    
    UIAlertView* failureAlert = [[UIAlertView alloc] initWithTitle:@"" message:CANNOT_FIND_LOCATION_MESSAGE delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
    [failureAlert show];
}

- (void) showCamera {
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    cameraUI.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    
    cameraUI.delegate = self;
    
    [self presentViewController: cameraUI animated: YES completion:nil];
}

- (void) cameraButton {
    
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:LOCATION_SERVICES_UNAVAILABLE_MESSAGE delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
    } else if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:CAMERA_UNAVAILABLE_MESSAGE delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
    } else if ([self locationMeetsRequirements:self.currentLocation]) {
        NSLog(@"Location accepted. Show camera. lat: %f long: %f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);
        [self showCamera];
    }
    else {
        self.findingLocation = YES;
        self.findLocationTimer = [NSTimer scheduledTimerWithTimeInterval:FIND_LOCATION_TIMEOUT target:self selector:@selector(findLocationTimeout:) userInfo:nil repeats:NO];
        findingLocationView = [[UIAlertView alloc] initWithTitle:FIND_LOCATION_TITLE message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        [findingLocationView show];
        
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        
        indicator.center = CGPointMake(32, 28);
        [indicator startAnimating];
        [findingLocationView addSubview:indicator];
    }
}


// Called when 'finding location...' popup is canceled
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == self.findingLocationView) {
        self.findingLocation = NO;
        [self.findLocationTimer invalidate];
        self.findLocationTimer = nil;
    }
}

//- (void) dataButton {
//    if (photoTableViewController == nil) {
//        photoTableViewController = [[PhotoTableViewController alloc] initWithPhotoData:self.photos];
//    }
//    [self.navigationController pushViewController:photoTableViewController animated:YES];
//}

//- (void) infoButton {
//    if (infoViewController == nil) {
//        infoViewController = [[InfoViewController alloc] init];
//        infoViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
//    }
//    [self.navigationController pushViewController:infoViewController animated:YES];
//}

- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    
    [self dismissViewControllerAnimated: YES completion:nil];
}

- (void) imagePickerController: (UIImagePickerController *) picker didFinishPickingMediaWithInfo: (NSDictionary *) info {
    [self dismissViewControllerAnimated: YES completion:nil];
    
    UIImage* editedImage = (UIImage *) [info objectForKey: UIImagePickerControllerEditedImage];
    UIImage* originalImage = (UIImage *) [info objectForKey: UIImagePickerControllerOriginalImage];
    NSDictionary* metadata = (NSDictionary *) [info objectForKey:UIImagePickerControllerMediaMetadata];
    
    UIImage* imageToSave;
    if (editedImage) {
        imageToSave = editedImage;
    } else {
        imageToSave = originalImage;
    }
    
    UIImage* fixedImage = [self normalizedImage:imageToSave];
//    NSMutableDictionary *newEntry = [self.photos addPhoto:fixedImage withLocation: self.currentLocation metadata:metadata];
//    NSString* thumbName = [newEntry objectForKey:THUMB_FILE_KEY];
//    UIImage* thumb = [[UIImage alloc] initWithContentsOfFile:thumbName];
//    if (self.photoDetailViewController == nil) {
//        self.photoDetailViewController = [[PhotoDetailViewController alloc] initWithImage:thumb entry:newEntry];
//        self.photoDetailViewController.photos = self.photos;
//        [self.photoDetailViewController setBackAsCancel];
//        self.photoDetailViewController.mandatoryFields = YES;
//    }
//    else {
//        [self.photoDetailViewController changePhotoWithImage:thumb entry:newEntry];
//    }
    [self.navigationController pushViewController:self.photoDetailViewController animated:YES];
}


// Image orientation fix
- (UIImage *)normalizedImage: (UIImage*) image {
    if (image.imageOrientation == UIImageOrientationUp) return image;
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    [image drawInRect:(CGRect){0, 0, image.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}


@end
