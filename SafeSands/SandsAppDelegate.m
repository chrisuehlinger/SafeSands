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
@synthesize stateAbbrevs;

NSUserDefaults *defaults;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    stationDB = [[TidalStationDB alloc] initWithDelegate:self];
    tempStationDB = [[WaterTempStationDB alloc] initWithDelegate:self];
    [self setupStateAbbrevs];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    defaults = [NSUserDefaults standardUserDefaults];
    if(![defaults objectForKey:@"SafeSandsPro"]){
        [defaults setObject:@"NO" forKey:@"SafeSandsPro"];
        [defaults synchronize];
    }
    
    self.hasAd=NO;
    if ([[defaults objectForKey:@"SafeSandsPro"] isEqualToString:@"NO"]) {
        adView = [AdWhirlView requestAdWhirlViewWithDelegate:self];
        [adView setFrame:CGRectMake(0, window.rootViewController.view.bounds.size.height, window.rootViewController.view.bounds.size.width, 0)];
        [adView requestFreshAd];
    }
    
    
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

- (UIViewController *)currentDisplayingViewController
{
    UIViewController *currentVC = [(UINavigationController *)[window rootViewController] visibleViewController];
    
    if ([currentVC isKindOfClass:[SandsTabBarController class]]) {
        currentVC = [(SandsTabBarController *)currentVC selectedViewController];
    }
    
    //NSLog(@"The currently displayed vc is a: %@",[controllerToDisplayAd class]);
    
    return currentVC;
}

#pragma mark BeachDelegate methods

-(void)changeLoadingText:(NSString *)newText
{
    UIViewController *currentVC = [self currentDisplayingViewController];
    if([[[currentVC class] description] isEqualToString:@"LocationSelectorViewController"])
        [(LocationSelectorViewController *)currentVC changeLoadingTextTo:newText];
}

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

#pragma mark - AdWhirlView methods

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
    NSLog(@"Ad Received from: %@", [adView mostRecentNetworkName]);
    
    
    [[self currentDisplayingViewController] performSelector:@selector(adjustAdSize)];
}

#pragma mark - StoreKit Methods

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"Transaction success!");
    [self recordTransaction:transaction];
    [self provideContent:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"purchaseComplete"
                                                        object:nil];
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"Transaction restored!");
    [self recordTransaction: transaction];
    [self provideContent: transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"purchaseComplete"
                                                        object:nil];
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"Transaction failed: %@", transaction.error);
    if (transaction.error.code != SKErrorPaymentCancelled)
        [self handleError:kTransactionFailedError];
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"purchaseComplete"
                                                        object:nil];
}

- (void) recordTransaction:(SKPaymentTransaction *)transaction
{
    //verify the receipt
    //Nahhhhh, not worth it for this project.
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    NSLog(@"Restore Transaction failed: %@", error);
}

- (void) provideContent:(NSString *)productIdentifier
{
    [defaults setObject:@"YES"
                 forKey:@"SafeSandsPro"];
    [defaults setObject:[[NSMutableArray alloc] init]
                 forKey:@"Recent Locations"];
    [defaults synchronize];

    hasAd=NO;
    [adView ignoreNewAdRequests];
    adView=nil;
}

#pragma mark - Error Handling

-(void)handleError:(SandsError)error
{
    //NSLog(@"Error: %@", error);
    
    currentBeach.delegate = nil;
    currentBeach = nil;
    
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:@"Connection Error. Please ensure that you have an internet connection."
                                                        delegate:nil
                                               cancelButtonTitle:@"Dismiss"
                                               otherButtonTitles:nil];
    switch (error) {
        case kLocationManagerError:
            [errorAlert setMessage:@"Cannot find your location. Please ensure that you have a 3G/Wi-Fi connection and that location services are enabled."];
            break;
            
        case kLocationServiceAuthError:
            [errorAlert setMessage:@"Location services error. Please that location services are enabled."];
            break;
            
        case kGeocodeError:
            [errorAlert setMessage:@"Geocoder error. Please check your connection and try again."];
            break;
            
        case kWeatherError:
            [errorAlert setMessage:@"Error retrieving weather from Weather Underground. Check your connection or try again later."];
            break;
            
        case kWaterTempError:
            [errorAlert setMessage:@"Error retrieving water temperature. Please check your connection."];
            break;
            
        case kTideError:
            [errorAlert setMessage:@"Error retrieving tides. Please check your connection."];
            break;
            
        case kUVError:
            [errorAlert setMessage:@"Error retrieving UV Index. Please check your connection."];
            break;
            
        case kAlertsError:
            [errorAlert setMessage:@"Error retrieving local weather alerts. Please check your connection."];
            break;
            
        case kNonUSACountryError:
            [errorAlert setMessage:@"SafeSands can only report on conditions within the USA."];
            break;
            
        case kTransactionFailedError:
            [errorAlert setMessage:@"In-App Purchase failed. Please ensure that you have a 3G/Wi-Fi connection and try again later."];
            break;
            
        case kTidalDBError:
            [errorAlert setMessage:@"Error loading Tidal Station DB. Please ensure that you have a 3G/Wi-Fi connection and try again later."];
            break;
            
        case kWaterTempDBError:
            [errorAlert setMessage:@"Error loading Water Temp Station DB. Please ensure that you have a 3G/Wi-Fi connection and try again later."];
            break;
            
        default:
            break;
    }
    
    [errorAlert show];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Connection Error" 
                                                        object:nil];
    
}

#pragma mark - ugh CL...

