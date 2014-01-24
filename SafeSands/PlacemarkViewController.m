//
//  PlacemarkViewController.m
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/20/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import "PlacemarkViewController.h"
#import "SandsAppDelegate.h"
#import <QuartzCore/QuartzCore.h>

/*@interface placemarkAnnotation : NSObject<MKAnnotation> {
    CLLocationCoordinate2D coordinate;
    NSString *mTitle;
    NSString *mSubTitle;
}
-(id)initWithCoordinate:(CLPlacemark *)p;
@end

@implementation placemarkAnnotation

@synthesize coordinate;

-(id)initWithCoordinate:(CLPlacemark *)p
{
    coordinate=p.location.coordinate;
    //NSLog(@"%f,%f",c.latitude,c.longitude);
    return self;
}
@end*/

@implementation PlacemarkViewController

@synthesize placemark;
@synthesize mapView;
@synthesize adWhirlView;
@synthesize directionsButton;
@synthesize locationLabel;

NSMutableDictionary *stateAbbrevs;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        stateAbbrevs = [(SandsAppDelegate *)[[UIApplication sharedApplication] delegate] stateAbbrevs];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor: [UIColor colorWithPatternImage:[UIImage imageNamed:@"sandBackground.jpg"]]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adjustAdSize)
                                                 name:@"receivedAd"
                                               object:nil];
    
    placemark = [[(SandsAppDelegate *)[[UIApplication sharedApplication] delegate] currentBeach] placemark];
    
    directionsButton.tintColor = [UIColor colorWithRed:0 green:155.0/255.0 blue:219.0/255.0 alpha:1];
    
    CALayer *locationLayer = [CALayer layer];
    locationLayer.backgroundColor = [UIColor colorWithRed:0 green:155.0/255.0 blue:219.0/255.0 alpha:1].CGColor;
    locationLayer.frame = CGRectMake(20, 10, 280, 40);
    locationLayer.cornerRadius = 10.0;
    [self.view.layer addSublayer:locationLayer];
    
    [locationLabel setText:[NSString stringWithFormat:@"%@, %@", [placemark locality], [stateAbbrevs objectForKey:[placemark administrativeArea]]]];
    [self.view bringSubviewToFront:locationLabel];
    
	
    CGFloat cellWidth = self.view.bounds.size.width - 2*20;
    CGRect frame = CGRectMake(20, 60, cellWidth, directionsButton.frame.origin.y-(10+60));
    mapView = [[MKMapView alloc] initWithFrame:frame];
    MKCoordinateRegion region =  MKCoordinateRegionMakeWithDistance(self.placemark.location.coordinate, 1000, 1000);
    [mapView setRegion:region];
    [mapView setMapType:MKMapTypeHybrid];
    mapView.layer.masksToBounds = YES;
    mapView.layer.cornerRadius = 10.0;
    [mapView.layer setPosition:CGPointMake(frame.origin.x+.5*frame.size.width, frame.origin.y+.5*frame.size.height)];
    [mapView setScrollEnabled:NO];
    [mapView setZoomEnabled:NO];
    [mapView setShowsUserLocation:YES];
    [self.view addSubview:mapView];
}

- (void)viewWillAppear:(BOOL)animated
{
    if([(SandsAppDelegate *)[[UIApplication sharedApplication] delegate] hasAd])
        [self adjustAdSize];
    
    // add a pin using self as the object implementing the MKAnnotation protocol
    [mapView addAnnotation:self];
    NSLog(@"Map Position: [%.0f %.0f]", mapView.layer.position.x, mapView.layer.position.y);
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [self setDirectionsButton:nil];
    [self setLocationLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - AdWhirl methods

-(void)adjustAdSize {
    NSLog(@"%@ is displaying the Ad.", self.navigationItem.title);
    adWhirlView = [(SandsAppDelegate *)[[UIApplication sharedApplication] delegate] adView];
    [self.view addSubview:adWhirlView];
	//1
	[UIView beginAnimations:@"AdResize" context:nil];
	[UIView setAnimationDuration:0.2];
    
    CGRect mapFrame = mapView.frame;
    mapFrame.size.height = mapView.frame.size.width-85;
    [mapView setFrame:mapFrame];
    
    CGRect buttonFrame = directionsButton.frame;
    buttonFrame.origin.y = mapFrame.origin.y+mapFrame.size.height+10;
    [directionsButton setFrame:buttonFrame];
    
    
	//2
	CGSize adSize = [adWhirlView actualAdSize];
	//3
	CGRect newFrame = adWhirlView.frame;
	//4
	newFrame.size.height = adSize.height;
    
   	//5 
    CGSize winSize = self.view.bounds.size;
    //6
	newFrame.size.width = winSize.width;
	//7
	newFrame.origin.x = (self.adWhirlView.bounds.size.width - adSize.width)/2;
    
    //8 
	newFrame.origin.y = (winSize.height - adSize.height);
	//9
	adWhirlView.frame = newFrame;
	//10
	[UIView commitAnimations];
}

- (IBAction)getDirections:(id)sender
{
    CLLocationCoordinate2D start = mapView.userLocation.location.coordinate;
    CLLocationCoordinate2D destination = [self coordinate];        
    
    NSString *googleMapsURLString = [NSString stringWithFormat:@"http://maps.google.com/?saddr=%1.6f,%1.6f&daddr=%1.6f,%1.6f",
                                     start.latitude, start.longitude, destination.latitude, destination.longitude];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:googleMapsURLString]];
}

#pragma mark - MKAnnotation Protocol (for map pin)

- (CLLocationCoordinate2D)coordinate
{
    return self.placemark.location.coordinate;
}

- (NSString *)title
{
    return self.placemark.thoroughfare;
}
@end
