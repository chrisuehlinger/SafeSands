//
//  TidalStationDB.m
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/13/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import "TidalStationDB.h"

@implementation TidalStationDB

@synthesize delegate;
@synthesize databaseBuilt;
@synthesize stationParser, dataStore;

static NSString * const coopsURL = @"http://tidesandcurrents.noaa.gov/cdata/StationListFormat?type=Current%20Data&filter=active&format=kml";

-(id)initWithDelegate:(id<TidalStationDBDelegate>)del
{
    delegate = del;
    databaseBuilt = NO;
    dataStore = [[SandsDataStore alloc] initWithDelegate:self andStoreName:@"tidalStations" andDataType:@"TidalStation"];
    if([dataStore databaseBuilt])
        [NSThread detachNewThreadSelector:@selector(databaseAlreadyBuilt) toTarget:self withObject:nil];
    else{
        fieldElements = [NSArray arrayWithObjects:@"nametag", @"coordinates", @"stnid", nil];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"pred" ofType:@"kml"];
        stationParser = [[SandsParser alloc] initWithFilePath:filePath
                                                  andDelegate:self
                                                    andFields:fieldElements
                                                andContainers:[NSArray arrayWithObject:@"Placemark"]];
    }
    
    return self;
}

-(void)databaseAlreadyBuilt
{
    [dataStore fetchItemsIfNecessary];
    databaseBuilt=YES;
    dispatch_async(dispatch_get_main_queue(),
                   ^{[delegate databaseBuilt];});
}

-(TidalStation *)closestStationTo:(CLPlacemark *)placemark
{
    NSInteger minDist = INFINITY;
    TidalStation *closestStation;
    while (![dataStore databaseBuilt]) {
        NSLog(@"Station DB not built.");
        [NSThread sleepForTimeInterval:1.0];
    }
    
    int i;
    float lat = placemark.location.coordinate.latitude;
    float lon = placemark.location.coordinate.longitude;
    for (i=1; i<[dataStore count]; i++) {
        TidalStation *thisStation = (TidalStation *)[dataStore fetchItem:i];
        //NSLog(@"%f %@, %@", [thisStation orderingValue], [thisStation name], [thisStation stationID]);
        float dist = 1000*sqrtf(powf((lat - [thisStation.latitude floatValue]), 2) + powf((lon - [thisStation.longtitude floatValue]), 2));
        NSInteger thisDist = dist;
        //NSInteger thisDist = [placemark.location distanceFromLocation:thisStation.location];
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
    TidalStation *newStation = (TidalStation *)[dataStore createItem];
    [newStation setName:[element objectForKey:@"nametag"]
                      coordinates:[element objectForKey:@"coordinates"]
                        stationID:[element objectForKey:@"stnid"]];
    [newStation setOrderingValue:[NSNumber numberWithInt:[dataStore count]]];
    //NSLog(@"%@", [element objectForKey:@"nametag"]);
}

-(void)parseComplete
{
    [dataStore databaseComplete];
    NSLog(@"TidalStationDB built.");
    [self databaseAlreadyBuilt];
}

-(void)retrievedData:(NSData *)data
{
    NSLog(@"This shouldn't happen: TidalStationDB");
}

-(void)handleConnectionError{
    [delegate handleConnectionError];
}

@end
