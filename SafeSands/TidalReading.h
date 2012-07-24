//
//  TidalReading.h
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/13/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "TidalStation.h"
#import "TidalStationDB.h"
#import "SandsParser.h"

@protocol tidalDelegate
-(void)foundTides;
-(void)handleConnectionError;
@end

@interface TidalReading : NSObject<TidalStationDBDelegate,SandsParserDelegate>{
    NSArray * fieldElements;
}

@property (weak) id<tidalDelegate> delegate;
@property (strong, nonatomic) SandsParser *tideParser;
@property (strong, nonatomic) NSMutableArray *readings;
@property (strong, nonatomic) TidalStationDB *tidalDB;
@property (strong, nonatomic) TidalStation *station;

-(id)initWithPlacemark:(CLPlacemark *)placemark;// andTidalDB:(TidalStationDB *)database;
-(void)databaseBuilt;

-(NSMutableDictionary *)lastTide;
-(NSMutableDictionary *)nextTide;

@end
