//
//  Beach.m
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/13/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import "Beach.h"

@implementation Beach

@synthesize alerts;
@synthesize placemark;
@synthesize weather;
@synthesize reading;
@synthesize delegate;
@synthesize uvIndex;
@synthesize hasTidalReading, hasAlerts;
@synthesize geocoder, locationManager;

TidalStationDB *tidalDB;

- (id)initWithString:(NSString *)locationString andDelegate:(id<BeachDelegate>)del
{
    haveWeather = NO;
    haveWaterTemp = NO;
    hasTidalReading = NO;
    hasAlerts = NO;
    haveUVIndex = NO;
    delegate = del;
    geocoder = [[CLGeocoder alloc] init];
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    NSLog(@"%@", locationString);
    
    if([locationString isEqualToString:@"CurrentLocation"])
        if ([locationManager location] != nil){
            NSLog(@"Using pre-fetched location");
            [geocoder reverseGeocodeLocation:[locationManager location] completionHandler:^(NSArray *placemarks, NSError *error)
             {
                 if (placemarks)
                     dispatch_async(dispatch_get_main_queue(),
                                    ^{
                                        BOOL inTheUS=NO;
                                        for (CLPlacemark *p in placemarks) {
                                            if ([[p ISOcountryCode] isEqualToString:@"US"]) {
                                                inTheUS = YES;
                                                [self haveLocation:p];
                                                break;
                                            }
                                        }
                                        
                                        if(!inTheUS)
                                            [delegate handleNonUSACountryError];
                                    });
                 else {
                     [delegate handleConnectionError];
                     //[NSException raise:@"Geocode failed"
                     //            format:@"Reason: %@", [error localizedDescription]];
                 }
                 
             }];

        }else if ([CLLocationManager locationServicesEnabled]){ //[CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized){
            NSLog(@"Tracking location");
            [locationManager startMonitoringSignificantLocationChanges];
        }else {
            NSLog(@"Tracking location not authorized");
            [delegate handleConnectionError];
        }
    else
        [geocoder geocodeAddressString:locationString
                     completionHandler:^(NSArray *placemarks, NSError *error)
          {
              if (placemarks)
                  dispatch_async(dispatch_get_main_queue(),
                                 ^{
                                     BOOL inTheUS=NO;
                                     for (CLPlacemark *p in placemarks) {
                                         if ([[p ISOcountryCode] isEqualToString:@"US"]) {
                                             inTheUS = YES;
                                             [self haveLocation:p];
                                             break;
                                         }
                                     }
                                     
                                     if(!inTheUS)
                                         [delegate handleNonUSACountryError];
                                     
                                 });
              else
              {
                  [delegate handleConnectionError];
                  //[NSException raise:@"Geocode failed"
                  //            format:@"Reason: %@", [error localizedDescription]];
              }
          }];
    
    return self;
}

-(void)haveLocation:(CLPlacemark *)thePlacemark
{
    [geocoder reverseGeocodeLocation:[thePlacemark location] completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (placemarks){
             BOOL inTheUS=NO;
             
             for (CLPlacemark *p in placemarks) {
                 if ([[p ISOcountryCode] isEqualToString:@"US"]) {
                     [self setPlacemark:p];
                     inTheUS = YES;
                     break;
                 }
             }
             
             if(inTheUS)
                 dispatch_async(dispatch_get_main_queue(),
                                ^{
                                    weather = [[Weather alloc] initWithPlacemark:placemark];
                                    [weather setDelegate:self];
                                    uvIndex = [[UVIndex alloc] initWithPlacemark:placemark
                                                                     andDelegate:self];
                                    alerts = [[Alerts alloc] initWithPlacemark:placemark
                                                                   andDelegate:self];
                                    reading = [[TidalReading alloc] initWithPlacemark:placemark];
                                    [reading setDelegate:self];
                                });
             else
                 [delegate handleNonUSACountryError];
         }else
         {
             [delegate handleConnectionError];
             //[NSException raise:@"Geocode failed"
             //           format:@"Reason: %@", [error localizedDescription]];
         }
     }];
}

-(void)dealloc
{
    [geocoder cancelGeocode];
    [locationManager stopMonitoringSignificantLocationChanges];
    locationManager=nil;
    geocoder = nil;
    delegate=nil;
    alerts=nil;
    placemark=nil;
    weather=nil;
    reading=nil;
    uvIndex=nil;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [manager stopMonitoringSignificantLocationChanges];
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (placemarks)
             dispatch_async(dispatch_get_main_queue(),
                            ^{
                                BOOL inTheUS=NO;
                                 for (CLPlacemark *p in placemarks) {
                                     if ([[p ISOcountryCode] isEqualToString:@"US"]) {
                                         inTheUS = YES;
                                         [self haveLocation:p];
                                         break;
                                     }
                                 }
                                 
                                 if(!inTheUS)
                                     [delegate handleNonUSACountryError];
                            });
         else {
             [delegate handleConnectionError];
             //[NSException raise:@"Geocode failed"
             //            format:@"Reason: %@", [error localizedDescription]];
         }
         
     }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [delegate handleConnectionError];
    //[NSException raise:@"Find Location failed"
    //            format:@"Reason: %@", [error localizedDescription]];
}

#pragma mark - other delegate methods

-(void)foundWeather
{
    haveWeather=YES;
    haveWaterTemp=YES;
    if (haveWeather && haveWaterTemp && haveUVIndex) [delegate foundData];
}

-(void)foundTides
{
    hasTidalReading=YES;
    [delegate foundTides];
}

-(void)foundAlerts
{
    hasAlerts=YES;
    [delegate foundAlerts];
}

-(void)foundUVIndex
{
    haveUVIndex=YES;
    if (haveWeather && haveWaterTemp && haveUVIndex) [delegate foundData];
}

-(void)handleConnectionError{
    [delegate handleConnectionError];
}

@end

