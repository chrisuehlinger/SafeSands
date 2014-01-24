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
@synthesize adWhirlView;

CALayer *rayLayer, *cloud1Layer, *cloud2Layer, *cloud3Layer;
CALayer *oceanBackLayer, *oceanMiddleLayer, *oceanFrontLayer;
CAEmitterLayer* emitter;
NSString *displayCondition;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adjustAdSize)
                                                 name:@"receivedAd"
                                               object:nil];
    
    [self.view setBackgroundColor: [UIColor colorWithRed:0 green:1 blue:1 alpha:1]];
    
    weather = [[(SandsAppDelegate *)[[UIApplication sharedApplication] delegate] currentBeach] weather];
    uvIndex = [[(SandsAppDelegate *)[[UIApplication sharedApplication] delegate] currentBeach] uvIndex];
    
    displayCondition= [self determineDisplayWeather:[[weather currentConditions] objectForKey:@"weather"]];
    
    
    if([displayCondition isEqualToString:@"Sunny"])
    {
        rayLayer = [CALayer layer];
        rayLayer.frame = CGRectMake(0, 0, 320, 387);
        UIImage *rayImage = [UIImage imageNamed:@"rayLayer.png"];
        rayLayer.contents = (id) rayImage.CGImage;
        rayLayer.masksToBounds = YES;
        [rayLayer setContentsScale:[[UIScreen mainScreen] scale]];
        [self.view.layer addSublayer:rayLayer];
    }else if([displayCondition isEqualToString:@"Cloudy"] || [displayCondition isEqualToString:@"Rainy"]){
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
    oceanBackLayer.frame = CGRectMake(-15, 0, 350, 367);
    UIImage *oceanBackImage = [UIImage imageNamed:@"oceanBackLayer.png"];
    oceanBackLayer.contents = (id) oceanBackImage.CGImage;
    oceanBackLayer.masksToBounds = YES;
    [oceanBackLayer setContentsScale:[[UIScreen mainScreen] scale]];
    [self.view.layer addSublayer:oceanBackLayer];
    
    oceanMiddleLayer = [CALayer layer];
    oceanMiddleLayer.frame = CGRectMake(-15, 0, 350, 367);
    UIImage *oceanMiddleImage = [UIImage imageNamed:@"oceanMiddleLayer.png"];
    oceanMiddleLayer.contents = (id) oceanMiddleImage.CGImage;
    oceanMiddleLayer.masksToBounds = YES;
    [oceanMiddleLayer setContentsScale:[[UIScreen mainScreen] scale]];
    [self.view.layer addSublayer:oceanMiddleLayer];
    
    oceanFrontLayer = [CALayer layer];
    oceanFrontLayer.frame = CGRectMake(-15, 0, 350, 367);
    UIImage *oceanFrontImage = [UIImage imageNamed:@"oceanFrontLayer.png"];
    oceanFrontLayer.contents = (id) oceanFrontImage.CGImage;
    oceanFrontLayer.masksToBounds = YES;
    [oceanFrontLayer setContentsScale:[[UIScreen mainScreen] scale]];
    [self.view.layer addSublayer:oceanFrontLayer];
    
    CALayer *beachLayer = [CALayer layer];
    beachLayer.frame = CGRectMake(0, 0, 320, 367);
    UIImage *beachImage = [UIImage imageNamed:@"beachLayer.png"];
    beachLayer.contents = (id) beachImage.CGImage;
    beachLayer.masksToBounds = YES;
    [beachLayer setContentsScale:[[UIScreen mainScreen] scale]];
    [self.view.layer addSublayer:beachLayer];
    
    CALayer *waterTempLayer = [CALayer layer];
    waterTempLayer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6].CGColor;
    waterTempLayer.shadowOffset = CGSizeMake(0, 3);
    waterTempLayer.frame = CGRectMake(10, 240, 120, 25);
    waterTempLayer.cornerRadius = 10.0;
    [self.view.layer addSublayer:waterTempLayer];
    
    CALayer *forecastLayer = [CALayer layer];
    forecastLayer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6].CGColor;
    forecastLayer.shadowOffset = CGSizeMake(0, 3);
    forecastLayer.frame = CGRectMake(160, 100, 140, 40);
    forecastLayer.cornerRadius = 10.0;
    [self.view.layer addSublayer:forecastLayer];
    
    CALayer *airTempLayer = [CALayer layer];
    airTempLayer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6].CGColor;
    airTempLayer.shadowOffset = CGSizeMake(0, 3);
    airTempLayer.frame = CGRectMake(205, 265, 100, 25);
    airTempLayer.cornerRadius = 10.0;
    [self.view.layer addSublayer:airTempLayer];
    
    CALayer *uvIndexLayer = [CALayer layer];
    uvIndexLayer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6].CGColor;
    uvIndexLayer.shadowOffset = CGSizeMake(0, 3);
    uvIndexLayer.frame = CGRectMake(10, 15, 120, 25);
    uvIndexLayer.cornerRadius = 10.0;
    [self.view.layer addSublayer:uvIndexLayer];
    
    // In accordance with the guidelines provided at:
    // http://www.wunderground.com/weather/api/d/docs?d=resources/logo-usage-guide
    CALayer *wuIconLayer = [CALayer layer];
    int wuIconHeight=17+1*5;
    int wuIconWidth=126+7.41176470588*5;
    //wuIconLayer.frame = CGRectMake((320-wuIconWidth)/2, 367-(25+50), wuIconWidth, wuIconHeight);
    wuIconLayer.frame = CGRectMake(320-(wuIconWidth+(wuIconHeight/4)), 367-((5*wuIconHeight/4)+50), wuIconWidth, wuIconHeight);
    UIImage *wuIcon = [UIImage imageNamed:@"wundergroundLogo_black_horz.png"];
    wuIconLayer.contents = (id) wuIcon.CGImage;
    [wuIconLayer setContentsScale:[[UIScreen mainScreen] scale]];
    [self.view.layer addSublayer:wuIconLayer];
}

