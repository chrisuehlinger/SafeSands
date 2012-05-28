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
@synthesize waterTemp;
@synthesize reading;
@synthesize delegate;
@synthesize uvIndex;

TidalStationDB *tidalDB;

- (id)initWithString:(NSString *)locationString andDelegate:(id<BeachDelegate>)del
{
    haveWeather = NO;
    haveWaterTemp = NO;
    haveTidalReading = NO;
    haveAlerts = NO;
    haveUVIndex = NO;
    delegate = del;
    geocoder = [[CLGeocoder alloc] init];
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    NSLog(@"%@", locationString);
    
    if([locationString isEqualToString:@"CurrentLocation"])
        [locationManager startMonitoringSignificantLocationChanges];
    else
        [geocoder geocodeAddressString:locationString
                     completionHandler:^(NSArray *placemarks, NSError *error)
          {
              if (placemarks)
                  dispatch_async(dispatch_get_main_queue(),
                                 ^{
                                     [self haveLocation:[placemarks objectAtIndex:0]];
                                 });
              else
              {
                  [[NSNotificationCenter defaultCenter] postNotificationName:@"Connection Error" object:nil];
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
             if([[[placemarks objectAtIndex:0] ISOcountryCode] isEqualToString:@"USA"])
             {
                 [self setPlacemark:[placemarks objectAtIndex:0]];
                 dispatch_async(dispatch_get_main_queue(),
                                ^{
                                    weather = [[Weather alloc] initWithPlacemark:placemark];
                                    [weather setDelegate:self];
                                    reading = [[TidalReading alloc] initWithPlacemark:placemark];
                                    [reading setDelegate:self];
                                    alerts = [[Alerts alloc] initWithPlacemark:placemark
                                                                   andDelegate:self];
                                    uvIndex = [[UVIndex alloc] initWithPlacemark:placemark
                                                                     andDelegate:self];
                                });
             }else
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"Non-USA Country"
                                                                     object:nil];
         }else
         {
             [[NSNotificationCenter defaultCenter] postNotificationName:@"Connection Error"
                                                                 object:nil];
             //[NSException raise:@"Geocode failed"
             //           format:@"Reason: %@", [error localizedDescription]];
         }
     }];
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
                                [self haveLocation:[placemarks objectAtIndex:0]];
                            });
         else {
             [[NSNotificationCenter defaultCenter] postNotificationName:@"Connection Error" object:nil];
             //[NSException raise:@"Geocode failed"
             //            format:@"Reason: %@", [error localizedDescription]];
         }
         
     }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Connection Error" object:nil];
    //[NSException raise:@"Find Location failed"
    //            format:@"Reason: %@", [error localizedDescription]];
}

#pragma mark - other delegate methods

-(void)foundWeather
{
    /*NSString *outText = [[NSString alloc] initWithString:@"Current Conditions:\n"];
    outText = [outText stringByAppendingFormat:@"%@\n", [[weather currentConditions] objectForKey:@"condition"]];
    outText = [outText stringByAppendingFormat:@"Air: %@°F\n", [[weather currentConditions] objectForKey:@"temp_f"]];
    outText = [outText stringByAppendingFormat:@"Water: %@°F\n", [[weather waterTemp] tempF]];
    [delegate foundWeather:outText andImage:[weather.currentConditions objectForKey:@"image"]];*/
    haveWeather=YES;
    haveWaterTemp=YES;
    if (haveWeather && haveWaterTemp && haveTidalReading && haveAlerts && haveUVIndex) [delegate foundData];
}

-(void)foundTides
{
    /*NSString *outText = [[NSString alloc] init];
    NSMutableDictionary *nextTide = [reading nextTide];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh':'mm' 'a"];
    [dateFormatter setLocale:[NSLocale systemLocale]];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    
    NSString *tideString;
    if([[nextTide objectForKey:@"highlow"] isEqualToString:@"H"])
        tideString = @"High";
    else
        tideString = @"Low";
    
    outText = [outText stringByAppendingFormat:@"Next Tide:\n%@ Tide at %@\n", tideString, [dateFormatter stringFromDate:[nextTide objectForKey:@"formattedDate"]]];*/
    haveTidalReading=YES;
    if (haveWeather && haveWaterTemp && haveTidalReading && haveAlerts && haveUVIndex) [delegate foundData];
}

-(void)foundAlerts
{
    /*NSString *outText = [[NSString alloc] init];
    int numAlerts = [[alerts alerts] count];
    if(numAlerts==0)
        outText = [outText stringByAppendingString:@"No Alerts Found.\n"];
    else
    {
        if (numAlerts==1)
            outText = [outText stringByAppendingString:@"1 Alert Found!\n"];
        else
            outText = [outText stringByAppendingFormat:@"%d Alerts Found.\n", numAlerts];
        
        outText = [outText stringByAppendingString:[alerts headlines]];
    }
    
    NSLog(@"outtext = %@", outText);*/
    haveAlerts=YES;
    if (haveWeather && haveWaterTemp && haveTidalReading && haveAlerts && haveUVIndex) [delegate foundData];
}

-(void)foundUVIndex
{
    /*NSString *outText = [[NSString alloc] init];
    if([uvIndex uvAlert])
        outText = [outText stringByAppendingFormat:@"WARNING: High UV Rating!\n"];
    
    outText = [outText stringByAppendingFormat:@"UV Index: %d\n", [[uvIndex index] intValue]];
    [delegate foundUVIndex:outText];*/
    haveUVIndex=YES;
    if (haveWeather && haveWaterTemp && haveTidalReading && haveAlerts && haveUVIndex) [delegate foundData];
}

@end

