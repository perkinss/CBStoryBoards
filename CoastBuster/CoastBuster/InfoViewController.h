//
//  InfoViewController.h
//  CoastBuster
//
//  Created by Susan Perkins on 2012-10-19.
//  Copyright (c) 2012 University of British Columbia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoViewController : UIViewController <UIWebViewDelegate> {
    
    UIWebView* webview;
    UIImageView* bannerView;
}

@end