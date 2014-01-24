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
-(void)handleError:(SandsError)error;
@end

@interface Weather : NSObject<SandsParserDelegate, WaterTemperatureDelegate>{
    
    NSArray * containerElements;
    NSArray * fieldElements;
}

@property (weak) id<WeatherDelegate> delegate;
@property (strong, nonatomic) SandsParser *weatherParser;

@property (strong, nonatomic) WaterTemperature *waterTemp;

@property (strong, nonatomic) NSMutableDictionary *currentConditions;

-(id)initWithPlacemark:(CLPlacemark *)placemark andDelegate:(id<WeatherDelegate>)del;

@end
