//
//  PlacemarkViewController.h
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/20/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AdWhirlView.h"

@interface PlacemarkViewController : UIViewController<MKAnnotation>

@property (strong, nonatomic) CLPlacemark *placemark;
@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) AdWhirlView *adWhirlView;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *directionsButton;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *locationLabel;

- (IBAction)getDirections:(id)sender;
@end
