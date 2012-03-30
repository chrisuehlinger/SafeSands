//
//  WaterTemperature.h
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/29/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WaterTempStation.h"
#import "WaterTempStationDB.h"
#import "SandsParser.h"

@protocol WaterTemperatureDelegate <NSObject>

-(void)foundWaterTemperature;

@end

@interface WaterTemperature : NSObject<SandsParserDelegate, WaterTempStationDBDelegate>{
    id<WaterTemperatureDelegate> delegate;
    WaterTempStationDB *stationDB;
    WaterTempStation *station;
}

@property (strong, nonatomic) id<WaterTemperatureDelegate> delegate;

@property (strong, nonatomic) NSNumber *tempF;
@property (strong, nonatomic) NSNumber *tempC;
@property (strong, nonatomic) SandsParser *waterTempParser;

-(id)initWithPlacemark:(CLPlacemark *)p andDelegate:(id<WaterTemperatureDelegate>)del;

@end
