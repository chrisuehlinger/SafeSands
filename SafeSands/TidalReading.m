//
//  TidalReading.m
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/13/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import "TidalReading.h"

@implementation TidalReading

@synthesize delegate;
@synthesize readings;
@synthesize tidalDB;

//timeZone?
static NSString * const noaaURL = @"http://tidesandcurrents.noaa.gov/noaatidepredictions/NOAATidesFacade.jsp?datatype=Annual%20XML&timeZone=2&datum=MLLW&Stationid=";

CLPlacemark *thePlacemark;

-(id)initWithPlacemark:(CLPlacemark *)placemark
{
    fieldElements = [NSArray arrayWithObjects:@"date", @"day", @"time", @"predictions_in_ft", @"predictions_in_cm", @"highlow", nil];
    readings = [[NSMutableArray alloc] init];
    thePlacemark = placemark;
    tidalDB = [[TidalStationDB alloc] initWithDelegate:self];
    return self;
}

-(void)databaseBuilt
{
    station = [tidalDB closestStationTo:thePlacemark];
    NSString *tidalPath = [NSString stringWithFormat: @"%@%@", noaaURL, station.stationID];
    NSLog(@"%@", tidalPath);
    
    tideParser = [[SandsParser alloc] initWithPath:tidalPath
                                       andDelegate:self
                                         andFields:fieldElements
                                     andContainers:[NSArray arrayWithObject:@"item"]];
    
    /*NSURLRequest *tideRequest = [NSURLRequest requestWithURL:[NSURL URLWithString: tidalPath]];
    tideConnection = [[NSURLConnection alloc] initWithRequest:tideRequest delegate:self];
    NSAssert(tideConnection != nil, @"Could not establish connection");*/
}

#pragma mark SandsParserDelegate methods

-(void)elementParsed:(NSMutableDictionary *)element
{
    //for (NSString *key in element) NSLog(@"%@ %@", key, [element objectForKey:key]);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy'/'MM'/'dd' 'HH':'mm' 'a"];
    NSDate *date = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ %@", [element objectForKey:@"date"],[element objectForKey:@"time"]]];
    
    
    if (date && [date timeIntervalSinceNow] >= 0) {
        //NSLog(@"%@ %@", [self.currentItemObject objectForKey:@"date"],[self.currentItemObject objectForKey:@"time"]);
        [element setObject:date forKey:@"formattedDate"];
        [readings addObject: element];
    }
}

-(void)parseComplete
{
    dispatch_async(dispatch_get_main_queue(), ^{[delegate foundTides];});
}

@end
