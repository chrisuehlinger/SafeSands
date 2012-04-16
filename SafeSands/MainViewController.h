//
//  MainViewController.h
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/9/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Beach.h"
#import "Weather.h"
#import "TidalReading.h"
#import "Alerts.h"
#import "PlacemarkViewController.h"
#import "WeatherViewController.h"
#import "TidalClockViewController.h"
#import "AlertViewController.h"

@interface MainViewController : UIViewController<beachDelegate>

@property (strong, nonatomic) Beach *beach;

@property (weak, nonatomic) IBOutlet UITextView *placemarkDisplay;
@property (weak, nonatomic) IBOutlet UIButton *placemarkButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *placemarkActivityIndicator;
- (IBAction)clickPlacemarkButton:(id)sender;

@property (weak, nonatomic) IBOutlet UITextView *weatherDisplay;
@property (weak, nonatomic) IBOutlet UIButton *weatherButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *weatherActivityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *weatherImageView;


@property (weak, nonatomic) IBOutlet UITextView *tidalDisplay;
@property (weak, nonatomic) IBOutlet UIButton *tidalButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *tidalActivityIndicator;

@property (weak, nonatomic) IBOutlet UITextView *ripTideDisplay;
@property (weak, nonatomic) IBOutlet UIButton *ripTideButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *ripTideActivityIndicator;

@end
