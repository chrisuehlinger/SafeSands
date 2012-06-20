//
//  ViewController.m
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/20/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import "WeatherViewController.h"
#import "SandsAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>

@implementation WeatherViewController

@synthesize weather;
@synthesize uvIndex;

CALayer *rayLayer, *cloud1Layer, *cloud2Layer, *cloud3Layer;
CALayer *oceanBackLayer, *oceanMiddleLayer, *oceanFrontLayer;
CAEmitterLayer* emitter;
NSArray *sunConditions, *cloudConditions, *rainConditions;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor: [UIColor colorWithRed:0 green:1 blue:1 alpha:1]];
    
    weather = [[(SandsAppDelegate *)[[UIApplication sharedApplication] delegate] currentBeach] weather];
    uvIndex = [[(SandsAppDelegate *)[[UIApplication sharedApplication] delegate] currentBeach] uvIndex];
    
    sunConditions = [NSArray arrayWithObjects:@"partly sunny", @"sunny", @"clear", @"mostly sunny", nil];
    //cloudConditions = [NSArray arrayWithObjects:@"overcast", @"partly cloudy", @"mostly cloudy", @"cloudy", @"mist", @"dust", @"fog", @"smoke", @"haze", nil];
    rainConditions = [NSArray arrayWithObjects:@"scattered thunderstorms", @"showers", @"scattered showers", @"rain and snow", @"light snow", @"freezing drizzle", @"chance of rain", @"chance of storm", @"rain", @"chance of snow", @"storm", @"thunderstorm", @"chance of tstorm", @"sleet", @"snow", @"icy", @"flurries", @"light rain", @"snow showers", @"hail", nil];
    
    if([sunConditions containsObject:[[[weather currentConditions] objectForKey:@"condition"] lowercaseString]])
    {
        rayLayer = [CALayer layer];
        rayLayer.frame = CGRectMake(0, 0, 320, 387);
        UIImage *rayImage = [UIImage imageNamed:@"rayLayer.png"];
        rayLayer.contents = (id) rayImage.CGImage;
        rayLayer.masksToBounds = YES;
        [rayLayer setContentsScale:[[UIScreen mainScreen] scale]];
        [self.view.layer addSublayer:rayLayer];
    }else {
        cloud1Layer = [CALayer layer];
        cloud1Layer.frame = CGRectMake(-15, 0, 335, 367);
        UIImage *cloud1Image = [UIImage imageNamed:@"cloud1Layer.png"];
        cloud1Layer.contents = (id) cloud1Image.CGImage;
        cloud1Layer.masksToBounds = YES;
        [cloud1Layer setContentsScale:[[UIScreen mainScreen] scale]];
        cloud1Layer.opacity = 0.75;
        [self.view.layer addSublayer:cloud1Layer];
        
        cloud2Layer = [CALayer layer];
        cloud2Layer.frame = CGRectMake(-15, 0, 335, 367);
        UIImage *cloud2Image = [UIImage imageNamed:@"cloud2Layer.png"];
        cloud2Layer.contents = (id) cloud2Image.CGImage;
        cloud2Layer.masksToBounds = YES;
        [cloud2Layer setContentsScale:[[UIScreen mainScreen] scale]];
        cloud2Layer.opacity = 0.75;
        [self.view.layer addSublayer:cloud2Layer];
        
        cloud3Layer = [CALayer layer];
        cloud3Layer.frame = CGRectMake(-15, 0, 335, 367);
        UIImage *cloud3Image = [UIImage imageNamed:@"cloud3Layer.png"];
        cloud3Layer.contents = (id) cloud3Image.CGImage;
        cloud3Layer.masksToBounds = YES;
        [cloud3Layer setContentsScale:[[UIScreen mainScreen] scale]];
        cloud3Layer.opacity = 0.75;
        [self.view.layer addSublayer:cloud3Layer];
        
    }
    
    CALayer *sunLayer = [CALayer layer];
    sunLayer.frame = CGRectMake(0, 0, 320, 387);
    UIImage *sunImage = [UIImage imageNamed:@"sunLayer.png"];
    sunLayer.contents = (id) sunImage.CGImage;
    sunLayer.masksToBounds = YES;
    [sunLayer setContentsScale:[[UIScreen mainScreen] scale]];
    [self.view.layer addSublayer:sunLayer];
    
    oceanBackLayer = [CALayer layer];
    oceanBackLayer.frame = CGRectMake(-15, 0, 335, 367);
    UIImage *oceanBackImage = [UIImage imageNamed:@"oceanBackLayer.png"];
    oceanBackLayer.contents = (id) oceanBackImage.CGImage;
    oceanBackLayer.masksToBounds = YES;
    [oceanBackLayer setContentsScale:[[UIScreen mainScreen] scale]];
    [self.view.layer addSublayer:oceanBackLayer];
    
    oceanMiddleLayer = [CALayer layer];
    oceanMiddleLayer.frame = CGRectMake(-15, 0, 335, 367);
    UIImage *oceanMiddleImage = [UIImage imageNamed:@"oceanMiddleLayer.png"];
    oceanMiddleLayer.contents = (id) oceanMiddleImage.CGImage;
    oceanMiddleLayer.masksToBounds = YES;
    [oceanMiddleLayer setContentsScale:[[UIScreen mainScreen] scale]];
    [self.view.layer addSublayer:oceanMiddleLayer];
    
    oceanFrontLayer = [CALayer layer];
    oceanFrontLayer.frame = CGRectMake(-15, 0, 335, 367);
    UIImage *oceanFrontImage = [UIImage imageNamed:@"oceanFrontLayer.png"];
    oceanFrontLayer.contents = (id) oceanFrontImage.CGImage;
    oceanFrontLayer.masksToBounds = YES;
    [oceanFrontLayer setContentsScale:[[UIScreen mainScreen] scale]];
    [self.view.layer addSublayer:oceanFrontLayer];
    
    CALayer *beachLayer = [CALayer layer];
    beachLayer.frame = CGRectMake(0, 15, 320, 367);
    UIImage *beachImage = [UIImage imageNamed:@"beachLayer.png"];
    beachLayer.contents = (id) beachImage.CGImage;
    beachLayer.masksToBounds = YES;
    [beachLayer setContentsScale:[[UIScreen mainScreen] scale]];
    [self.view.layer addSublayer:beachLayer];
    
    CALayer *waterTempLayer = [CALayer layer];
    waterTempLayer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6].CGColor;
    waterTempLayer.shadowOffset = CGSizeMake(0, 3);
    waterTempLayer.frame = CGRectMake(10, 260, 120, 25);
    waterTempLayer.cornerRadius = 10.0;
    [self.view.layer addSublayer:waterTempLayer];
    
    CALayer *forecastLayer = [CALayer layer];
    forecastLayer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6].CGColor;
    forecastLayer.shadowOffset = CGSizeMake(0, 3);
    forecastLayer.frame = CGRectMake(175, 110, 120, 40);
    forecastLayer.cornerRadius = 10.0;
    [self.view.layer addSublayer:forecastLayer];
    
    CALayer *airTempLayer = [CALayer layer];
    airTempLayer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6].CGColor;
    airTempLayer.shadowOffset = CGSizeMake(0, 3);
    airTempLayer.frame = CGRectMake(190, 290, 100, 45);
    airTempLayer.cornerRadius = 10.0;
    [self.view.layer addSublayer:airTempLayer];
    
    CALayer *uvIndexLayer = [CALayer layer];
    uvIndexLayer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6].CGColor;
    uvIndexLayer.shadowOffset = CGSizeMake(0, 3);
    uvIndexLayer.frame = CGRectMake(10, 15, 120, 25);
    uvIndexLayer.cornerRadius = 10.0;
    [self.view.layer addSublayer:uvIndexLayer];
}

