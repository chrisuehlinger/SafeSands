//
//  Beach.m
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/13/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import "Beach.h"
#import "SandsAppDelegate.h"

@implementation Beach

@synthesize alerts;
@synthesize placemark;
@synthesize weather;
@synthesize reading;
@synthesize delegate;
@synthesize uvIndex;
@synthesize hasTidalReading, hasAlerts;
@synthesize geocoder, locationManager;
@synthesize locationInput;

TidalStationDB *tidalDB;
NSMutableDictionary *stateAbbrevs;

- (id)initWithString:(NSString *)locationString andDelegate:(id<BeachDelegate>)del
{
    stateAbbrevs = [(SandsAppDelegate *)[[UIApplication sharedApplication] delegate] stateAbbrevs];
    locationInput=locationString;
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
            [delegate changeLoadingText:@"Geocoding Location..."];
            
            [self reverseGeocodeLocation:[locationManager location]];
            /*[geocoder reverseGeocodeLocation:[locationManager location] completionHandler:^(NSArray *placemarks, NSError *error)
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
                                            [delegate handleError:kNonUSACountryError];
                                    });
                 else {
                     [delegate handleError:kGeocodeError];
                     //[NSException raise:@"Geocode failed"
                     //            format:@"Reason: %@", [error localizedDescription]];
                 }
                 
             }];*/

        }else if ([CLLocationManager locationServicesEnabled]){
            NSLog(@"Tracking location");
            [locationManager startMonitoringSignificantLocationChanges];
            [delegate changeLoadingText:@"Finding Current Location..."];
        }else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized){
            NSLog(@"Tracking location not authorized");
            [delegate handleError:kLocationServiceAuthError];
        }else {
            NSLog(@"Unknown location error");
            [delegate handleError:kLocationManagerError];
        }
    else{
        [delegate changeLoadingText:@"Geocoding Location..."];
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
                                         [delegate handleError:kNonUSACountryError];
                                     
                                 });
              else
              {
                  [delegate handleError:kGeocodeError];
                  //[NSException raise:@"Geocode failed"
                  //            format:@"Reason: %@", [error localizedDescription]];
              }
          }];
    }
    
    return self;
}

-(void)haveLocation:(CLPlacemark *)thePlacemark
{
    /*[delegate changeLoadingText:@"Loading Weather..."];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults objectForKey:@"SafeSandsPro"] isEqualToString:@"YES"]) {
        
        NSString *cityName = [NSString stringWithFormat:@"%@, %@", [placemark locality], [stateAbbrevs objectForKey:[placemark administrativeArea]]];
        
        NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:[defaults objectForKey:@"Recent Locations"]];
        
        if([temp containsObject:cityName])
            [temp removeObject:cityName];
        
        
        [temp addObject:cityName];
        [defaults setObject:temp forKey:@"Recent Locations"];
        [defaults synchronize];
        
        for (NSString *a in [[NSUserDefaults standardUserDefaults] objectForKey:@"Recent Locations"]) {
            NSLog(@"%@", a);
        }
    }
    
    weather = [[Weather alloc] initWithPlacemark:placemark andDelegate:self];
    uvIndex = [[UVIndex alloc] initWithPlacemark:placemark andDelegate:self];
    alerts = [[Alerts alloc] initWithPlacemark:placemark andDelegate:self];
    reading = [[TidalReading alloc] initWithPlacemark:placemark andDelegate:self];*/
    
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
                                    [delegate changeLoadingText:@"Loading Weather..."];
                                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                    if ([[defaults objectForKey:@"SafeSandsPro"] isEqualToString:@"YES"]) {
                                        
                                        NSString *cityName = [NSString stringWithFormat:@"%@, %@", [placemark locality], [stateAbbrevs objectForKey:[placemark administrativeArea]]];
                                        
                                        NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:[defaults objectForKey:@"Recent Locations"]];
                                        
                                        NSLog(@"Success! %@", cityName);
                                        if([temp containsObject:cityName])
                                            [temp removeObject:cityName];
                                        
                                        
                                        [temp addObject:cityName];
                                        [defaults setObject:temp forKey:@"Recent Locations"];
                                        [defaults synchronize];
                                        
                                        for (NSString *a in [[NSUserDefaults standardUserDefaults] objectForKey:@"Recent Locations"]) {
                                            NSLog(@"%@", a);
                                        }
                                    }
                                    weather = [[Weather alloc] initWithPlacemark:placemark andDelegate:self];
                                    uvIndex = [[UVIndex alloc] initWithPlacemark:placemark andDelegate:self];
                                    alerts = [[Alerts alloc] initWithPlacemark:placemark andDelegate:self];
                                    reading = [[TidalReading alloc] initWithPlacemark:placemark andDelegate:self];
                                });
             else
                 [delegate handleError:kNonUSACountryError];
         }else
         {
             [delegate handleError:kGeocodeError];
             //[NSException raise:@"Geocode failed"
             //           format:@"Reason: %@", [error localizedDescription]];
         }
     }];
}

-(void)reverseGeocodeLocation:(CLLocation *)theLocation
{
    [geocoder reverseGeocodeLocation:theLocation completionHandler:^(NSArray *placemarks, NSError *error)
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
                                    [delegate handleError:kNonUSACountryError];
                            });
         else {
             [delegate handleError:kGeocodeError];
             //[NSException raise:@"Geocode failed"
             //            format:@"Reason: %@", [error localizedDescription]];
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
    NSLog(@"Found it!");
    [manager stopMonitoringSignificantLocationChanges];
    [delegate changeLoadingText:@"Geocoding Location..."];
    [self reverseGeocodeLocation:newLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [delegate handleError:kLocationManagerError];
    //[NSException raise:@"Find Location failed"
    //            format:@"Reason: %@", [error localizedDescription]];
}

#pragma mark - other delegate methods

-(void)foundWeather
{
    haveWeather=YES;
    haveWaterTemp=YES;
    if (haveWeather && haveWaterTemp && haveUVIndex)
        [delegate foundData];
    else if (!haveUVIndex)
        [delegate changeLoadingText:@"Loading UV Index..."];
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
    if (haveWeather && haveWaterTemp && haveUVIndex)
        [delegate foundData];
    else if (!haveWeather)
        [delegate changeLoadingText:@"Loading Weather..."];
}

-(void)handleError:(SandsError)error{
    [delegate handleError:error];
}

@end

