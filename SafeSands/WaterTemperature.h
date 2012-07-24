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
-(void)handleConnectionError;
@end

@interface WaterTemperature : NSObject<SandsParserDelegate, WaterTempStationDBDelegate>

@property (weak) id<WaterTemperatureDelegate> delegate;

@property (strong, nonatomic) WaterTempStationDB *stationDB;
@property (strong, nonatomic) NSNumber *tempF;
@property (strong, nonatomic) NSNumber *tempC;
@property (strong, nonatomic) SandsParser *waterTempParser;
@property (strong, nonatomic) WaterTempStation *station;

-(id)initWithPlacemark:(CLPlacemark *)p andDelegate:(id<WaterTemperatureDelegate>)del;

@end
