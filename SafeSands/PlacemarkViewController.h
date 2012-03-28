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

@interface PlacemarkViewController : UIViewController

@property (strong, nonatomic) CLPlacemark *placemark;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end
