//
//  SandsAppDelegate.h
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/9/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Beach.h"
#import "TidalStationDB.h"
#import "WaterTempStationDB.h"
#import "AdWhirlView.h"

@interface SandsAppDelegate : UIResponder <UIApplicationDelegate, BeachDelegate, TidalStationDBDelegate, WaterTempStationDBDelegate, AdWhirlDelegate>
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
@property bool hasAd;

@end
