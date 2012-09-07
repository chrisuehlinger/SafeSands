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
    double timeLeft = [nextTime timeIntervalSinceNow];
    double angle;
    
    if (timeLeft/3600 >= 6) {
        angle = pi-pi*(timeLeft/tideInterval);
    }else {
        angle = pi-pi*timeLeft/(6*3600);
    }
    
    if([[lastTide objectForKey:@"highlow"] isEqualToString:@"L"])
        angle += pi;
    
    return angle;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //NSLog(@"Rect = %f,%f,%f,%f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    //rect = self.frame;
    CGFloat radius = 75.0;
    CGPoint center = CGPointMake(rect.origin.x + .5*rect.size.width+1,
                                 rect.origin.y + .5*rect.size.height-35);
    
    CALayer *clockFace = [CALayer layer];
    clockFace.frame = CGRectMake(0, -10, 320, 337);
    UIImage *clockImage = [UIImage imageNamed:@"tidalClockLayer.png"];
    clockFace.contents = (id) clockImage.CGImage;
    clockFace.masksToBounds = YES;
    [clockFace setContentsScale:[[UIScreen mainScreen] scale]];
    [self.layer addSublayer:clockFace];
    
    if (hasTide) {
        //NSString *displayFont = @"Helvetica";
    
        /*NSString *marks[] = {@"H", @"5", @"4", @"3", @"2", @"1", @"L", @"5", @"4", @"3", @"2", @"1", nil};
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
        }*/
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"h:mm' 'a"];
        [dateFormatter setLocale:[NSLocale currentLocale]];
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        
        NSString *timeString;
        CGFloat fontSize = 30.0;
        NSLog(@"Last Tide, %@ at %@",[lastTide objectForKey:@"highlow"],  [lastTide objectForKey:@"formattedDate"]);
        NSLog(@"Next Tide, %@ at %@",[nextTide objectForKey:@"highlow"],  [nextTide objectForKey:@"formattedDate"]);
        if([[lastTide objectForKey:@"highlow"] isEqualToString:@"H"])
            timeString = [dateFormatter stringFromDate:[lastTide objectForKey:@"formattedDate"]];
        else
            timeString = [dateFormatter stringFromDate:[nextTide objectForKey:@"formattedDate"]];
        
        CATextLayer *highTimeDisplay = [CATextLayer layer];
        CGFloat highColor[] = {192.0/255.0, 4.0/255.0, 16.0/255.0, 1};
        [highTimeDisplay setBounds:CGRectMake(0, 0, 125, fontSize)];
        [highTimeDisplay setForegroundColor:CGColorCreate(CGColorSpaceCreateDeviceRGB(), highColor)];
        [highTimeDisplay setAlignmentMode:kCAAlignmentCenter];
        [highTimeDisplay setFont:@"GillSans"];
        [highTimeDisplay setFontSize:fontSize];
        [highTimeDisplay setString:timeString];
        [highTimeDisplay setPosition:CGPointMake(center.x, 22)];
        [highTimeDisplay setContentsScale:[[UIScreen mainScreen] scale]];
        [self.layer addSublayer:highTimeDisplay];
        
        if([[lastTide objectForKey:@"highlow"] isEqualToString:@"H"])
            timeString = [dateFormatter stringFromDate:[nextTide objectForKey:@"formattedDate"]] ;
        else
            timeString = [dateFormatter stringFromDate:[lastTide objectForKey:@"formattedDate"]] ;
        
        CATextLayer *lowTimeDisplay = [CATextLayer layer];
        CGFloat lowColor[] = {0, 29.0/255.0, 126.0/255.0, 1};
        [lowTimeDisplay setBounds:CGRectMake(0, 0, 125, fontSize)];
        [lowTimeDisplay setForegroundColor:CGColorCreate(CGColorSpaceCreateDeviceRGB(), lowColor)];
        [lowTimeDisplay setAlignmentMode:kCAAlignmentCenter];
        [lowTimeDisplay setFont:@"GillSans"];
        [lowTimeDisplay setFontSize:fontSize];
        [lowTimeDisplay setString:timeString];
        [lowTimeDisplay setPosition:CGPointMake(center.x, 293)];
        [lowTimeDisplay setContentsScale:[[UIScreen mainScreen] scale]];
        [self.layer addSublayer:lowTimeDisplay];
        
        double angle = [self angleFromDate];
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, center.x-1, center.y+1);
        CGPathAddLineToPoint(path, NULL, center.x+sin(angle)*(radius-5), center.y-cos(angle)*(radius-5));
        CGPathCloseSubpath(path);
        
        CAShapeLayer *hand = [CAShapeLayer layer];
        [hand setBounds:self.bounds];
        [hand setPath:path];
        [hand setLineWidth:4.0];
        [hand setLineCap:kCALineCapRound];
        [hand setPosition:center];
        //CGFloat handFloats[] = {cos(angle), 0, -cos(angle), .4};
        CGFloat handFloats[] = {0, 0, 0, 1};
        [hand setStrokeColor:CGColorCreate(CGColorSpaceCreateDeviceRGB(), handFloats)];
        [self.layer addSublayer:hand];
    }
}

-(void)drawClockWithLastTide:(NSMutableDictionary *)last andNextTide:(NSMutableDictionary *)next
{
    lastTide=last;
    nextTide=next;
    hasTide=YES;
    [super setNeedsDisplay];
    [self setContentMode:UIViewContentModeRedraw];
}


@end
