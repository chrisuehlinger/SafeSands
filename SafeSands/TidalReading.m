//
//  TidalReading.m
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/13/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import "TidalReading.h"
#import "SandsAppDelegate.h"

@implementation TidalReading

@synthesize delegate;
@synthesize readings;
@synthesize tidalDB;
@synthesize station;
@synthesize tideParser;

static NSString * const noaaURL = @"http://tidesandcurrents.noaa.gov/noaatidepredictions/NOAATidesFacade.jsp?datatype=Annual%20XML&timeZone=0&datum=MLLW&Stationid=";

NSDateFormatter *dateFormatter;

CLPlacemark *thePlacemark;

-(id)initWithPlacemark:(CLPlacemark *)placemark andDelegate:(id<TidalDelegate>)del
{
    delegate = del;
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy'/'MM'/'dd' 'HH':'mm"];
    
    fieldElements = [NSArray arrayWithObjects:@"date", @"day", @"time", @"predictions_in_ft", @"predictions_in_cm", @"highlow", nil];
    readings = [[NSMutableArray alloc] init];
    thePlacemark = placemark;
    tidalDB = [(SandsAppDelegate *)[[UIApplication sharedApplication] delegate] stationDB];
    station = [tidalDB closestStationTo:thePlacemark];
    
    NSString *tidalPath = [NSString stringWithFormat: @"%@%@", noaaURL, station.stationID];
    //NSLog(@"%@", tidalPath);
    
    tideParser = [[SandsParser alloc] initWithPath:tidalPath
                                       andDelegate:self
                                         andFields:fieldElements
                                     andContainers:[NSArray arrayWithObject:@"item"]];
    return self;
}

-(NSMutableDictionary *)lastTide
{
    NSMutableDictionary *last;
    
    for (NSMutableDictionary *read in readings) {
        if ([[read objectForKey:@"formattedDate"] timeIntervalSinceNow] > 0) {
            break;
        }else {
            last=read;
        }
    }
    
    return last;
}

-(NSMutableDictionary *)nextTide
{
    NSMutableDictionary *next;
    
    for (NSMutableDictionary *read in readings) {
        if ([[read objectForKey:@"formattedDate"] timeIntervalSinceNow] > 0) {
            next=read;
            break;
        }
    }
    
    return next;
}

#pragma mark - TidalStationDBDelegate methods

-(void)databaseBuilt
{
    station = [tidalDB closestStationTo:thePlacemark];
    
    NSString *tidalPath = [NSString stringWithFormat: @"%@%@", noaaURL, station.stationID];
    //NSLog(@"%@", tidalPath);
    
    tideParser = [[SandsParser alloc] initWithPath:tidalPath
                                       andDelegate:self
                                         andFields:fieldElements
                                     andContainers:[NSArray arrayWithObject:@"item"]];
}

#pragma mark SandsParserDelegate methods

-(void)elementParsed:(NSMutableDictionary *)element
{

    NSDate *date = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ %@", [element objectForKey:@"date"],[element objectForKey:@"time"]]];
    
    [element setObject:date forKey:@"formattedDate"];
    [readings addObject: element];
}

-(void)parseComplete
{

    /*NSLog(@"Seconds between Tides: %f Minimum acceptable: %d", [nextDate timeIntervalSinceDate:lastDate], (12*3600));
        NSSortDescriptor *dateDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"formattedDate"
                                    ascending:YES
                                     selector:@selector(timeIntervalSinceNow)];
        NSArray *temp = [[NSArray alloc] initWithArray:readings];
        readings = [[NSMutableArray alloc] initWithArray:[temp sortedArrayUsingDescriptors:[NSArray arrayWithObjects:dateDescriptor, nil]]];
        for (NSDictionary *element in readings)
            NSLog(@"%@ Tide at: %@ on %@", [element objectForKey:@"highlow"], [element objectForKey:@"time"], [element objectForKey:@"date"]);*/
    
    dispatch_async(dispatch_get_main_queue(), ^{[delegate foundTides];});
}

-(void)retrievedData:(NSData *)data
{
    NSLog(@"This shouldn't happen: TidalReading");
}

-(void)handleError:(SandsError)error{
    if(error == kOtherError)
        [delegate handleError:kTideError];
    else 
        [delegate handleError:error];
}

@end
