//
//  Beach.h
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/13/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Weather.h"
#import "WaterTemperature.h"
#import "TidalReading.h"
#import "Alerts.h"
#import "UVIndex.h"

@protocol beachDelegate
-(void)foundPlacemark:(NSString *)newText;
-(void)foundWeather:(NSString *)newText andImage:(UIImage *)theImage;
-(void)foundTides:(NSString *)newText;
-(void)foundAlerts:(NSString *)newText;
-(void)foundUVIndex:(NSString *)newText;
@end

@interface Beach : NSObject<CLLocationManagerDelegate, weatherDelegate, tidalDelegate, AlertsDelegate, UVIndexDelegate> 
{
    id<beachDelegate> delegate;
    CLPlacemark *placemark;
    Weather *weather;
    WaterTemperature *waterTemp;
    TidalReading *reading;
    Alerts *alerts;
    UVIndex *uvIndex;
    
    CLGeocoder *geocoder;
    CLLocationManager *locationManager;
}

@property (strong, nonatomic) id<beachDelegate> delegate;
@property (strong, nonatomic) CLPlacemark *placemark;
@property (strong, nonatomic) Weather *weather;
@property (strong, nonatomic) WaterTemperature *waterTemp;
@property (strong, nonatomic) TidalReading *reading;
@property (strong, nonatomic) Alerts *alerts;
@property (strong, nonatomic) UVIndex *uvIndex;

- (id)initWithString:(NSString *)locationString andDelegate:(id<beachDelegate>)del;

@end