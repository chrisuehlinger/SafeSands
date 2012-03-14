//
//  TidalReading.m
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/13/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import "TidalReading.h"

@implementation TidalReading

@synthesize readings;
@synthesize tideConnection, tideData;
@synthesize currentParsedCharacterData, currentItemObject;

//timeZone?
static NSString * const noaaURL = @"http://tidesandcurrents.noaa.gov/noaatidepredictions/NOAATidesFacade.jsp?datatype=Annual%20XML&timeZone=2&datum=MLLW&Stationid=";

-(id)initWithStationID:(NSString *)stnID
{
    fieldElements = [NSArray arrayWithObjects:@"date", @"day", @"time", @"predictions_in_ft", @"predictions_in_cm", @"highlow", nil];
    readings = [[NSMutableArray alloc] init];
    NSURLRequest *tideRequest = [NSURLRequest requestWithURL:[NSURL URLWithString: [NSString stringWithFormat: @"%@%@", noaaURL, stnID]]];
    tideConnection = [[NSURLConnection alloc] initWithRequest:tideRequest delegate:self];
    NSAssert(tideConnection != nil, @"Could not establish connection");
    return self;
}

-(void)parseTideData:(NSMutableData *)data
{
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    [parser parse];
}

-(void)readingsCollected
{
    
}

#pragma mark -
#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    if(!tideData) tideData = [[NSMutableData alloc] init];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.tideData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self setTideConnection:nil];
    
    NSLog(@"Have tide data, %d bytes", tideData.length);
    [NSThread detachNewThreadSelector:@selector(parseTideData:) toTarget:self withObject:tideData];
    
    
    [self setTideData:nil];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self setTideConnection:nil];
    
    NSLog(@"Uh oh! Error!");
    
    [self setTideData:nil];
    
}


#pragma mark -
#pragma mark NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    //NSLog(@"%s %@", __FUNCTION__, elementName);
    
    if ([elementName isEqualToString:@"item"]) self.currentItemObject = [[NSMutableDictionary alloc] init];
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
    }else if ([elementName isEqualToString:@"item"]) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat: @"yyyy'/'MM'/'dd' 'HH':'mm' 'a"];
        NSDate *date = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ %@", [self.currentItemObject objectForKey:@"date"],[self.currentItemObject objectForKey:@"time"]]];
        [self.currentItemObject setValue:date forKey:@"formattedDate"];
        
        if ([date timeIntervalSinceNow] >= 0) {
            NSLog(@"%@ %@", [self.currentItemObject objectForKey:@"date"],[self.currentItemObject objectForKey:@"time"]);
            [readings addObject: self.currentItemObject];
        }
    }
    
    // Stop accumulating parsed character data. We won't start again until specific elements begin.
    accumulatingParsedCharacterData = NO;
}

-(void)parserDidEndDocument:(NSXMLParser *)parser
{
    dispatch_async(dispatch_get_main_queue(), ^{[self readingsCollected];});
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
    /*if (didAbortParsing == NO) {
        // Pass the error to the main thread for handling.
        [self performSelectorOnMainThread:@selector(handleError:) withObject:parseError waitUntilDone:NO];
    }*/
}
/*
#pragma mark -
#pragma mark Date parsing methods

-(NSString *) dateToLocalizedString:(NSDate *) date {
    // NSLog(@"%s %@", __FUNCTION__, date);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE, MMMM d, hh:mm a"];
    NSString *s = [dateFormatter stringFromDate:date];
    [dateFormatter release];
    return s;
}
-(NSDate *) SQLDateToDate:(NSString *) SQLDateString {
    // NSLog(@"%s %@", __FUNCTION__, SQLDateString);
    if ((id) SQLDateString == [NSNull null] || [SQLDateString length] == 0)
        return [NSDate date]; // current date/time
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];   // "SQL" format
    NSDate *date = [dateFormatter dateFromString:SQLDateString];
    [dateFormatter release];
    return date;
}

-(NSString *) dateStringToSQLDate:(NSString *) dateString {
    // NSLog(@"%s %@", __FUNCTION__, dateString);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLenient:NO];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];   // the formatter should live in UTC
    NSString *s = nil;
    
    NSArray *dateFormats = [NSArray arrayWithObjects:
                            @"EEE, dd MMM yyyy HHmmss zzz",  // no colons, see below
                            @"dd MMM yyyy HHmmss zzz",
                            @"yyyy-MM-dd'T'HHmmss'Z'",
                            @"yyyy-MM-dd'T'HHmmssZ",
                            @"EEE MMM dd HHmm zzz yyyy",
                            @"EEE MMM dd HHmmss zzz yyyy",
                            nil];
    
    // iOS's limited implementation of unicode date formating is missing support for colons in timezone offsets 
    // so we just take all the colons out of the string -- it's more flexible like this anyway
    dateString = [dateString stringByReplacingOccurrencesOfString:@":" withString:@""];
    NSDate * date = nil;
    for (NSString *format in dateFormats) {
        [dateFormatter setDateFormat:format];
        // store the NSDate object
        if((date = [dateFormatter dateFromString:dateString])) {
            // message(@"%@ (%@) -> %@", dateString, format, date);
            break;
        }
    }
    
    if (!date) date = [NSDate date];    // no date? use now.
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];   // SQL date format
    s = [dateFormatter stringFromDate:date];
    [dateFormatter release];
    return s;
}

#pragma mark -
#pragma mark Error handling

- (void)handleError:(NSError *)error {
    // NSLog(@"%s", __FUNCTION__);
    // NSLog(@"error is %@, %@", error, [error domain]);
    NSString *errorMessage = [error localizedDescription];
    
    // errors in NSXMLParserErrorDomain >= 10 are harmless parsing errors
    if ([error domain] == NSXMLParserErrorDomain && [error code] >= 10) {
        alertMessage(@"Cannot parse feed: %@", errorMessage);  // tell the user why parsing is stopped
    } else {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error" message:errorMessage delegate:nil
                                  cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (void)errorAlert:(NSString *) message {
    // NSLog(@"%s", __FUNCTION__);
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"RSS Error" message:message delegate:nil
                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
    [self dismissModalViewControllerAnimated:YES];
}
*/

@end
