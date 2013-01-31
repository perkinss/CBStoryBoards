//
//  BaseViewController.m
//  CoastBuster
//
//  Created by Susan Perkins on 2013-01-14.
//  Copyright (c) 2013 ONC. All rights reserved.
//

@class PhotoData;
@class PhotoSelectionViewController;
@class PhotoTableViewController;
@class PhotoDetailViewController;
@class InfoViewController;
@class SitesViewController;
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "constants.h"

@interface BaseViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, UIAlertViewDelegate> {
    PhotoData *photos;
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    BOOL findingLocation;
    NSTimer* findLocationTimer;
    UIAlertView* findingLocationView;
    
    PhotoTableViewController *photoTableViewController;
    PhotoDetailViewController *photoDetailViewController;
    InfoViewController *infoViewController;
    
    UILabel* userIDLabel;
    
    UIButton *photoButton;
    UIButton *tableButton;
    UIButton *infoButton;
    
    UIImageView *bgImageView;
    
}

@property (nonatomic, retain) PhotoData *photos;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *currentLocation;

@property (nonatomic, retain) PhotoTableViewController *photoTableViewController;
@property (nonatomic, retain) InfoViewController *infoViewController;
@property (nonatomic, retain) PhotoDetailViewController *photoDetailViewController;
@property (nonatomic, retain) SitesViewController *sitesViewController;


@property (nonatomic, retain) UILabel* userIDLabel;

@property (nonatomic) BOOL findingLocation;
@property (nonatomic, retain) NSTimer* findLocationTimer;
@property (nonatomic, retain) UIAlertView* findingLocationView;
@property (nonatomic, retain) UIImagePickerController *cameraController;

- (id)initWithPhotoData:(PhotoData*) photoData;

- (void) cameraButton;

//- (void) dataButton;
//- (void) infoButton;

@end

