//
//  Weather.m
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/13/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import "Weather.h"

@implementation Weather

@synthesize delegate;
@synthesize weatherParser;
@synthesize forecastInfo, currentConditions, forecastConditions;

-(id)initWithPlacemark:(CLPlacemark *)placemark
{
    forecastConditions = [[NSMutableArray alloc] init];
    containerElements = [NSArray arrayWithObjects: @"forecast_information", @"current_conditions", @"forecast_conditions", nil];
    fieldElements = [NSArray arrayWithObjects: @"city", @"postal_code", @"current_date_time", 
                               @"condition", @"temp_f", @"temp_c", @"humidity", @"icon", @"wind_condition", 
                               @"day_of_week", @"low", @"high", nil];
    
    weatherParser = [[SandsParser alloc] initWithPath:[NSString stringWithFormat: @"http://www.google.com/ig/api?weather=%@", [placemark postalCode]]
                                          andDelegate:self
                                            andFields:fieldElements
                                        andContainers:containerElements];
    return self;
}

-(void)parseWeatherData:(NSData *)data {
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    //[parser setDelegate:self];
    [parser parse];
}

#pragma mark - SandsParserDelegate methods

-(void)elementParsed:(NSMutableDictionary *)element
{
    //NSLog(@"Element parsed!");
    if (!forecastInfo)
        forecastInfo = [[NSMutableDictionary alloc] initWithDictionary: element copyItems:YES];
    else if (!currentConditions){
        currentConditions = [[NSMutableDictionary alloc] initWithDictionary: element copyItems:YES];
        //NSLog(@"%@ %@", @"temp_f", [element objectForKey:@"temp_f"]);
    }else
        [forecastConditions addObject: [[NSMutableDictionary alloc] initWithDictionary: element copyItems:YES]];
}

-(void)parseComplete
{
    BOOL corrupt = NO;
    NSString *outText = [NSString stringWithFormat:@"Weather\n"];
    outText = [outText stringByAppendingFormat:@"\tforecastInfo\n"];
    for (NSString *key in forecastInfo) {
        if (![forecastInfo objectForKey:key])
            corrupt = YES;
        outText = [outText stringByAppendingFormat:@"\t\t%@\t%@\n", key, [forecastInfo objectForKey:key]];
    }
    outText = [outText stringByAppendingFormat:@"\tcurrentConditions\n"];
    for (NSString *key in currentConditions) {
        if (![currentConditions objectForKey:key])
            corrupt = YES;
        outText = [outText stringByAppendingFormat:@"\t\t%@\t%@\n", key, [currentConditions objectForKey:key]];
    }
    for (NSDictionary *foreCond in forecastConditions) {
        outText = [outText stringByAppendingFormat:@"\tforecastConditions\n"];
        //if ([foreCond count] < 5)
        //    corrupt = YES;
        for (NSString *key in foreCond) {
            if (![foreCond objectForKey:key])
                corrupt = YES;
            outText = [outText stringByAppendingFormat:@"\t\t%@\t%@\n", key, [foreCond objectForKey:key]];
        }
    }
    //NSLog(@"%@", outText);
    if (corrupt) {
        [weatherParser repeatOperations];
    }else
        dispatch_async(dispatch_get_main_queue(), ^{[delegate foundWeather];});
}

@end
