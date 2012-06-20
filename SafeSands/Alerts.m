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
@synthesize headlines;

NSString *alertsPath= @"http://alerts.weather.gov/cap/us.php?x=0";
NSString *sameCodesPath= @"http://www.nws.noaa.gov/nwr/SameCode.txt";
NSString *zoneCodesPath = @"http://www.nws.noaa.gov/geodata/catalog/wsom/data/bp23fe12.dbx";
NSString *countyCodesPath = @"http://www.itl.nist.gov/fipspubs/co-codes/states.txt";

SandsParser *codeRetriever;
NSString *code;
NSMutableDictionary *stateAbbrevs;
NSMutableDictionary *alertsPerCode;
NSMutableDictionary *codeMapping;

-(id)initWithPlacemark:(CLPlacemark *)p andDelegate:(id<AlertsDelegate>)del
{
    [self setupStateAbbrevs];
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
    [self incrementAlerts:element];
}

-(void)parseComplete
{
    [self codeWithMostAlerts];
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
    [self getCodeMapping:sameCodes];
}

-(void)setupStateAbbrevs
{
    stateAbbrevs = [[NSMutableDictionary alloc] init];
    [stateAbbrevs setValue:@"AL" forKey:@"Alabama"];
    [stateAbbrevs setValue:@"AK" forKey:@"Alaska"];
    [stateAbbrevs setValue:@"AZ" forKey:@"Arizona"];
    [stateAbbrevs setValue:@"AR" forKey:@"Arkansas"];
    [stateAbbrevs setValue:@"CA" forKey:@"California"];
    [stateAbbrevs setValue:@"CO" forKey:@"Colorado"];
    [stateAbbrevs setValue:@"CT" forKey:@"Connecticut"];
    [stateAbbrevs setValue:@"DE" forKey:@"Delaware"];
    [stateAbbrevs setValue:@"FL" forKey:@"Florida"];
    [stateAbbrevs setValue:@"GA" forKey:@"Georgia"];
    [stateAbbrevs setValue:@"HI" forKey:@"Hawaii"];
    [stateAbbrevs setValue:@"ID" forKey:@"Idaho"];
    [stateAbbrevs setValue:@"IL" forKey:@"Illinois"];
    [stateAbbrevs setValue:@"IN" forKey:@"Indiana"];
    [stateAbbrevs setValue:@"IA" forKey:@"Iowa"];
    [stateAbbrevs setValue:@"KS" forKey:@"Kansas"];
    [stateAbbrevs setValue:@"KY" forKey:@"Kentucky"];
    [stateAbbrevs setValue:@"LA" forKey:@"Louisiana"];
    [stateAbbrevs setValue:@"ME" forKey:@"Maine"];
    [stateAbbrevs setValue:@"MD" forKey:@"Maryland"];
    [stateAbbrevs setValue:@"MA" forKey:@"Massachusetts"];
    [stateAbbrevs setValue:@"MI" forKey:@"Michigan"];
    [stateAbbrevs setValue:@"MN" forKey:@"Minnesota"];
    [stateAbbrevs setValue:@"MS" forKey:@"Mississippi"];
    [stateAbbrevs setValue:@"MO" forKey:@"Missouri"];
    [stateAbbrevs setValue:@"MT" forKey:@"Montana"];
    [stateAbbrevs setValue:@"NE" forKey:@"Nebraska"];
    [stateAbbrevs setValue:@"NV" forKey:@"Nevada"];
    [stateAbbrevs setValue:@"NH" forKey:@"New Hampshire"];
    [stateAbbrevs setValue:@"NJ" forKey:@"New Jersey"];
    [stateAbbrevs setValue:@"NM" forKey:@"New Mexico"];
    [stateAbbrevs setValue:@"NY" forKey:@"New York"];
    [stateAbbrevs setValue:@"NC" forKey:@"North Carolina"];
    [stateAbbrevs setValue:@"ND" forKey:@"North Dakota"];
    [stateAbbrevs setValue:@"OH" forKey:@"Ohio"];
    [stateAbbrevs setValue:@"OK" forKey:@"Oklahoma"];
    [stateAbbrevs setValue:@"OR" forKey:@"Oregon"];
    [stateAbbrevs setValue:@"PA" forKey:@"Pennsylvania"];
    [stateAbbrevs setValue:@"RI" forKey:@"Rhode Island"];
    [stateAbbrevs setValue:@"SC" forKey:@"South Carolina"];
    [stateAbbrevs setValue:@"SD" forKey:@"South Dakota"];
    [stateAbbrevs setValue:@"TN" forKey:@"Tennessee"];
    [stateAbbrevs setValue:@"TX" forKey:@"Texas"];
    [stateAbbrevs setValue:@"UT" forKey:@"Utah"];
    [stateAbbrevs setValue:@"VT" forKey:@"Vermont"];
    [stateAbbrevs setValue:@"VA" forKey:@"Virginia"];
    [stateAbbrevs setValue:@"WA" forKey:@"Washington"];
    [stateAbbrevs setValue:@"WV" forKey:@"West Virginia"];
    [stateAbbrevs setValue:@"WI" forKey:@"Wisconsin"];
    [stateAbbrevs setValue:@"WY" forKey:@"Wyoming"];
    [stateAbbrevs setValue:@"AS" forKey:@"American Samoa"];
    [stateAbbrevs setValue:@"DC" forKey:@"District of Columbia"];
    [stateAbbrevs setValue:@"FM" forKey:@"Federated States of Micronesia"];
    [stateAbbrevs setValue:@"GU" forKey:@"Guam"];
    [stateAbbrevs setValue:@"MH" forKey:@"Marshall Islands"];
    [stateAbbrevs setValue:@"MP" forKey:@"Northern Mariana Islands"];
    [stateAbbrevs setValue:@"PW" forKey:@"Palau"];
    [stateAbbrevs setValue:@"PR" forKey:@"Puerto Rico"];
    [stateAbbrevs setValue:@"VI" forKey:@"Virgin Islands"];
    [stateAbbrevs setValue:@"AE" forKey:@"Armed Forces Africa"];
    [stateAbbrevs setValue:@"AA" forKey:@"Armed Forces Americas"];
    [stateAbbrevs setValue:@"AE" forKey:@"Armed Forces Canada"];
    [stateAbbrevs setValue:@"AE" forKey:@"Armed Forces Europe"];
    [stateAbbrevs setValue:@"AE" forKey:@"Armed Forces Middle East"];
    [stateAbbrevs setValue:@"AP" forKey:@"Armed Forces Pacific"];
}

#pragma mark - Methods for finding most alerted county

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
    for (NSString *c in affectedAreas) {
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
    NSLog(@"Most Alerts: %d in county: %@", mostAlerts, [codeMapping objectForKey:codeWithMostAlerts]);
}

@end