-(void)setupStateAbbrevs
{
    stateAbbrevs = [[NSMutableDictionary alloc] init];
    [stateAbbrevs setValue:@"AL" forKey:@"Alabama"];
    [stateAbbrevs setValue:@"AK" forKey:@"Alaska"];
    [stateAbbrevs setValue:@"AZ" forKey:@"Arizona"];
    [stateAbbrevs setValue:@"AR" forKey:@"Arkansas"];
    [stateAbbrevs setValue:@"CA" forKey:@"California"];
    [stateAbbrevs setValue:@"CO" forKey:@"Colorado"];
    [stateAbbrevs setValue:@"CT" forKey:@"Connecticut"];
    [stateAbbrevs setValue:@"DE" forKey:@"Delaware"];
    [stateAbbrevs setValue:@"FL" forKey:@"Florida"];
    [stateAbbrevs setValue:@"GA" forKey:@"Georgia"];
    [stateAbbrevs setValue:@"HI" forKey:@"Hawaii"];
    [stateAbbrevs setValue:@"ID" forKey:@"Idaho"];
    [stateAbbrevs setValue:@"IL" forKey:@"Illinois"];
    [stateAbbrevs setValue:@"IN" forKey:@"Indiana"];
    [stateAbbrevs setValue:@"IA" forKey:@"Iowa"];
    [stateAbbrevs setValue:@"KS" forKey:@"Kansas"];
    [stateAbbrevs setValue:@"KY" forKey:@"Kentucky"];
    [stateAbbrevs setValue:@"LA" forKey:@"Louisiana"];
    [stateAbbrevs setValue:@"ME" forKey:@"Maine"];
    [stateAbbrevs setValue:@"MD" forKey:@"Maryland"];
    [stateAbbrevs setValue:@"MA" forKey:@"Massachusetts"];
    [stateAbbrevs setValue:@"MI" forKey:@"Michigan"];
    [stateAbbrevs setValue:@"MN" forKey:@"Minnesota"];
    [stateAbbrevs setValue:@"MS" forKey:@"Mississippi"];
    [stateAbbrevs setValue:@"MO" forKey:@"Missouri"];
    [stateAbbrevs setValue:@"MT" forKey:@"Montana"];
    [stateAbbrevs setValue:@"NE" forKey:@"Nebraska"];
    [stateAbbrevs setValue:@"NV" forKey:@"Nevada"];
    [stateAbbrevs setValue:@"NH" forKey:@"New Hampshire"];
    [stateAbbrevs setValue:@"NJ" forKey:@"New Jersey"];
    [stateAbbrevs setValue:@"NM" forKey:@"New Mexico"];
    [stateAbbrevs setValue:@"NY" forKey:@"New York"];
    [stateAbbrevs setValue:@"NC" forKey:@"North Carolina"];
    [stateAbbrevs setValue:@"ND" forKey:@"North Dakota"];
    [stateAbbrevs setValue:@"OH" forKey:@"Ohio"];
    [stateAbbrevs setValue:@"OK" forKey:@"Oklahoma"];
    [stateAbbrevs setValue:@"OR" forKey:@"Oregon"];
    [stateAbbrevs setValue:@"PA" forKey:@"Pennsylvania"];
    [stateAbbrevs setValue:@"RI" forKey:@"Rhode Island"];
    [stateAbbrevs setValue:@"SC" forKey:@"South Carolina"];
    [stateAbbrevs setValue:@"SD" forKey:@"South Dakota"];
    [stateAbbrevs setValue:@"TN" forKey:@"Tennessee"];
    [stateAbbrevs setValue:@"TX" forKey:@"Texas"];
    [stateAbbrevs setValue:@"UT" forKey:@"Utah"];
    [stateAbbrevs setValue:@"VT" forKey:@"Vermont"];
    [stateAbbrevs setValue:@"VA" forKey:@"Virginia"];
    [stateAbbrevs setValue:@"WA" forKey:@"Washington"];
    [stateAbbrevs setValue:@"WV" forKey:@"West Virginia"];
    [stateAbbrevs setValue:@"WI" forKey:@"Wisconsin"];
    [stateAbbrevs setValue:@"WY" forKey:@"Wyoming"];
    [stateAbbrevs setValue:@"AS" forKey:@"American Samoa"];
    [stateAbbrevs setValue:@"DC" forKey:@"District of Columbia"];
    [stateAbbrevs setValue:@"FM" forKey:@"Federated States of Micronesia"];
    [stateAbbrevs setValue:@"GU" forKey:@"Guam"];
    [stateAbbrevs setValue:@"MH" forKey:@"Marshall Islands"];
    [stateAbbrevs setValue:@"MP" forKey:@"Northern Mariana Islands"];
    [stateAbbrevs setValue:@"PW" forKey:@"Palau"];
    [stateAbbrevs setValue:@"PR" forKey:@"Puerto Rico"];
    [stateAbbrevs setValue:@"VI" forKey:@"Virgin Islands"];
    [stateAbbrevs setValue:@"AE" forKey:@"Armed Forces Africa"];
    [stateAbbrevs setValue:@"AA" forKey:@"Armed Forces Americas"];
    [stateAbbrevs setValue:@"AE" forKey:@"Armed Forces Canada"];
    [stateAbbrevs setValue:@"AE" forKey:@"Armed Forces Europe"];
    [stateAbbrevs setValue:@"AE" forKey:@"Armed Forces Middle East"];
    [stateAbbrevs setValue:@"AP" forKey:@"Armed Forces Pacific"];
}

@end
