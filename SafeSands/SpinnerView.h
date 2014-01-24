//
//  SpinnerView.h
//  SafeSands
//
//  Created by Chris Uehlinger on 4/16/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface SpinnerView : UIView

@property (strong, nonatomic) CATextLayer *loadingLabel;

+(SpinnerView *)loadSpinnerIntoView:(UIView *)superView withLoadingText:(NSString *)loadingText;
+(SpinnerView *)loadSpinnerIntoView:(UIView *)superView;
-(void)removeSpinner;

@end
