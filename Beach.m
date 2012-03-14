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

- (id)initWithString:(NSString *)locationString
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    geocoder = [[CLGeocoder alloc] init];
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    
    if([locationString isEqualToString:@"CurrentLocation"]) [locationManager startMonitoringSignificantLocationChanges];
    else [geocoder geocodeAddressString:locationString completionHandler:^(NSArray *placemarks, NSError *error)
         {
             dispatch_async(dispatch_get_main_queue(), ^{ [self haveLocation:[placemarks objectAtIndex:0]]; });
         }];
    tidalDB = [[TidalStationDB alloc] initWithDelegate:self];
    return self;
}

-(void)haveLocation:(CLPlacemark *)thePlacemark
{
    [geocoder reverseGeocodeLocation:[thePlacemark location] completionHandler:^(NSArray *placemarks, NSError *error)
     {
         [self setPlacemark:[placemarks objectAtIndex:0]];
         dispatch_async(dispatch_get_main_queue(), ^{
             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
             [delegate upDateText: [NSString stringWithFormat: @"CLPlacemark\tplacemark\n\tcoord.lat\t%f\n\tcoord.long\t%f\n\tlocality\t%@\n\tpostalCode\t%@\n",
                                    placemark.location.coordinate.latitude,
                                    placemark.location.coordinate.longitude,
                                    placemark.locality,
                                    placemark.postalCode]];
             weather = [[Weather alloc] initWithPlacemark:placemark];
             [weather setDelegate:self];
         });
     }];
}

-(void)databaseBuilt
{
    reading = [tidalDB retrieveTidalData:placemark];
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

-(void)upDateText:(NSString *)newText
{
    [delegate upDateText:newText];
    
}
@end
