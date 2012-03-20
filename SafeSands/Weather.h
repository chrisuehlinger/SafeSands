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

@protocol weatherDelegate
-(void)foundWeather;
@end

@interface Weather : NSObject<SandsParserDelegate>{
    id<weatherDelegate> delegate;
    
    NSArray * containerElements;
    NSArray * fieldElements;
    
    NSMutableDictionary *forecastInfo;
    NSMutableDictionary *currentConditions;
    NSMutableArray *forecastConditions;
    
    SandsParser *weatherParser;
}

@property (strong, nonatomic) id<weatherDelegate> delegate;

@property (strong, nonatomic) SandsParser *weatherParser;

@property (strong, nonatomic) NSMutableDictionary *forecastInfo;
@property (strong, nonatomic) NSMutableDictionary *currentConditions;
@property (strong, nonatomic) NSMutableArray *forecastConditions;

-(id)initWithPlacemark:(CLPlacemark *)placemark;

@end
