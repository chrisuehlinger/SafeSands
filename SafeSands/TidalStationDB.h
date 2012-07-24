//
//  TidalStationDB.h
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/13/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreData/CoreData.h>
#import "TidalStation.h"
#import "SandsParser.h"
#import "SandsDataStore.h"

@protocol TidalStationDBDelegate <NSObject>
-(void)databaseBuilt;
-(void)handleConnectionError;
@end

@interface TidalStationDB : NSObject<SandsParserDelegate, SandsDataStoreDelegate>{
    NSArray *fieldElements;
}

@property (weak) id<TidalStationDBDelegate> delegate;
@property (strong, nonatomic) SandsParser *stationParser;
@property (strong, nonatomic) SandsDataStore *dataStore;
@property bool databaseBuilt;

-(id)initWithDelegate:(id<TidalStationDBDelegate>)del;
-(TidalStation *)closestStationTo:(CLPlacemark *)placemark;


@end
