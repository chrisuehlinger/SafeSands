//
//  Alerts.m
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/29/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import "Alerts.h"


@implementation Alerts

@synthesize placemark;
@synthesize delegate;
@synthesize alerts;

NSString *alertsPath= @"http://alerts.weather.gov/cap/us.php?x=0";
NSString *sameCodesPath= @"http://www.nws.noaa.gov/nwr/SameCode.txt";
NSString *zoneCodesPath = @"http://www.nws.noaa.gov/geodata/catalog/wsom/data/bp23fe12.dbx";
NSString *countyCodesPath = @"http://www.itl.nist.gov/fipspubs/co-codes/states.txt";

SandsParser *codeRetriever;
NSString *code;

-(id)initWithPlacemark:(CLPlacemark *)p andDelegate:(id<AlertsDelegate>)del
{
    placemark=p;
    delegate=del;
    alerts = [[NSMutableArray alloc] init];
    fieldElements = [NSArray arrayWithObjects:@"id", @"updated", @"published", @"name", @"title", @"summary", @"valueName", @"value", @"cap:event", @"cap:effective", @"cap:expires", @"cap:status", @"cap:msgType", @"cap:category", @"cap:urgency", @"cap:severity", @"cap:certainty", @"cap:areaDesc", nil];
    codeRetriever = [[SandsParser alloc] initWithDataPath:sameCodesPath andDelegate:self];
    return self;
}

-(void)searchAlerts
{
    
}

#pragma mark - SandsParserDelegate methods

-(void)elementParsed:(NSMutableDictionary *)element
{
        NSArray *affectedAreas = [[[element objectForKey:@"cap:geocode"] objectForKey:@"value"] componentsSeparatedByString:@" "];
        if ([affectedAreas containsObject: code]) {
            [alerts addObject:element];
            NSLog(@"Found Alert: %@", [element objectForKey:@"cap:event"]);
        }
}

-(void)parseComplete
{
    NSLog(@"Alerts parsed");
    [delegate foundAlerts];
}

-(void)retrievedData:(NSData *)data
{
    NSString *codesFile = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *county;
    if ([[[placemark subAdministrativeArea] substringFromIndex:([[placemark subAdministrativeArea] length]-5)] isEqualToString:@" City"])
        county = [[placemark subAdministrativeArea] substringToIndex:([[placemark subAdministrativeArea] length]-5)];
    else
        county = [placemark subAdministrativeArea];
    NSLog(@"County: \"%@\"", county);
    
    NSMutableArray *sameCodes = [[NSMutableArray alloc] initWithArray:[codesFile componentsSeparatedByString:@"\n"]];
    for (NSString *c in sameCodes) {
        NSArray *parts = [c componentsSeparatedByString:@","];
        
        //TODO: make state abbreviaton table just to be safe
        if ([[parts objectAtIndex:1] isEqualToString:county]) {
            code = [parts objectAtIndex:0];
            NSLog(@"Code: %@", code);
            break;
        }
    }
    alertParser = [[SandsParser alloc] initWithPath:alertsPath
                                        andDelegate:self
                                          andFields:fieldElements
                                      andContainers:[NSArray arrayWithObjects:@"entry", @"cap:geocode", nil]];
}

@end
