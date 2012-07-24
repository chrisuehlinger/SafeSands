//
//  UVIndex.m
//  SafeSands
//
//  Created by Christopher Uehlinger on 4/16/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import "UVIndex.h"

@implementation UVIndex

@synthesize delegate, placemark, indexParser;
@synthesize uvAlert, forecastDate, index;

NSString *uvURL = @"http://iaspub.epa.gov/uvindexalert/services/UVIndexAlertPort?method=getUVIndexAlertByZipCode&in0=";

-(id)initWithPlacemark:(CLPlacemark *)p andDelegate:(id<UVIndexDelegate>)del
{
    delegate = del;
    placemark = p;
    fieldElements = [NSArray arrayWithObjects:@"alert", @"forecastDate", @"index", nil];
    indexParser = [[SandsParser alloc] initWithPath:[uvURL stringByAppendingString:placemark.postalCode]
                                        andDelegate:self
                                          andFields:fieldElements
                                      andContainers:[NSArray arrayWithObject:@"multiRef"]];
    return self;
}

-(void)elementParsed:(NSMutableDictionary *)element
{
    if ([[element objectForKey:@"alert"] isEqualToString:@"true"])
        uvAlert = YES;
    else
        uvAlert = NO;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy'-'MM'-'dd"];
    forecastDate = [dateFormatter dateFromString:[element objectForKey:@"forecastDate"]];
    
    index = [NSNumber numberWithInt:[[element objectForKey:@"index"] intValue]];
    NSLog(@"UV Index = %d", [index intValue]);
}

-(void)parseComplete
{
    [delegate foundUVIndex];
}

-(void)retrievedData:(NSData *)data
{
    NSLog(@"This shouldn't happen: UVIndex");
}

-(void)handleConnectionError{
    [delegate handleConnectionError];
}

@end
