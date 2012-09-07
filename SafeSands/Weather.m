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
@synthesize waterTemp;
@synthesize currentConditions;

SandsParser *imageParser;
bool waterTempFound;
bool imagesLoaded;

-(id)initWithPlacemark:(CLPlacemark *)placemark andDelegate:(id<WeatherDelegate>)del
{
    delegate = del;
    waterTempFound = NO;
    imagesLoaded = NO;
    waterTemp = [[WaterTemperature alloc] initWithPlacemark:placemark andDelegate:self];
    containerElements = [NSArray arrayWithObjects: @"current_observation", nil];
    fieldElements = [NSArray arrayWithObjects: 
                               @"weather", @"temp_f", @"temp_c", @"feelslike_f", @"feelslike_c", @"relative_humidity", @"wind_mph", 
                               @"wind_kph", @"low", @"high", nil];
    
    //NSLog(@"%@", [NSString stringWithFormat: @"http://www.google.com/ig/api?weather=%@", [placemark postalCode]]);
    weatherParser = [[SandsParser alloc] initWithPath: [NSString stringWithFormat: @"http://api.wunderground.com/api/0be862001bb6f5f5/conditions/q/%@.xml", [placemark postalCode]]
                                          andDelegate: self
                                            andFields: fieldElements
                                        andContainers: containerElements];
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
    if (!currentConditions){
        currentConditions = [[NSMutableDictionary alloc] initWithDictionary: element copyItems:YES];
        //NSLog(@"%@ %@", @"temp_f", [element objectForKey:@"temp_f"]);
    }
}

-(void)parseComplete
{
    BOOL corrupt = NO;
    NSString *outText = [NSString stringWithFormat:@"Weather\n"];
    outText = [outText stringByAppendingFormat:@"\tcurrentConditions\n"];
    for (NSString *key in currentConditions) {
        if (![currentConditions objectForKey:key])
            corrupt = YES;
        outText = [outText stringByAppendingFormat:@"\t\t%@\t%@\n", key, [currentConditions objectForKey:key]];
    }

    //NSLog(@"%@", outText);
    if (corrupt) {
        [weatherParser repeatOperations];
    }
    imagesLoaded = YES;
    
    if(imagesLoaded && waterTempFound)
        dispatch_async(dispatch_get_main_queue(), ^{[delegate foundWeather];});
}

-(void)retrievedData:(NSData *)data
{
    bool imageUsed = NO;
    if(![currentConditions objectForKey:@"image"]){
        [currentConditions setObject:[[UIImage alloc] initWithData:data] forKey:@"image"];
        imageUsed = YES;
    }
    
    imagesLoaded = YES;
    
    if(imagesLoaded && waterTempFound)
        dispatch_async(dispatch_get_main_queue(), ^{[delegate foundWeather];});
}

-(void)foundWaterTemperature
{
    waterTempFound = YES;
    if(imagesLoaded && waterTempFound)
        dispatch_async(dispatch_get_main_queue(), ^{[delegate foundWeather];});
}

-(void)handleError:(SandsError)error{
    if(error == kOtherError)
        [delegate handleError:kWeatherError];
    else 
        [delegate handleError:error];
}

@end
