//
//  DisclaimerViewController.m
//  CoastBuster
//
//  Created by Jeff Proctor on 2012-10-16.
//  Copyright (c) 2012 University of British Columbia. All rights reserved.
//

#import "DisclaimerViewController.h"
#include "constants.h"
#include "PhotoData.h"




@implementation DisclaimerViewController


@synthesize nextView;



- (id)initWithNextView: (BaseViewController*) _nextView
{
    self = [super init];
    if (self) {
        [self.navigationItem setTitle:@"Terms of Use"];
        self.nextView = _nextView;
    }
    return self;
}

- (void) loadView {
    NSError *error = nil;
    NSString* fullPath = [[NSBundle mainBundle] pathForResource:DISCLAIMER_FILENAME ofType:@"html"];
    NSString* disclaimerText = [NSString stringWithContentsOfFile:fullPath encoding:NSASCIIStringEncoding error: &error];
    
    webview = [[UIWebView alloc] init];
    [webview loadHTMLString:disclaimerText baseURL:nil];
    webview.delegate = self;
    
    agreeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [agreeButton addTarget:self action:@selector(agreeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [agreeButton setTitle:@"Agree" forState:UIControlStateNormal];
    
    UIView* parentView = [[UIView alloc] init];
    [parentView addSubview:webview];
    [parentView addSubview:agreeButton];
    self.view = parentView;
}

- (void) layoutViewsInOrientation: (UIInterfaceOrientation) orientation {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    float screenWidth = screenRect.size.width;
    float screenHeight = screenRect.size.height;
    float navBarHeight = NAVBAR_HEIGHT_PORTRAIT;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        screenWidth = screenRect.size.height;
        screenHeight = screenRect.size.width;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
            navBarHeight = NAVBAR_HEIGHT_LANDSCAPE;
        }
    }
    
    int buttonWidth = 300;
    int buttonHeight = 50;
    int margin = 10;
    int buttonX = (screenWidth - buttonWidth)/2;
    NSInteger currentY = 0;
    
    int webviewHeight = screenHeight - buttonHeight - STATUS_BAR_HEIGHT - navBarHeight;
    webview.frame = CGRectMake(0, 0, screenWidth, webviewHeight);
    currentY += webviewHeight;
    
    agreeButton.frame = CGRectMake(buttonX, currentY, buttonWidth, buttonHeight);
    currentY += buttonHeight + margin;
}

- (void) viewWillAppear:(BOOL)animated  {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self layoutViewsInOrientation: self.interfaceOrientation];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:duration];
    [self layoutViewsInOrientation:toInterfaceOrientation];
    [UIView commitAnimations];
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

-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
}

- (void) agreeButtonPressed {
    self.nextView.photos.agreedToTerms = YES;
    [self.nextView.photos saveData];
    [self.navigationController pushViewController:nextView animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
