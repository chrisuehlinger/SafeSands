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

@protocol BeachDelegate
-(void)foundData;
@end

@interface Beach : NSObject<CLLocationManagerDelegate, WeatherDelegate, tidalDelegate, AlertsDelegate, UVIndexDelegate> 
{
    id<BeachDelegate> delegate;
    CLPlacemark *placemark;
    Weather *weather;
    WaterTemperature *waterTemp;
    TidalReading *reading;
    Alerts *alerts;
    UVIndex *uvIndex;
    
    bool haveWeather;
    bool haveWaterTemp;
    bool haveTidalReading;
    bool haveAlerts;
    bool haveUVIndex;
    
    CLGeocoder *geocoder;
    CLLocationManager *locationManager;
}

@property (strong, nonatomic) id<BeachDelegate> delegate;
@property (strong, nonatomic) CLPlacemark *placemark;
@property (strong, nonatomic) Weather *weather;
@property (strong, nonatomic) WaterTemperature *waterTemp;
@property (strong, nonatomic) TidalReading *reading;
@property (strong, nonatomic) Alerts *alerts;
@property (strong, nonatomic) UVIndex *uvIndex;

- (id)initWithString:(NSString *)locationString andDelegate:(id<BeachDelegate>)del;
@end