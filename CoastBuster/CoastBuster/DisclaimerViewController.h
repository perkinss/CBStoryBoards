//
//  DisclaimerViewController.h
//  CoastBuster
//
//  Created by Jeff Proctor on 2012-10-16.
//  Copyright (c) 2012 University of British Columbia. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "BaseViewController.h"

@interface DisclaimerViewController : UIViewController <UIWebViewDelegate> {
    BaseViewController* nextView;
    
    UIWebView* webview;
    UIButton* agreeButton;
}

@property (nonatomic, retain) BaseViewController* nextView;


- (id)initWithNextView: (UIViewController*) _nextView;

@end
