//
//  Beach.m
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/13/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import "Beach.h"

@implementation Beach

@synthesize placemark;
@synthesize weather;
@synthesize reading;
@synthesize delegate;

TidalStationDB *tidalDB;

- (id)initWithString:(NSString *)locationString andDelegate:(id<beachDelegate>)del
{
    delegate = del;
    geocoder = [[CLGeocoder alloc] init];
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    
    if([locationString isEqualToString:@"CurrentLocation"]) [locationManager startMonitoringSignificantLocationChanges];
    else [geocoder geocodeAddressString:locationString completionHandler:^(NSArray *placemarks, NSError *error)
          {dispatch_async(dispatch_get_main_queue(), ^{ [self haveLocation:[placemarks objectAtIndex:0]]; });}];
    return self;
}

-(void)haveLocation:(CLPlacemark *)thePlacemark
{
    [geocoder reverseGeocodeLocation:[thePlacemark location] completionHandler:^(NSArray *placemarks, NSError *error)
     {
         [self setPlacemark:[placemarks objectAtIndex:0]];
         dispatch_async(dispatch_get_main_queue(), ^{
             [delegate foundPlacemark:[NSString stringWithFormat:@"%@, %@",placemark.locality, placemark.administrativeArea]];
             weather = [[Weather alloc] initWithPlacemark:placemark];
             [weather setDelegate:self];
             reading = [[TidalReading alloc] initWithPlacemark:placemark];
             [reading setDelegate:self];
             
         });
     }];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [manager stopMonitoringSignificantLocationChanges];
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         dispatch_async(dispatch_get_main_queue(), ^{ [self haveLocation:[placemarks objectAtIndex:0]];});
     }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    // FIX ME
}

#pragma mark - other delegate methods

-(void)foundWeather
{
    NSString *outText = [[NSString alloc] init];
    outText = [outText stringByAppendingFormat:@"%@\n", [[weather currentConditions] objectForKey:@"condition"]];
    outText = [outText stringByAppendingFormat:@"%@oF\n", [[weather currentConditions] objectForKey:@"temp_f"]];
    [delegate foundWeather:outText andImage:[weather.currentConditions objectForKey:@"image"]];
}

-(void)foundTides
{
    NSString *outText = [[NSString alloc] init];
    NSMutableDictionary *nextTide = [reading nextTide];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh':'mm' 'a"];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    outText = [outText stringByAppendingFormat:@"%@ at %@\n", [nextTide objectForKey:@"highlow"], [dateFormatter stringFromDate:[nextTide objectForKey:@"formattedDate"]]];
    [delegate foundTides:outText];
}

@end

