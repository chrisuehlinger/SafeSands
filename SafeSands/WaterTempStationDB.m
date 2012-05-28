//
//  WaterTempStationDB.m
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/29/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import "WaterTempStationDB.h"

@implementation WaterTempStationDB

@synthesize delegate;
@synthesize databaseBuilt;

static NSString * const nodcURL = @"http://www.nodc.noaa.gov/dsdt/cwtg/rss/all.xml";

-(id)initWithDelegate:(id<WaterTempStationDBDelegate>)del
{
    databaseBuilt = NO;
    delegate = del;
    count=0;
    
    dataStore = [[SandsDataStore alloc] initWithDelegate:self andStoreName:@"waterTempStations" andDataType:@"WaterTempStation"];
    if([dataStore databaseBuilt])
        [NSThread detachNewThreadSelector:@selector(databaseAlreadyBuilt) toTarget:self withObject:nil];
    else{
        fieldElements = [NSArray arrayWithObjects:@"title", @"link", nil];
        stationParser = [[SandsParser alloc] initWithPath:nodcURL
                                              andDelegate:self
                                                andFields:fieldElements
                                            andContainers:[NSArray arrayWithObject:@"item"]];
    }
    
    return self;
}

-(void)databaseAlreadyBuilt
{
    databaseBuilt=YES;
    [dataStore fetchItemsIfNecessary];
    dispatch_async(dispatch_get_main_queue(),
                   ^{[delegate databaseBuilt];});
}

-(WaterTempStation *)closestStationTo:(CLPlacemark *)placemark
{
    NSInteger minDist = INFINITY;
    WaterTempStation *closestStation;
    while (![dataStore databaseBuilt]) {
        NSLog(@"Station DB not built.");
        [NSThread sleepForTimeInterval:1.0];
    }
    
    int i;
    for (i=1; i<[dataStore count]; i++) {
        WaterTempStation *thisStation = (WaterTempStation *)[dataStore fetchItem:i];
        //NSLog(@"%f %@, %@", [thisStation orderingValue], [thisStation name], [thisStation stationID]);
        NSInteger thisDist = [placemark.location distanceFromLocation:thisStation.location];
        if( thisDist < minDist && thisDist > -1) {
            closestStation = thisStation;
            minDist = thisDist;
            //NSLog(@"%d %@ %d", i, [closestStation name], minDist);
        }
    }
    return closestStation;
}

#pragma mark - SandsParserDelegate methods

-(void)elementParsed:(NSMutableDictionary *)element
{
    //NSLog(@"%@",element);
    WaterTempStation *newStation = (WaterTempStation *)[dataStore createItem];
    NSArray *linkMatches = [[element objectForKey:@"link"] componentsSeparatedByString:@"#n"];
    NSString *newStationID = [linkMatches objectAtIndex:1];
    [newStation setName:[element objectForKey:@"title"]
              stationID:newStationID
            andDelegate:self];
    [newStation setOrderingValue:[NSNumber numberWithInt:[dataStore count]]];
}

-(void)parseComplete
{
    
}

-(void)retrievedData:(NSData *)data
{
    NSLog(@"This shouldn't happen: WaterTempStationDB");
}

-(void)stationLocationFound:(WaterTempStation *)theStation
{
    count++;
    //NSLog(@"Location found: %@", theStation.name);
    if(count == [dataStore count]) {
        [dataStore databaseComplete];
        NSLog(@"WaterTempStationDB built.");
        [self databaseAlreadyBuilt];
    }
}


@end
