//
//  TidalClockView.h
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/28/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TidalClockView : UIView{
    bool hasTide;
}

@property (strong, nonatomic) NSMutableDictionary *lastTide;
@property (strong, nonatomic) NSMutableDictionary *nextTide;

-(void)drawClockWithLastTide:(NSMutableDictionary *)last andNextTide:(NSMutableDictionary *)next;

@end
