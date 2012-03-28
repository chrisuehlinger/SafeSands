//
//  PlacemarkViewController.m
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/20/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import "PlacemarkViewController.h"

@interface placemarkAnnotation : NSObject<MKAnnotation> {
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
@end

@implementation PlacemarkViewController

@synthesize placemark;
@synthesize mapView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [mapView setVisibleMapRect:MKMapRectMake(0, 0, 100, 100) animated:YES];
    [mapView setCenterCoordinate:placemark.location.coordinate animated:YES];
    [mapView addAnnotation:[[placemarkAnnotation alloc]initWithCoordinate:placemark]];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
