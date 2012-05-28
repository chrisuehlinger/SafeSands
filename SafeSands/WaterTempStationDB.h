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

@end

@interface WaterTempStationDB : NSObject<SandsParserDelegate, SandsDataStoreDelegate, WaterTempStationDelegate>{
    id<WaterTempStationDBDelegate> delegate;
    SandsParser *stationParser;
    NSArray *fieldElements;
    bool databaseBuilt;
    
    int count;
    SandsDataStore *dataStore;
}

@property (strong, nonatomic) id<WaterTempStationDBDelegate> delegate;
@property bool databaseBuilt;

-(id)initWithDelegate:(id<WaterTempStationDBDelegate>)del;
-(WaterTempStation *)closestStationTo:(CLPlacemark *)placemark;

@end
