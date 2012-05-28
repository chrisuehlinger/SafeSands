//
//  WaterTemperature.m
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/29/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import "WaterTemperature.h"
#import "SandsAppDelegate.h"

@implementation WaterTemperature

@synthesize delegate;
@synthesize waterTempParser;
@synthesize tempF, tempC;

NSString *ndocURL = @"http://www.nodc.noaa.gov/dsdt/cwtg/rss/all.xml";
CLPlacemark *thePlacemark;

-(id)initWithPlacemark:(CLPlacemark *)p andDelegate:(id<WaterTemperatureDelegate>)del
{
    thePlacemark = p;
    delegate = del;
    //stationDB =[[WaterTempStationDB alloc] initWithDelegate:self];
    stationDB  = [(SandsAppDelegate *)[[UIApplication sharedApplication] delegate] tempStationDB];
    
    station = [stationDB closestStationTo:thePlacemark];
    waterTempParser = 
    [[SandsParser alloc] initWithPath:ndocURL
                          andDelegate:self
                            andFields:[NSArray arrayWithObjects:@"link", @"description", nil]
                        andContainers:[NSArray arrayWithObjects:@"item", nil]];
    //NSLog(@"Station ID: %@", station.stationID);
    
    return self;
}

-(void)elementParsed:(NSMutableDictionary *)element
{
    NSError *err;
    NSArray *linkMatches = [[element objectForKey:@"link"] componentsSeparatedByString:@"#n"];    
    NSString *stationID =[linkMatches objectAtIndex:1];
    //NSLog(@"%@", stationID);
    if ([stationID isEqualToString:[station stationID]]) {
        //NSLog(@"desc: %@", [element objectForKey:@"description"]);
        NSArray *tempMatches = [[NSRegularExpression regularExpressionWithPattern:@"\\W(-?1?[0-9]{1,2}\\.[0-9])\\W" options:0 error:&err] matchesInString:[element objectForKey:@"description"] options:0 range:NSMakeRange(0, [[element objectForKey:@"description"] length])];
        tempF = [NSNumber numberWithDouble:[[[element objectForKey:@"description"] substringWithRange:[[tempMatches objectAtIndex:0] rangeAtIndex:1]] doubleValue]];
        tempC = [NSNumber numberWithDouble:[[[element objectForKey:@"description"] substringWithRange:[[tempMatches objectAtIndex:1] rangeAtIndex:1]] doubleValue]];
        //NSLog(@"Water Temperature = %.1f°F %.1f°C", [tempF doubleValue], [tempC doubleValue]);
        [delegate foundWaterTemperature];
    }
}

-(void)parseComplete
{
    
}

-(void)retrievedData:(NSData *)data
{
    NSLog(@"This shouldn't happen: WaterTemperature");
}

-(void)databaseBuilt
{
    
    station = [stationDB closestStationTo:thePlacemark];
    waterTempParser = 
    [[SandsParser alloc] initWithPath:ndocURL
                          andDelegate:self
                            andFields:[NSArray arrayWithObjects:@"link", @"description", nil]
                        andContainers:[NSArray arrayWithObjects:@"item", nil]];
    //NSLog(@"Station ID: %@", station.stationID);
}

@end
