//
//  TidalClockViewController.h
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/28/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TidalReading.h"
#import "TidalClockView.h"
#import "AdWhirlView.h"

@interface TidalClockViewController : UIViewController{
    bool hasReading;
}

@property (strong,nonatomic) TidalReading *reading;
@property (strong, nonatomic) TidalClockView *clock;
@property (strong, nonatomic) AdWhirlView *adWhirlView;

-(void)createClockWithReading:(TidalReading *)r;

@end
