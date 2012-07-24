//
//  SandsAppDelegate.m
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/9/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import "SandsAppDelegate.h"
#import "SandsTabBarController.h"
#import "AlertViewController.h"
#import "TidalClockViewController.h"
#import "WeatherViewController.h"
#import "PlacemarkViewController.h"
#import "LocationSelectorViewController.h"


@implementation SandsAppDelegate

@synthesize window, navController;
@synthesize currentBeach;
@synthesize stationDB;
@synthesize tempStationDB;
@synthesize adView;
@synthesize hasAd;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.hasAd=NO;
    adView = [AdWhirlView requestAdWhirlViewWithDelegate:self];
    [adView setFrame:CGRectMake(0, window.rootViewController.view.bounds.size.height, window.rootViewController.view.bounds.size.width, 0)];
    [adView requestFreshAd];
    
    stationDB = [[TidalStationDB alloc] initWithDelegate:self];
    tempStationDB = [[WaterTempStationDB alloc] initWithDelegate:self];
    
    [window addSubview:[navController view]];
    [window makeKeyAndVisible];
    
    //[NSThread sleepForTimeInterval:10.0];
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
    NSLog(@"Posting Notification: aboutToEnterBackground.");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"aboutToEnterBackground" object:nil];
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
    NSLog(@"Posting Notification: aboutToTerminate.");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"aboutToTerminate" object:nil];
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

#pragma mark BeachDelegate methods

-(void)foundData
{
    NSLog(@"Posting Notification: foundData.");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"foundData" object:nil];
}

-(void)foundTides
{
    NSLog(@"Posting Notification: foundTides.");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"foundTides" object:nil];
}

-(void)foundAlerts
{
    NSLog(@"Posting Notification: foundAlerts.");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"foundAlerts" object:nil];
}

#pragma mark TidalStationDBDelegate methods

-(void)databaseBuilt
{
    
}

- (NSString *)adWhirlApplicationKey {
    NSLog(@"AdWhirl Key Retrieved");
    return @"1a4fbc00cb164b2286f526bb5da3b9e9";
}

/*
-(BOOL)adWhirlTestMode
{
#ifndef NDEBUG
    return YES;
#else
    return NO;
#endif
}
 */

- (UIViewController *)viewControllerForPresentingModalView {
    NSLog(@"Presenting Ad in Modal View");
    UIViewController *vc = window.rootViewController;
    return vc;
    //return [[[[UIApplication sharedApplication] windows] lastObject] rootViewController];
}

- (void)adWhirlDidReceiveAd:(AdWhirlView *)adWhirlView {
    [adWhirlView rotateToOrientation:UIInterfaceOrientationPortrait];
    self.hasAd=YES;
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"receivedAd" object:nil];
    NSLog(@"Ad Received from: %@", [adView mostRecentNetworkName]);
    
    UIViewController *controllerToDisplayAd = [(UINavigationController *)[window rootViewController] visibleViewController];
    
    if ([controllerToDisplayAd isKindOfClass:[SandsTabBarController class]]) {
        controllerToDisplayAd = [(SandsTabBarController *)controllerToDisplayAd selectedViewController];
    }
    
    //NSLog(@"The currently displayed vc is a: %@",[controllerToDisplayAd class]);
    [controllerToDisplayAd performSelector:@selector(adjustAdSize)];
}

#pragma mark - Error Handling

-(void)handleConnectionError
{
    NSLog(@"Connection Error");
        
    currentBeach.delegate = nil;
    currentBeach = nil;
        
    UIAlertView *noConnectionAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"Connection Error. Please ensure that you have an internet connection."
                                                                delegate:nil
                                                        cancelButtonTitle:@"Dismiss"
                                                        otherButtonTitles:nil];
    [noConnectionAlert show];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Connection Error"
                                                        object:nil];
}

-(void)handleNonUSACountryError
{
    NSLog(@"Non-USA Country Error");
    currentBeach.delegate = nil;
    currentBeach = nil;
    UIAlertView *nonUSAAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                          message:@"SafeSands can only report on conditions within the USA."
                                                         delegate:nil
                                                cancelButtonTitle:@"Dismiss"
                                                otherButtonTitles:nil];
    [nonUSAAlert show];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Non-USA Country"
                                                        object:nil];
}


@end
