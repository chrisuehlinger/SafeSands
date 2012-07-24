//
//  AlertViewController.h
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/30/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Alerts.h"
#import "AdWhirlView.h"

@interface AlertViewController : UIViewController <UIScrollViewDelegate> {
    Alerts *alerts;
    BOOL pageControlUsed;
}

@property (strong, nonatomic) Alerts *alerts;
@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, unsafe_unretained) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) AdWhirlView *adWhirlView;

-(void)setUpScrollView:(Alerts *)a;

@end
