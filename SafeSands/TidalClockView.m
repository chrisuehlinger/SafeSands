//
//  TidalClockView.m
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/28/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import "TidalClockView.h"

@implementation TidalClockView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Get the graphics context and clear it
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextClearRect(ctx, rect);
    
    // Draw a green solid circle
    CGContextSetRGBFillColor(ctx, 0, 255, 0, 1);
    CGContextFillEllipseInRect(ctx, CGRectMake(100, 100, 25, 25));
    
}


@end
