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

@interface MainViewController : UIViewController<beachDelegate>

@property (strong, nonatomic) Beach *beach;

@property (weak, nonatomic) IBOutlet UITextView *beachDisplay;
@property (strong, nonatomic) NSString *locationText;
@end
