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
@synthesize weatherConnection;
@synthesize weatherData;

@synthesize currentItemObject;

@synthesize forecastInfo;
@synthesize currentConditions;
@synthesize forecastConditions;

-(id)initWithPlacemark:(CLPlacemark *)placemark
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    forecastConditions = [[NSMutableArray alloc] init];
    containerElements = [NSArray arrayWithObjects: @"forecast_information", @"current_conditions", @"forecast_conditions", nil];
    fieldElements = [NSArray arrayWithObjects: @"city", @"postal_code", @"current_date_time", 
                               @"condition", @"temp_f", @"temp_c", @"humidity", @"icon", @"wind_condition", 
                               @"day_of_week", @"low", @"high", nil];
    NSURLRequest *weatherRequest = [NSURLRequest requestWithURL:[NSURL URLWithString: [NSString stringWithFormat: @"http://www.google.com/ig/api?weather=%@", [placemark postalCode]]]];
    weatherConnection = [[NSURLConnection alloc] initWithRequest:weatherRequest delegate:self];
    NSAssert(weatherConnection != nil, @"Could not establish connection");
    return self;
}

-(void)parseWeatherData:(NSData *)data {
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    [parser parse];
}

#pragma mark -
#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    if(!weatherData) weatherData = [[NSMutableData alloc] init];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.weatherData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self setWeatherConnection:nil];
    
    NSLog(@"Have data, %d bytes", weatherData.length);
    [NSThread detachNewThreadSelector:@selector(parseWeatherData:) toTarget:self withObject:weatherData];
    
    
    [self setWeatherData:nil];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self setWeatherConnection:nil];
    
    NSLog(@"Uh oh! Error!");
    
    [self setWeatherData:nil];
    
}

#pragma mark -
#pragma mark NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    //NSLog(@"%s %@", __FUNCTION__, elementName);

    if ([containerElements containsObject:elementName]) {
        self.currentItemObject = [[NSMutableDictionary alloc] init]; 
    }
    
    if ([fieldElements containsObject:elementName]) {
        //NSLog(@"%@: %@", elementName, [attributeDict objectForKey:@"data"]);
        [[self currentItemObject] setObject:[attributeDict objectForKey:@"data"] forKey:elementName];
    }
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([containerElements containsObject:elementName]) {
        if ([elementName isEqualToString:@"forecast_information"]) forecastInfo = self.currentItemObject;
        if ([elementName isEqualToString:@"current_conditions"]) currentConditions = self.currentItemObject;
        if ([elementName isEqualToString:@"forecast_conditions"]) [forecastConditions addObject: self.currentItemObject];
        self.currentItemObject = nil;
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    NSString *outText = [NSString stringWithFormat:@"Weather\n"];
    outText = [outText stringByAppendingFormat:@"\tforecastInfo\n"];
    for (NSString *key in forecastInfo) {
        outText = [outText stringByAppendingFormat:@"\t\t%@\t%@\n", key, [forecastInfo objectForKey:key]];
    }
    outText = [outText stringByAppendingFormat:@"\tcurrentConditions\n"];
    for (NSString *key in currentConditions) {
        outText = [outText stringByAppendingFormat:@"\t\t%@\t%@\n", key, [currentConditions objectForKey:key]];
    }
    for (NSDictionary *foreCond in forecastConditions) {
        outText = [outText stringByAppendingFormat:@"\tforecastConditions\n"];
        for (NSString *key in foreCond) {
            outText = [outText stringByAppendingFormat:@"\t\t%@\t%@\n", key, [foreCond objectForKey:key]];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{[delegate upDateText:outText];});
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    // We abort parsing if we get more than kMaximumNumberOfItemsToParse. 
    // We use the didAbortParsing flag to avoid treating this as an error. 
    /*if (didAbortParsing == NO) {
        // Pass the error to the main thread for handling.
        [self performSelectorOnMainThread:@selector(handleError:) withObject:parseError waitUntilDone:NO];
    }*/
}

#pragma mark -
#pragma mark Date parsing methods

/*-(NSString *) dateToLocalizedString:(NSDate *) date {
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
 }*/

@end
