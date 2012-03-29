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

@interface TidalClockViewController : UIViewController{
    bool hasReading;
}

@property (strong,nonatomic) TidalReading *reading;
@property (weak, nonatomic) IBOutlet TidalClockView *clock;

-(void)createClockWithReading:(TidalReading *)r;

@end
