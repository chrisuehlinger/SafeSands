//
//  Weather.h
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/13/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol weatherDelegate
-(void)upDateText:(NSString *)newText;
@end

@interface Weather : NSObject<NSXMLParserDelegate>{
    id<weatherDelegate> delegate;
    
    NSMutableDictionary *currentItemObject;
    
    NSArray * containerElements;
    NSArray * fieldElements;
    
    NSMutableDictionary *forecastInfo;
    NSMutableDictionary *currentConditions;
    NSMutableArray *forecastConditions;
}

@property (strong, nonatomic) id<weatherDelegate> delegate;

@property (strong, nonatomic) NSURLConnection *weatherConnection;
@property (strong, nonatomic) NSMutableData *weatherData;
@property (strong, nonatomic) NSMutableDictionary *currentItemObject;

@property (strong, nonatomic) NSMutableDictionary *forecastInfo;
@property (strong, nonatomic) NSMutableDictionary *currentConditions;
@property (strong, nonatomic) NSMutableArray *forecastConditions;

-(id)initWithPlacemark:(CLPlacemark *)placemark;

@end
