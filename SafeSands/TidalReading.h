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

@protocol TidalDelegate
-(void)foundTides;
-(void)handleError:(SandsError)error;
@end

@interface TidalReading : NSObject<TidalStationDBDelegate,SandsParserDelegate>{
    NSArray * fieldElements;
}

@property (weak) id<TidalDelegate> delegate;
@property (strong, nonatomic) SandsParser *tideParser;
@property (strong, nonatomic) NSMutableArray *readings;
@property (strong, nonatomic) TidalStationDB *tidalDB;
@property (strong, nonatomic) TidalStation *station;

-(id)initWithPlacemark:(CLPlacemark *)placemark andDelegate:(id<TidalDelegate>)del;
-(void)databaseBuilt;

-(NSMutableDictionary *)lastTide;
-(NSMutableDictionary *)nextTide;

@end
