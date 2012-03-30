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

@protocol tidalStationDBDelegate <NSObject>

-(void)databaseBuilt;

@end

@interface TidalStationDB : NSObject<SandsParserDelegate, SandsDataStoreDelegate>{
    id<tidalStationDBDelegate> delegate;
    SandsParser *stationParser;
    NSArray *fieldElements;
    
    SandsDataStore *dataStore;
}

@property (strong, nonatomic) id<tidalStationDBDelegate> delegate;

-(id)initWithDelegate:(id<tidalStationDBDelegate>)del;
-(TidalStation *)closestStationTo:(CLPlacemark *)placemark;


@end
