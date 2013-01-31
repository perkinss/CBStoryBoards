////
////  InfoViewController.m
////  CoastBuster
////
////  Created by Susan Perkins on 2013-01-15.
////  Copyright (c) 2013 ONC. All rights reserved.
////
//
//#import "InfoViewController.h"
//
//@interface InfoViewController ()
//
//@end
//
//@implementation InfoViewController
//
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}
//
//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//	// Do any additional setup after loading the view.
//}
//
//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
//
//@end
//
//  InfoViewController.m
//  CoastBuster
//
//  Created by Susan Perkins on 2012-10-19.
//  Copyright (c) 2012 University of British Columbia. All rights reserved.
//

#import "InfoViewController.h"
#include "constants.h"

@interface InfoViewController ()

@end

@implementation InfoViewController

- (id)init {
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
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

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self layoutViewsForOrientation:toInterfaceOrientation];
}

- (void) layoutViewsForOrientation: (UIInterfaceOrientation) orientation {
    UIScreen *mainScreen = [UIScreen mainScreen];
    CGFloat scale = ([mainScreen respondsToSelector:@selector(scale)] ? mainScreen.scale : 1.0f);
    int screenWidth;
    int screenHeight;
    int navBarHeight;
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        screenWidth = [mainScreen bounds].size.width;
        screenHeight = [mainScreen bounds].size.height;
        navBarHeight = NAVBAR_HEIGHT_PORTRAIT;
    }
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        screenWidth = [mainScreen bounds].size.height;
        screenHeight = [mainScreen bounds].size.width;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
            navBarHeight = NAVBAR_HEIGHT_LANDSCAPE;
        }
        else {
            navBarHeight = NAVBAR_HEIGHT_PORTRAIT;
        }
    }
    
    int scaledWidth = scale * screenWidth;
    
    UIImage *bannerImage;
    if (scaledWidth == 320) {
        bannerImage = [UIImage imageNamed:@"320w_logo_banner.png"];
    }
    else if (scaledWidth == 480) {
        bannerImage = [UIImage imageNamed:@"480w_logo_banner.jpg"];
    }
    else if (scaledWidth == 640) {
        bannerImage = [UIImage imageNamed:@"640w_logo_banner.png"];
    }
    else if (scaledWidth == 960) {
        bannerImage = [UIImage imageNamed:@"960w_logo_banner.png"];
    }
    else if (scaledWidth == 1136) {
        bannerImage = [UIImage imageNamed:@"1136w_logo_banner.png"];
    }
    else {
        bannerImage = [UIImage imageNamed:@"1136w_logo_banner.png"];
    }
    
    bannerView.image = bannerImage;
    bannerView.frame = CGRectMake(0, 0, bannerImage.size.width, bannerImage.size.height);
    int bannerWidth = bannerImage.size.width;
    if (bannerWidth != screenWidth) {
        float ratio = ((float)screenWidth) / bannerView.frame.size.width;
        CGRect newframe = bannerView.frame;
        newframe.size.width = screenWidth;
        newframe.size.height *= ratio;
        bannerView.frame = newframe;
    }
    
    webview.frame = CGRectMake(0, bannerView.frame.size.height, screenWidth, screenHeight - STATUS_BAR_HEIGHT - bannerView.frame.size.height - navBarHeight);
    
}

- (void)loadView {
    UIView *parent = [[UIView alloc] init];
    
    webview = [[UIWebView alloc] init];
    webview.delegate = self;
    NSError *error = nil;
    NSString* fullPath = [[NSBundle mainBundle] pathForResource:INFO_FILENAME ofType:@"html"];
    NSString* infoText = [NSString stringWithContentsOfFile:fullPath encoding:NSASCIIStringEncoding error: &error];
    [webview loadHTMLString:infoText baseURL:nil];
    
    
    bannerView = [[UIImageView alloc] init];
    
    [parent addSubview:webview];
    [parent addSubview:bannerView];
    
    self.view = parent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Help";
    
	// Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self layoutViewsForOrientation:self.interfaceOrientation];
}

-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

