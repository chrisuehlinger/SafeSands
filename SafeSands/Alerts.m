//
//  Alerts.m
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/29/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import "Alerts.h"
#import "SandsAppDelegate.h"

@implementation Alerts

@synthesize placemark;
@synthesize delegate;
@synthesize alerts;
@synthesize headlines;
@synthesize alertParser;

NSString *alertsPath= @"http://alerts.weather.gov/cap/us.php?x=0";
NSString *sameCodesPath= @"http://www.nws.noaa.gov/nwr/SameCode.txt";
NSString *zoneCodesPath = @"http://www.nws.noaa.gov/geodata/catalog/wsom/data/bp23fe12.dbx";
NSString *countyCodesPath = @"http://www.itl.nist.gov/fipspubs/co-codes/states.txt";

SandsParser *codeRetriever;
NSString *code;
NSMutableDictionary *stateAbbrevs;
#ifndef NDEBUG
NSMutableDictionary *alertsPerCode;
#endif
NSMutableDictionary *codeMapping;

-(id)initWithPlacemark:(CLPlacemark *)p andDelegate:(id<AlertsDelegate>)del
{
    stateAbbrevs = [(SandsAppDelegate *)[[UIApplication sharedApplication] delegate] stateAbbrevs];
    headlines = [[NSString alloc] init];
    placemark=p;
    delegate=del;
    alerts = [[NSMutableArray alloc] init];
    fieldElements = [NSArray arrayWithObjects:@"id", @"updated", @"published", @"name", @"title", @"summary", @"valueName", @"value", @"cap:event", @"cap:effective", @"cap:expires", @"cap:status", @"cap:msgType", @"cap:category", @"cap:urgency", @"cap:severity", @"cap:certainty", @"cap:areaDesc", nil];
    codeRetriever = [[SandsParser alloc] initWithDataPath:sameCodesPath andDelegate:self];
    return self;
}

#pragma mark - SandsParserDelegate methods

-(void)elementParsed:(NSMutableDictionary *)element
{
    NSArray *affectedAreas = [[[element objectForKey:@"cap:geocode"] objectForKey:@"value"] componentsSeparatedByString:@" "];
    if ([affectedAreas containsObject: code]) {
        [alerts addObject:element];
        headlines = [headlines stringByAppendingFormat:@"%@\n", [element objectForKey:@"cap:event"]];
        NSLog(@"Found Alert: %@", [element objectForKey:@"cap:event"]);
    }
#ifndef NDEBUG
    [self incrementAlerts:element];
#endif
}

-(void)parseComplete
{
    
    #ifndef NDEBUG
    [self codeWithMostAlerts];
    #endif
    
    NSLog(@"Alerts parsed");
    [delegate foundAlerts];
}

-(void)retrievedData:(NSData *)data
{
    NSString *codesFile = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *county;
    if ([[placemark subAdministrativeArea] length] > 4
        && [[[placemark subAdministrativeArea] substringFromIndex:([[placemark subAdministrativeArea] length]-5)] isEqualToString:@" City"])
        county = [[placemark subAdministrativeArea] substringToIndex:([[placemark subAdministrativeArea] length]-5)];
    else
        county = [placemark subAdministrativeArea];
    NSLog(@"County: \"%@\" State: \"%@\"", county, [stateAbbrevs objectForKey:[placemark administrativeArea]]);
    
    NSMutableArray *sameCodes = [[NSMutableArray alloc] initWithArray:[codesFile componentsSeparatedByString:@"\n"]];
    for (NSString *c in sameCodes) {
        NSArray *parts = [c componentsSeparatedByString:@","];
        if ([[parts objectAtIndex:1] isEqualToString:county]
            && [[[parts objectAtIndex:2] substringFromIndex:1] isEqualToString:[stateAbbrevs objectForKey:[placemark administrativeArea]]]) {
            code = [parts objectAtIndex:0];
            NSLog(@"Code: %@", code);
            break;
        }
    }
    alertParser = [[SandsParser alloc] initWithPath:alertsPath
                                        andDelegate:self
                                          andFields:fieldElements
                                      andContainers:[NSArray arrayWithObjects:@"entry", @"cap:geocode", nil]];
#ifndef NDEBUG
    [self getCodeMapping:sameCodes];
#endif
}

-(void)handleError:(SandsError)error{
    if(error == kOtherError)
        [delegate handleError:kAlertsError];
    else 
        [delegate handleError:error];
}

#pragma mark - Methods for finding most alerted county

#ifndef NDEBUG
-(void)getCodeMapping:(NSArray *)codesArray
{
    alertsPerCode = [[NSMutableDictionary alloc] init];
    
    codeMapping = [[NSMutableDictionary alloc] init];
    for (NSString *c in codesArray) {
        NSArray *parts = [c componentsSeparatedByString:@","];
        [alertsPerCode setValue:[NSNumber numberWithInt:0] forKey:[parts objectAtIndex:0]];
        [codeMapping setValue:[NSString stringWithFormat:@"%@,%@",[parts objectAtIndex:1],[parts objectAtIndex:2]]
                       forKey:[parts objectAtIndex:0]];
    }
}


-(void)incrementAlerts:(NSDictionary *)alert
{
    NSArray *affectedAreas = [[[alert objectForKey:@"cap:geocode"] objectForKey:@"value"] componentsSeparatedByString:@" "];
    
    for (NSString *c in affectedAreas)
        if(c.length > 0)
        {
            NSNumber *oldVal = [alertsPerCode objectForKey:c];
            oldVal = [NSNumber numberWithInteger: ([oldVal intValue] + 1)];

            [alertsPerCode setValue:oldVal forKey:c];

        }
}

-(void)codeWithMostAlerts
{
    NSString *codeWithMostAlerts;
    int mostAlerts = 0;
    for (NSString *c in alertsPerCode) {
        NSNumber *numAlerts = [alertsPerCode objectForKey:c];
        if ([numAlerts intValue] > mostAlerts ) {
            mostAlerts = [numAlerts intValue];
            codeWithMostAlerts = c;
        }
    }
    NSLog(@"Most Alerts: %d in county: %@", mostAlerts,[codeMapping objectForKey:codeWithMostAlerts]);
}
#endif

@end
