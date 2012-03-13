//
//  MainViewController.m
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/9/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import "MainViewController.h"

@implementation MainViewController
@synthesize locationDisplay, locationText, locationManager, geocoder, weatherConnection, weatherData;
@synthesize currentParseBatch, currentParsedCharacterData, currentItemObject, currentFeedObject;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self locationDisplay] setText:@"Finding Location..."];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    geocoder = [[CLGeocoder alloc] init];
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    if(locationText == nil)
    {
        [locationManager startMonitoringSignificantLocationChanges];
    }else {
        [geocoder geocodeAddressString:locationText completionHandler:^(NSArray *placemarks, NSError *error)
         {
             dispatch_async(dispatch_get_main_queue(), ^{ [self haveLocation:[placemarks objectAtIndex:0]];});
         }];
        
    }
}

- (void)viewDidUnload
{
    [self setLocationDisplay:nil];
    [[self locationDisplay] setText:@" "];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [locationManager stopMonitoringSignificantLocationChanges];
    [geocoder cancelGeocode];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - retrieve Weather

- (void) retrieveWeather:(CLPlacemark *)thePlacemark
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSURLRequest *weatherRequest = [NSURLRequest requestWithURL:[NSURL URLWithString: [NSString stringWithFormat: @"http://www.google.com/ig/api?weather=%@", [thePlacemark postalCode]]]];
    weatherConnection = [[NSURLConnection alloc] initWithRequest:weatherRequest delegate:self];
    NSAssert(weatherConnection != nil, @"Could not establish connection");
}

- (void)parseWeatherData:(NSData *)data {
    
    self.currentParseBatch = [NSMutableArray array];
    self.currentParsedCharacterData = [NSMutableString string];
    parsedItemsCounter = 0;
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    [parser parse];
    
    // depending on the total number of items parsed, the last batch might not have been a "full" batch, and thus
    // not been part of the regular batch transfer. So, we check the count of the array and, if necessary, send it to the main thread.
    /*if ([self.currentParseBatch count] > 0) {
        [self performSelectorOnMainThread:@selector(updateDBWithItems:) withObject:self.currentParseBatch waitUntilDone:NO];
    }*/
    self.currentParseBatch = nil;
    self.currentItemObject = nil;
    self.currentFeedObject = nil;
    self.currentParsedCharacterData = nil;
}

- (void) haveLocation:(CLPlacemark *)thePlacemark
{
    [self.geocoder reverseGeocodeLocation:[thePlacemark location] completionHandler:^(NSArray *placemarks, NSError *error)
     {
        CLPlacemark *newPlacemark = [placemarks objectAtIndex:0];
        dispatch_async(dispatch_get_main_queue(), ^{
             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
             [locationDisplay setText: [NSString stringWithFormat: @"%@ %f, %f", [newPlacemark postalCode], [newPlacemark location].coordinate.latitude, [newPlacemark location].coordinate.longitude]];
             [self retrieveWeather: newPlacemark];
         });
     }];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [manager stopMonitoringSignificantLocationChanges];
    [self.geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         dispatch_async(dispatch_get_main_queue(), ^{ [self haveLocation:[placemarks objectAtIndex:0]];});
     }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [locationDisplay setText: @"Failed to find Current Location"];
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

#pragma -
#pragma mark Parser constants

// Limit the number of parsed items to 50.
static NSUInteger const kMaximumNumberOfItemsToParse = 50;

// Number of items in a parse batch
static NSUInteger const kSizeOfItemsBatch = 10;

// Reduce potential parsing errors by using string constants declared in a single place.
static NSString * const kChannelElementName = @"channel";
static NSString * const kItemElementName = @"item";
static NSString * const kDescriptionElementName = @"description";
static NSString * const kLinkElementName = @"link";
static NSString * const kTitleElementName = @"title";
static NSString * const kUpdatedElementName = @"pubDate";
static NSString * const kDCDateElementName = @"dc:date";

#pragma mark -
#pragma mark NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    NSLog(@"%s %@", __FUNCTION__, elementName);
    
    NSArray * containerElements = [NSArray arrayWithObjects: @"city", @"postal_code", nil];
    
    // If the number of parsed items is greater than kMaximumNumberOfItemsToParse, abort the parse.
    if (parsedItemsCounter >= kMaximumNumberOfItemsToParse) {
        // Use didAbortParsing flag to distinguish between this real parser errors.
        didAbortParsing = YES;
        [parser abortParsing];
    }
    if ([elementName isEqualToString:@"forecast_information"]) {
        NSMutableDictionary *forecast_info = [[NSMutableDictionary alloc] init];
        self.currentFeedObject = forecast_info;
        self.currentItemObject = forecast_info;   // shortcut so parser can treat it the same
    }
    if ([containerElements containsObject:elementName]) {
        /*accumulatingParsedCharacterData = YES;
        // reset character accumulator
        [currentParsedCharacterData setString:@""];*/
NSLog(@"%@: %@", elementName, [attributeDict objectForKey:@"data"]);
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
