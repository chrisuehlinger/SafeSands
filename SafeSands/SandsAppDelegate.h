//
//  SandsAppDelegate.h
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/9/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "Beach.h"
#import "TidalStationDB.h"
#import "WaterTempStationDB.h"
#import "AdWhirlView.h"

/*typedef enum SandsError {
    kLocationManagerError,
    kGeocodeError,
    kNonUSACountryError,
    kWeatherError,
    kTideError,
    kUVError,
    kWaterTempError,
    kAlertsError,
    kConnectionError,
    kOtherError
} SandsError;*/

@interface SandsAppDelegate : UIResponder <UIApplicationDelegate, BeachDelegate, TidalStationDBDelegate, WaterTempStationDBDelegate, AdWhirlDelegate, SKPaymentTransactionObserver>
{
    UIWindow *window;
    UINavigationController *navController;
    bool hasAd;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) IBOutlet UINavigationController *navController;
@property (strong, nonatomic) Beach *currentBeach;
@property (strong, nonatomic) TidalStationDB *stationDB;
@property (strong, nonatomic) WaterTempStationDB *tempStationDB;
@property (strong, nonatomic) AdWhirlView *adView;
@property (strong, nonatomic) NSMutableDictionary *stateAbbrevs;
@property bool hasAd;

-(void)handleError:(SandsError)error;

@end
