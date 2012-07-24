//
//  WaterTempStationDB.h
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/29/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreData/CoreData.h>
#import "WaterTempStation.h"
#import "SandsParser.h"
#import "SandsDataStore.h"

@protocol WaterTempStationDBDelegate <NSObject>
-(void)databaseBuilt;
-(void)handleConnectionError;
@end

@interface WaterTempStationDB : NSObject<SandsParserDelegate, SandsDataStoreDelegate, WaterTempStationDelegate>{
    NSArray *fieldElements;
    int count;
}

@property (weak) id<WaterTempStationDBDelegate> delegate;
@property (strong, nonatomic) SandsParser *stationParser;
@property (strong, nonatomic) SandsDataStore *dataStore;
@property bool databaseBuilt;

-(id)initWithDelegate:(id<WaterTempStationDBDelegate>)del;
-(WaterTempStation *)closestStationTo:(CLPlacemark *)placemark;

@end
