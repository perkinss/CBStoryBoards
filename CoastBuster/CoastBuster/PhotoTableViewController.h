//
//  MasterViewController.h
//  CoastBuster
//
//  Created by Susan Perkins on 2013-01-09.
//  Copyright (c) 2013 ONC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoDetailViewController;

@interface PhotoTableViewController : UITableViewController

@property (strong, nonatomic) PhotoDetailViewController *detailViewController;

@end
