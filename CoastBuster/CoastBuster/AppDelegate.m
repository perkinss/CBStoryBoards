//
//  AppDelegate.m
//  BeachComber
//
//  Created by Jeff Proctor on 12-07-18.
//

#import "AppDelegate.h"
#import "BaseViewController.h"
#import "DisclaimerViewController.h"
#import "PhotoData.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize baseController;
@synthesize photoData;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
 //   self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
  //  self.window.backgroundColor = [UIColor whiteColor];
    
    self.photoData = [[PhotoData alloc] init];
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
//        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
//        splitViewController.delegate = (id)navigationController.topViewController;
//    }
////    // iPad customization:
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//        UISplitViewController *firstView;
//        self.baseController = [[BaseViewController alloc] initWithPhotoData:photoData];
//        if (self.photoData.agreedToTerms) {
//            firstView = self.baseController;
//        } else {
//            firstView = [[DisclaimerViewController alloc] initWithNextView:self.baseController];
//        }
//        firstView = (UISplitViewController *)self.window.rootViewController;
//        UINavigationController *navigationController = [firstView.viewControllers lastObject];
//        firstView.delegate = (id)navigationController.topViewController;
//    } else {
 
//        UIViewController* firstView;
        
//        self.baseController = [[BaseViewController alloc] initWithPhotoData:photoData];
//        if (self.photoData.agreedToTerms) {
  //          firstView = self.baseController;
//        } else {
//            firstView = [[DisclaimerViewController alloc] initWithNextView:self.baseController];
 //       }
        
  //      UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController: firstView];
//        self.window.rootViewController = navController;
 //       [self.window makeKeyAndVisible];
  //  }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self.photoData saveData];
    
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    //this doesn't usually get called :(
    [self.photoData saveData];
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end


