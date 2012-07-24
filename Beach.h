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
-(void)foundTides;
-(void)foundAlerts;
-(void)handleConnectionError;
-(void)handleNonUSACountryError;
@end

@interface Beach : NSObject<CLLocationManagerDelegate, WeatherDelegate, tidalDelegate, AlertsDelegate, UVIndexDelegate> 
{   
    bool haveWeather;
    bool haveWaterTemp;
    bool hasTidalReading;
    bool hasAlerts;
    bool haveUVIndex;
}

@property (weak) id<BeachDelegate> delegate;
@property (strong, nonatomic) CLPlacemark *placemark;
@property (strong, nonatomic) Weather *weather;
@property (strong, nonatomic) TidalReading *reading;
@property (strong, nonatomic) Alerts *alerts;
@property (strong, nonatomic) UVIndex *uvIndex;
@property (strong, nonatomic) CLGeocoder *geocoder;
@property (strong) CLLocationManager *locationManager;

@property bool hasTidalReading;
@property bool hasAlerts;

- (id)initWithString:(NSString *)locationString andDelegate:(id<BeachDelegate>)del;
@end