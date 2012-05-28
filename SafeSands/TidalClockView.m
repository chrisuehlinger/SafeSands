//
//  TidalClockView.m
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/28/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import "TidalClockView.h"
#import <QuartzCore/QuartzCore.h>

@implementation TidalClockView

@synthesize lastTide;
@synthesize nextTide;

static double pi = 3.14159268;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        hasTide=NO;
    }
    return self;
}

-(double)angleFromDate
{
    NSDate *lastTime = [lastTide objectForKey:@"formattedDate"];
    NSDate *nextTime = [nextTide objectForKey:@"formattedDate"];
    double tideInterval = [nextTime timeIntervalSinceDate:lastTime];
    double timePassed = -1*[lastTime timeIntervalSinceNow];
    
    double angle = pi*(timePassed/tideInterval);
    if([[lastTide objectForKey:@"highlow"] isEqualToString:@"L"])
        angle += pi;
    
    /*NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDate *now = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
    [dateFormatter setDateFormat:@"hh:mm:ss"];
    NSArray *timeArray = [[dateFormatter stringFromDate:now] componentsSeparatedByString: @":"];
    double time = [[timeArray objectAtIndex:2] doubleValue];
    time = 2.0*pi*(time/60.0);*/
    
    return angle;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGFloat radius = 100.0;
    CGPoint center = CGPointMake(rect.origin.x + .5*rect.size.width,
                                 rect.origin.y + .5*rect.size.height);
    
    CAGradientLayer *clockFace = [CALayer layer];
    [clockFace setMasksToBounds:YES];
    [clockFace setBackgroundColor: [[UIColor lightGrayColor] CGColor]];
    [clockFace setCornerRadius:radius ];
    [clockFace setBounds:CGRectMake(0, 0, radius *2, radius *2)];
    [clockFace setPosition:center];
    [self.layer addSublayer:clockFace];
    
    if (hasTide) {
        //NSString *displayFont = @"Helvetica";
        CGFloat fontSize = 24.0;
    
        NSString *marks[] = {@"H", @"5", @"4", @"3", @"2", @"1", @"L", @"5", @"4", @"3", @"2", @"1", nil};
        int i;
        for (i=0; i<12; i++) {
            double angle = 2.0*pi*(i/12.0);
            CATextLayer *mark = [CATextLayer layer];
            CGFloat colorFloats[] = {cos(angle), 0, -cos(angle), 1};
            [mark setBounds:CGRectMake(0, 0, fontSize, fontSize)];
            [mark setForegroundColor:CGColorCreate(CGColorSpaceCreateDeviceRGB(), colorFloats)];
            [mark setAlignmentMode:kCAAlignmentCenter];
            [mark setFont:@"Helvetica"];
            [mark setFontSize:fontSize];
            [mark setString:marks[i]];
            [mark setPosition:CGPointMake(center.x+sin(angle)*(radius-.5*fontSize), center.y-cos(angle)*(radius-.6*fontSize))];
            [mark setContentsScale:[[UIScreen mainScreen] scale]];
            [self.layer addSublayer:mark];
        }
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"h:mm' 'a"];
        [dateFormatter setLocale:[NSLocale currentLocale]];
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        
        NSString *timeString;
        fontSize = 30.0;
        if([[lastTide objectForKey:@"highlow"] isEqualToString:@"H"])
            timeString = [dateFormatter stringFromDate:[lastTide objectForKey:@"formattedDate"]];
        else
            timeString = [dateFormatter stringFromDate:[nextTide objectForKey:@"formattedDate"]];
        
        CATextLayer *highTimeDisplay = [CATextLayer layer];
        CGFloat highColor[] = {1, 0, 0, 1};
        [highTimeDisplay setBounds:CGRectMake(0, 0, 150, fontSize)];
        [highTimeDisplay setForegroundColor:CGColorCreate(CGColorSpaceCreateDeviceRGB(), highColor)];
        [highTimeDisplay setAlignmentMode:kCAAlignmentCenter];
        [highTimeDisplay setFont:@"Helvetica"];
        [highTimeDisplay setFontSize:fontSize];
        [highTimeDisplay setString:timeString];
        [highTimeDisplay setPosition:CGPointMake(center.x, center.y-(radius+.6*fontSize))];
        [highTimeDisplay setContentsScale:[[UIScreen mainScreen] scale]];
        [self.layer addSublayer:highTimeDisplay];
        
        if([[nextTide objectForKey:@"highlow"] isEqualToString:@"L"])
            timeString = [dateFormatter stringFromDate:[nextTide objectForKey:@"formattedDate"]] ;
        else
            timeString = [dateFormatter stringFromDate:[lastTide objectForKey:@"formattedDate"]] ;
        
        CATextLayer *lowTimeDisplay = [CATextLayer layer];
        CGFloat lowColor[] = {0, 0, 1, 1};
        [lowTimeDisplay setBounds:CGRectMake(0, 0, 150, fontSize)];
        [lowTimeDisplay setForegroundColor:CGColorCreate(CGColorSpaceCreateDeviceRGB(), lowColor)];
        [lowTimeDisplay setAlignmentMode:kCAAlignmentCenter];
        [lowTimeDisplay setFont:@"Helvetica"];
        [lowTimeDisplay setFontSize:fontSize];
        [lowTimeDisplay setString:timeString];
        [lowTimeDisplay setPosition:CGPointMake(center.x, center.y+(radius+.6*fontSize))];
        [lowTimeDisplay setContentsScale:[[UIScreen mainScreen] scale]];
        [self.layer addSublayer:lowTimeDisplay];
        
        double angle = [self angleFromDate];
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, center.x, center.y);
        CGPathAddLineToPoint(path, NULL, center.x+sin(angle)*(radius-5), center.y-cos(angle)*(radius-5));
        CGPathCloseSubpath(path);
        
        CAShapeLayer *hand = [CAShapeLayer layer];
        [hand setBounds:CGRectMake(center.x-radius, center.y-radius, 2*radius, 2*radius)];
        [hand setPath:path];
        [hand setLineWidth:4.0];
        [hand setLineCap:kCALineCapRound];
        [hand setPosition:center];
        CGFloat handFloats[] = {cos(angle), 0, -cos(angle), .4};
        [hand setStrokeColor:CGColorCreate(CGColorSpaceCreateDeviceRGB(), handFloats)];
        [self.layer addSublayer:hand];
    }
}

-(void)drawClockWithLastTide:(NSMutableDictionary *)last andNextTide:(NSMutableDictionary *)next
{
    lastTide=last;
    nextTide=next;
    hasTide=YES;
    [self setNeedsDisplay];
}


@end