-(void)viewWillAppear:(BOOL)animated
{
    if([displayCondition isEqualToString:@"Sunny"])
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
    }else if([displayCondition isEqualToString:@"Cloudy"] || [displayCondition isEqualToString:@"Rainy"]){
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
        
        if ([displayCondition isEqualToString:@"Rainy"]) 
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
    
    if([(SandsAppDelegate *)[[UIApplication sharedApplication] delegate] hasAd])
        [self adjustAdSize];
    
    
    NSString *weatherText = [[NSString alloc] initWithFormat:@"Forecast:\n%@", [[weather currentConditions] objectForKey:@"weather"]];
    
    CATextLayer *weatherTextLayer = [CATextLayer layer];
    [weatherTextLayer setForegroundColor:[[UIColor whiteColor] CGColor]];
    [weatherTextLayer setString:weatherText];
    [weatherTextLayer setFrame:CGRectMake(161, 105, 138, 40)];
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
    NSString *airTempText = [[NSString alloc] initWithString:@"Air: "];
    int airTemp = [[[weather currentConditions] objectForKey:@"temp_f"] intValue];
    
    if ([[[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem] boolValue]) 
    {
        airTemp = [[[weather currentConditions] objectForKey:@"temp_c"] intValue];
        
        waterTempText = [waterTempText stringByAppendingFormat:@"%d°C", [[[weather waterTemp] tempC] intValue]];
        
        airTempText = [airTempText stringByAppendingFormat:@"%d°C", airTemp];
    }else
    {
        waterTempText = [waterTempText stringByAppendingFormat:@"%d°F", [[[weather waterTemp] tempF] intValue]];
        airTempText = [airTempText stringByAppendingFormat:@"%d°F", airTemp];
    }

    CATextLayer *waterTempTextLayer = [CATextLayer layer];
    [waterTempTextLayer setForegroundColor:[[UIColor whiteColor] CGColor]];
    [waterTempTextLayer setString:waterTempText];
    [waterTempTextLayer setFrame:CGRectMake(15, 245, 110, 25)];
    [waterTempTextLayer setAlignmentMode:kCAAlignmentCenter];
    [waterTempTextLayer setFont:@"Helvetica"];
    [waterTempTextLayer setFontSize:18];
    [waterTempTextLayer setContentsScale:[[UIScreen mainScreen] scale]];
    [self.view.layer addSublayer:waterTempTextLayer];
    [waterTempTextLayer setZPosition:1];
    
    CATextLayer *airTempTextLayer = [CATextLayer layer];
    [airTempTextLayer setForegroundColor:[[UIColor whiteColor] CGColor]];
    [airTempTextLayer setString:airTempText];
    [airTempTextLayer setFrame:CGRectMake(210, 270, 90, 40)];
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

-(NSString *)determineDisplayWeather:(NSString *)condition
{
    NSArray *sunConditions = [NSArray arrayWithObjects:@"Clear", nil];
    NSArray *cloudConditions = [NSArray arrayWithObjects:@"Mist", @"Fog", @"Fog Patches", @"Smoke", @"Haze", @"Freezing Fog", @"Patches of Fog", @"Shallow Fog", @"Partial Fog", @"Overcast", @"Scattered Clouds", @"Funnel Cloud", @"Mostly Cloudy", @"Partly Cloudy", nil];
    NSArray *rainConditions = [NSArray arrayWithObjects:@"Drizzle", @"Rain", @"Snow", @"Snow Grains", @"Ice Crystals", @"Ice Pellets", @"Hail", @"Spray", @"Low Drifting Snow", @"Blowing Snow", @"Rain Mist", @"Rain Showers", @"Snow Showers", @"Snow Blowing Snow Mist", @"Ice Pellet Showers", @"Hail Showers", @"Small Hail Showers", @"Thunderstorm", @"Thunderstorms and Rain", @"Thunderstorms and Snow", @"Thunderstorms and Ice Pellets", @"Thunderstorms with Hail", @"Thunderstorms with Small Hail", @"Freezing Drizzle", @"Freezing Rain", @"Small Hail", @"Squals", nil];
    
    if ([condition length] > 6 && ([[condition substringToIndex:4] isEqualToString:@"Light"] || [[condition substringToIndex:4] isEqualToString:@"Heavy"])) {
        condition = [condition substringFromIndex:6];
    }
    
    if ([sunConditions containsObject:condition])
        return @"Sunny";
    else if ([cloudConditions containsObject:condition])
        return @"Cloudy";
    else if ([rainConditions containsObject:condition])
        return @"Rainy";
    else 
        return @"Other";
}


#pragma mark - AdWhirl methods

-(void)adjustAdSize {
    NSLog(@"%@ is displaying the Ad.", self.navigationItem.title);
    adWhirlView = [(SandsAppDelegate *)[[UIApplication sharedApplication] delegate] adView];
    [self.view addSubview:adWhirlView];
	//1
	[UIView beginAnimations:@"AdResize" context:nil];
	[UIView setAnimationDuration:0.2];
	//2
	CGSize adSize = [adWhirlView actualAdSize];
	//3
	CGRect newFrame = adWhirlView.frame;
	//4
	newFrame.size.height = adSize.height;
    
   	//5 
    CGSize winSize = self.view.bounds.size;
    //6
	newFrame.size.width = winSize.width;
	//7
	newFrame.origin.x = (self.adWhirlView.bounds.size.width - adSize.width)/2;
    
    //8 
	newFrame.origin.y = (winSize.height - adSize.height);
	//9
	adWhirlView.frame = newFrame;
	//10
	[UIView commitAnimations];
}

@end
