//
//  TidalStationDB.m
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/13/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import "TidalStationDB.h"

@implementation TidalStationDB

@synthesize delegate, currentParsedCharacterData, currentItemObject;

-(id)initWithDelegate:(id)del
{
    delegate = del;
    fieldElements = [NSArray arrayWithObjects:@"nametag", @"coordinates", @"stnid", nil];
    stations = [[NSMutableArray alloc] init];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"pred" ofType:@"kml"];  
    NSData *stationData = [NSData dataWithContentsOfFile:filePath];
    //NSLog(@"have data: %d bytes", [stationData length]);
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [NSThread detachNewThreadSelector:@selector(parseStationData:) toTarget:self withObject:stationData];
    
    return self;
}

- (void)parseStationData:(NSData *)data {
    // NSLog(@"%s", __FUNCTION__);
    self.currentParsedCharacterData = [NSMutableString string];
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    [parser parse];
}

-(TidalReading *)retrieveTidalData:(CLPlacemark *)placemark
{
    NSInteger minDist = INFINITY;
    TidalStation *closestStation;
    for (TidalStation *station in stations) {
        NSInteger thisDist = [placemark.location distanceFromLocation:station.location];
        if( thisDist < minDist) {
            closestStation = station;
            minDist = thisDist;
            //NSLog(@"%@ %d", [closestStation name], minDist);
        }
    }
    //NSLog(@"%@ %d", [closestStation name], minDist);
    TidalReading *reading = [[TidalReading alloc] initWithStationID:[closestStation stationID]];
    return reading;
}

-(void)databaseBuilt
{
    //FIX ME
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [delegate databaseBuilt];
}


#pragma mark -
#pragma mark NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    //NSLog(@"%s %@", __FUNCTION__, elementName);
    
    if ([elementName isEqualToString:@"Placemark"]) self.currentItemObject = [[NSMutableDictionary alloc] init];
    else if ([fieldElements containsObject:elementName]) {
        accumulatingParsedCharacterData = YES;
        // reset character accumulator
        [currentParsedCharacterData setString:@""];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {     
    //NSLog(@"%s (%@) data: %@", __FUNCTION__, elementName, currentParsedCharacterData);
    
    if ([fieldElements containsObject:elementName]){
        //NSLog(@"%@ %@", elementName, self.currentParsedCharacterData);
        [self.currentItemObject setValue:self.currentParsedCharacterData forKey:elementName];
        currentParsedCharacterData = [[NSMutableString alloc] init];
    }else if ([elementName isEqualToString:@"Placemark"]) {
        //NSLog(@"nametag: %@ coordinates: %@ ID: %@",[self.currentItemObject objectForKey:@"nametag"],[self.currentItemObject objectForKey:@"coordinates"],[self.currentItemObject objectForKey:@"stnid"]);
        
        [stations addObject:[[TidalStation alloc] initWithName:[self.currentItemObject objectForKey:[fieldElements objectAtIndex:0]]coordinates:[self.currentItemObject objectForKey:[fieldElements objectAtIndex:1]] stationID:[self.currentItemObject objectForKey:[fieldElements objectAtIndex:2]]]];
    }
        
    // Stop accumulating parsed character data. We won't start again until specific elements begin.
    accumulatingParsedCharacterData = NO;
}

-(void)parserDidEndDocument:(NSXMLParser *)parser
{
    dispatch_async(dispatch_get_main_queue(), ^{[self databaseBuilt];});
}

// The parser delivers parsed character data (PCDATA) in chunks, not necessarily all at once. 
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    //NSLog(@"%s (%@)", __FUNCTION__, string);
    if (accumulatingParsedCharacterData) {
        [self.currentParsedCharacterData appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    // We abort parsing if we get more than kMaximumNumberOfItemsToParse. 
    // We use the didAbortParsing flag to avoid treating this as an error. 
    if (didAbortParsing == NO) {
        // Pass the error to the main thread for handling.
        [self performSelectorOnMainThread:@selector(handleError:) withObject:parseError waitUntilDone:NO];
    }
}

@end
