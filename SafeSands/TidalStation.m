//
//  TidalStation.m
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/13/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import "TidalStation.h"

@implementation TidalStation



@synthesize name;
@synthesize location;
@synthesize stationID;

-(id)initWithName:(NSString *)theName coordinates:(NSString *)coords stationID:(NSString *)stnID
{
    name = theName;
    NSArray *transCoords = [coords componentsSeparatedByString:@","];
    location = [[CLLocation alloc] initWithLatitude:[[transCoords objectAtIndex:1] doubleValue] longitude:[[transCoords objectAtIndex:0] doubleValue]];
    stationID = stnID;
    
    //NSLog(@"nametag: %@ coordinates: %f,%f ID: %@",name, location.coordinate.latitude, location.coordinate.longitude, stationID);
    return self;
}

@end
