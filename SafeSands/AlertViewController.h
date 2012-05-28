//
//  AlertViewController.h
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/30/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Alerts.h"

@interface AlertViewController : UIViewController <UIScrollViewDelegate> {
    Alerts *alerts;
    BOOL pageControlUsed;
}

@property (strong, nonatomic) Alerts *alerts;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIPageControl *pageControl;

-(void)setUpScrollView:(Alerts *)a;

@end
