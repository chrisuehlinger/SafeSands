//
//  Weather.h
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/13/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "SandsParser.h"
#import "WaterTemperature.h"

@protocol WeatherDelegate
-(void)foundWeather;
@end

@interface Weather : NSObject<SandsParserDelegate, WaterTemperatureDelegate>{
    id<WeatherDelegate> delegate;
    
    WaterTemperature *waterTemp;
    
    NSArray * containerElements;
    NSArray * fieldElements;
    SandsParser *weatherParser;
    
    NSMutableDictionary *forecastInfo;
    NSMutableDictionary *currentConditions;
    NSMutableArray *forecastConditions;
}

@property (strong, nonatomic) id<WeatherDelegate> delegate;
@property (strong, nonatomic) SandsParser *weatherParser;

@property (strong, nonatomic) WaterTemperature *waterTemp;

@property (strong, nonatomic) NSMutableDictionary *forecastInfo;
@property (strong, nonatomic) NSMutableDictionary *currentConditions;
@property (strong, nonatomic) NSMutableArray *forecastConditions;

-(id)initWithPlacemark:(CLPlacemark *)placemark;

@end
