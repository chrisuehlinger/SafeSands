//
//  TidalStation.m
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/13/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import "TidalStation.h"

@implementation TidalStation

@dynamic latitude;
@dynamic location;
@dynamic longtitude;
@dynamic name;
@dynamic orderingValue;
@dynamic stationID;

-(id)initWithName:(NSString *)theName coordinates:(NSString *)coords stationID:(NSString *)stnID
{
    name = theName;
    NSArray *transCoords = [coords componentsSeparatedByString:@","];
    latitude = [NSNumber numberWithDouble:[[transCoords objectAtIndex:1] doubleValue]];
    longtitude = [NSNumber numberWithDouble:[[transCoords objectAtIndex:0] doubleValue]];
    location = [[CLLocation alloc] initWithLatitude:[latitude doubleValue] longitude:[longtitude doubleValue]];
    stationID = stnID;
    
    //NSLog(@"nametag: %@ coordinates: %f,%f ID: %@",name, location.coordinate.latitude, location.coordinate.longitude, stationID);
    return self;
}

-(void)setName:(NSString *)theName coordinates:(NSString *)coords stationID:(NSString *)stnID
{
    name = theName;
    NSArray *transCoords = [coords componentsSeparatedByString:@","];
    latitude = [NSNumber numberWithDouble:[[transCoords objectAtIndex:1] doubleValue]];
    longtitude = [NSNumber numberWithDouble:[[transCoords objectAtIndex:0] doubleValue]];
    location = [[CLLocation alloc] initWithLatitude:[latitude doubleValue] longitude:[longtitude doubleValue]];
    stationID = stnID;
}

-(void)awakeFromFetch
{
    [super awakeFromFetch];
    //location = [[CLLocation alloc] initWithLatitude:[latitude doubleValue] longitude:[longtitude doubleValue]];
}

@end
