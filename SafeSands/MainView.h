//
//  MainView.h
//  SafeSands
//
//  Created by Christopher Uehlinger on 4/16/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface MainView : UIView{
    CALayer *mainLayer;
}

-(void)drawPlacemark;
-(void)animateChange;

@end
