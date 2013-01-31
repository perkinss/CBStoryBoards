//
//  DetailViewController.h
//  CoastBuster
//
//  Created by Susan Perkins on 2013-01-09.
//  Copyright (c) 2013 ONC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
