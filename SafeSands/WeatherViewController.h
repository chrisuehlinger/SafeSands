//
//  ViewController.h
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/20/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Weather.h"
#import "UVIndex.h"

@interface WeatherViewController : UIViewController

@property (strong, nonatomic) Weather *weather;
@property (strong, nonatomic) UVIndex *uvIndex;



@end