-(void)viewDidAppear:(BOOL)animated
{
    if([sunConditions containsObject:[[[weather currentConditions] objectForKey:@"condition"] lowercaseString]])
    {
        // create the animation that will handle the pulsing.
        CABasicAnimation* pulseAnimation = [CABasicAnimation animation];
        pulseAnimation.keyPath = @"opacity";
        pulseAnimation.fromValue = [NSNumber numberWithFloat: 0.0];
        pulseAnimation.toValue = [NSNumber numberWithFloat: 1.0];
        pulseAnimation.duration = 3.0;
        pulseAnimation.repeatCount = HUGE_VALF;
        pulseAnimation.autoreverses = YES;
        pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseOut];
        [rayLayer addAnimation:pulseAnimation forKey:@"pulseAnimation"];
    }else {
        CABasicAnimation *cloud1Animation = [CABasicAnimation animation];
        [cloud1Animation setKeyPath:@"position.x"];
        [cloud1Animation setFromValue:[NSNumber numberWithInt:cloud1Layer.position.x-5]];
        [cloud1Animation setToValue:[NSNumber numberWithInt:cloud1Layer.position.x+4]];
        [cloud1Animation setDuration: 3.5];
        [cloud1Animation setRepeatCount:HUGE_VALF];
        [cloud1Animation setAutoreverses:YES];
        [cloud1Animation setTimingFunction:[CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
        [cloud1Layer addAnimation:cloud1Animation forKey:@"animateCloud1"];
        
        CABasicAnimation *cloud2Animation = [CABasicAnimation animation];
        [cloud2Animation setKeyPath:@"position.x"];
        [cloud2Animation setFromValue:[NSNumber numberWithInt:cloud2Layer.position.x-5]];
        [cloud2Animation setToValue:[NSNumber numberWithInt:cloud2Layer.position.x+5]];
        [cloud2Animation setDuration: 4.0];
        [cloud2Animation setRepeatCount:HUGE_VALF];
        [cloud2Animation setAutoreverses:YES];
        [cloud2Animation setTimingFunction:[CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
        [cloud2Layer addAnimation:cloud2Animation forKey:@"animateCloud2"];
        
        CABasicAnimation *cloud3Animation = [CABasicAnimation animation];
        [cloud3Animation setKeyPath:@"position.x"];
        [cloud3Animation setFromValue:[NSNumber numberWithInt:cloud3Layer.position.x-4]];
        [cloud3Animation setToValue:[NSNumber numberWithInt:cloud3Layer.position.x+5]];
        [cloud3Animation setDuration: 4.5];
        [cloud3Animation setRepeatCount:HUGE_VALF];
        [cloud3Animation setAutoreverses:YES];
        [cloud3Animation setTimingFunction:[CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
        [cloud3Layer addAnimation:cloud3Animation forKey:@"animateCloud3"];
        
        if ([rainConditions containsObject:[[[weather currentConditions] objectForKey:@"condition"] lowercaseString]]) 
        {
            
            emitter = [CAEmitterLayer layer];
            emitter.emitterPosition = CGPointMake(230, 75);
            emitter.emitterMode = kCAEmitterLayerLine;
            emitter.emitterShape = kCAEmitterLayerLine;
            emitter.emitterSize = CGSizeMake(125, 0);
            
            //Create the emitter cell
            CAEmitterCell* rain1 = [CAEmitterCell emitterCell];
            rain1.emissionLongitude = 1.15*M_PI;
            rain1.birthRate = 20;
            rain1.lifetime = 1;
            rain1.lifetimeRange = 0.5;
            rain1.velocity = 50;
            rain1.velocityRange = 10;
            rain1.emissionRange = .1*M_PI;
            rain1.scaleSpeed = 0.25; // was 0.3
            rain1.color = [[UIColor colorWithRed:0.1 green:0.1 blue:.5 alpha:.5] CGColor];
            rain1.contents = (id)([UIImage imageNamed:@"rain1.png"].CGImage);
            rain1.name = @"particle";
            
            emitter.emitterCells = [NSArray arrayWithObject:rain1];
            [emitter setZPosition: -10];
            [self.view.layer addSublayer:emitter];
        }
    }

    CABasicAnimation *oceanBackAnimation = [CABasicAnimation animation];
    [oceanBackAnimation setKeyPath:@"position.x"];
    [oceanBackAnimation setFromValue:[NSNumber numberWithInt:oceanBackLayer.position.x-5]];
    [oceanBackAnimation setToValue:[NSNumber numberWithInt:oceanBackLayer.position.x+5]];
    [oceanBackAnimation setDuration: 4.0];
    [oceanBackAnimation setRepeatCount:HUGE_VALF];
    [oceanBackAnimation setAutoreverses:YES];
    [oceanBackLayer addAnimation:oceanBackAnimation forKey:@"animateOceanBack"];
    
    CABasicAnimation *oceanMiddleAnimation = [CABasicAnimation animation];
    [oceanMiddleAnimation setKeyPath:@"position.x"];
    [oceanMiddleAnimation setFromValue:[NSNumber numberWithInt:oceanMiddleLayer.position.x+5]];
    [oceanMiddleAnimation setToValue:[NSNumber numberWithInt:oceanMiddleLayer.position.x-5]];
    [oceanMiddleAnimation setDuration: 4.0];
    [oceanMiddleAnimation setRepeatCount:HUGE_VALF];
    [oceanMiddleAnimation setAutoreverses:YES];
    [oceanMiddleLayer addAnimation:oceanMiddleAnimation forKey:@"animateOceanMiddle"];    
    
    CABasicAnimation *oceanFrontAnimation = [CABasicAnimation animation];
    [oceanFrontAnimation setKeyPath:@"position.x"];
    [oceanFrontAnimation setFromValue:[NSNumber numberWithInt:oceanFrontLayer.position.x-4]];
    [oceanFrontAnimation setToValue:[NSNumber numberWithInt:oceanFrontLayer.position.x+4]];
    [oceanFrontAnimation setDuration: 4.0];
    [oceanFrontAnimation setRepeatCount:HUGE_VALF];
    [oceanFrontAnimation setAutoreverses:YES];
    [oceanFrontLayer addAnimation:oceanFrontAnimation forKey:@"animateOceanFront"];
    
    NSString *weatherText = [[NSString alloc] initWithFormat:@"Forecast:\n%@", [[weather currentConditions] objectForKey:@"condition"]];
    
    CATextLayer *weatherTextLayer = [CATextLayer layer];
    [weatherTextLayer setForegroundColor:[[UIColor whiteColor] CGColor]];
    [weatherTextLayer setString:weatherText];
    [weatherTextLayer setFrame:CGRectMake(180, 115, 110, 40)];
    [weatherTextLayer setAlignmentMode:kCAAlignmentCenter];
    [weatherTextLayer setFont:@"Helvetica"];
    [weatherTextLayer setFontSize:18];
    [weatherTextLayer setContentsScale:[[UIScreen mainScreen] scale]];
    [self.view.layer addSublayer:weatherTextLayer];
    [weatherTextLayer setZPosition:1];
    
    NSString *uvIndexText = [[NSString alloc] initWithFormat:@"UV Index: %d", [[uvIndex index] intValue]];
    //if ([uvIndex uvAlert])
    //    uvIndexText = [uvIndexText stringByAppendingFormat:@"Warning: UV Alert!\n"];
    
    CATextLayer *uvIndexTextLayer = [CATextLayer layer];
    [uvIndexTextLayer setForegroundColor:[[UIColor whiteColor] CGColor]];
    [uvIndexTextLayer setString:uvIndexText];
    [uvIndexTextLayer setFrame:CGRectMake(15, 20, 110, 30)];
    [uvIndexTextLayer setAlignmentMode:kCAAlignmentCenter];
    [uvIndexTextLayer setFont:@"Helvetica"];
    [uvIndexTextLayer setFontSize:18];
    [uvIndexTextLayer setContentsScale:[[UIScreen mainScreen] scale]];
    [self.view.layer addSublayer:uvIndexTextLayer];
    [uvIndexTextLayer setZPosition:1];
    
    NSString *waterTempText = [[NSString alloc] initWithString:@"Water:"];
    NSString *airTempText = [[NSString alloc] initWithString:@"High:"];
    int highTemp = [[[[weather forecastConditions] objectAtIndex:0] objectForKey:@"high"] intValue];
    int lowTemp = [[[[weather forecastConditions] objectAtIndex:0] objectForKey:@"low"] intValue];
    
    if ([[[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem] boolValue]) 
    {
        waterTempText = [waterTempText stringByAppendingFormat:@"%d°C", [[[weather waterTemp] tempC] intValue]];
        
        highTemp = (highTemp-32)*5/9;
        lowTemp = (lowTemp-32)*5/9;
        
        airTempText = [airTempText stringByAppendingFormat:@"%d°C\nLow: %d°C", highTemp, lowTemp];
    }else
    {
        waterTempText = [waterTempText stringByAppendingFormat:@"%d°F", [[[weather waterTemp] tempF] intValue]];
        airTempText = [airTempText stringByAppendingFormat:@"%d°F\nLow: %d°F", highTemp, lowTemp];
    }

    CATextLayer *waterTempTextLayer = [CATextLayer layer];
    [waterTempTextLayer setForegroundColor:[[UIColor whiteColor] CGColor]];
    [waterTempTextLayer setString:waterTempText];
    [waterTempTextLayer setFrame:CGRectMake(15, 265, 110, 25)];
    [waterTempTextLayer setAlignmentMode:kCAAlignmentCenter];
    [waterTempTextLayer setFont:@"Helvetica"];
    [waterTempTextLayer setFontSize:18];
    [waterTempTextLayer setContentsScale:[[UIScreen mainScreen] scale]];
    [self.view.layer addSublayer:waterTempTextLayer];
    [waterTempTextLayer setZPosition:1];
    
    CATextLayer *airTempTextLayer = [CATextLayer layer];
    [airTempTextLayer setForegroundColor:[[UIColor whiteColor] CGColor]];
    [airTempTextLayer setString:airTempText];
    [airTempTextLayer setFrame:CGRectMake(195, 295, 90, 40)];
    [airTempTextLayer setAlignmentMode:kCAAlignmentCenter];
    [airTempTextLayer setFont:@"Helvetica"];
    [airTempTextLayer setFontSize:18];
    [airTempTextLayer setContentsScale:[[UIScreen mainScreen] scale]];
    [self.view.layer addSublayer:airTempTextLayer];
    [airTempTextLayer setZPosition:1];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
