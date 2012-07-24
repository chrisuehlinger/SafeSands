//
//  WaterTempStation.m
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/29/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import "WaterTempStation.h"


@implementation WaterTempStation

@dynamic name;
@dynamic latitude;
@dynamic location;
@dynamic longitude;
@dynamic orderingValue;
@dynamic stationID;
@synthesize delegate;

-(id)initWithName:(NSString *)theName stationID:(NSString *)stnID andDelegate:(id<WaterTempStationDelegate>)del
{
    delegate = del;
    name = theName;
    stationID = stnID;
    [self findLocation];
    return self;
}

-(void)setName:(NSString *)theName stationID:(NSString *)stnID andDelegate:(id<WaterTempStationDelegate>)del
{
    delegate=del;
    name = theName;
    stationID = stnID;
    [self findLocation];
}

-(void)findLocation
{
    geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:name completionHandler:^(NSArray *placemarks, NSError *error)
     {
         CLPlacemark *mark = [placemarks objectAtIndex:0];
         location = [mark location];
         latitude = [NSNumber numberWithDouble:location.coordinate.latitude];
         longitude = [NSNumber numberWithDouble:location.coordinate.longitude];
         [delegate stationLocationFound:self];
     }];
}

-(void)awakeFromFetch
{
    [super awakeFromFetch];
    location = [[CLLocation alloc] initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
}

@end
