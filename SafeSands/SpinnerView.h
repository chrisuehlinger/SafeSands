//
//  SpinnerView.h
//  SafeSands
//
//  Created by Chris Uehlinger on 4/16/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpinnerView : UIView

+(SpinnerView *)loadSpinnerIntoView:(UIView *)superView;
-(void)removeSpinner;

@end
