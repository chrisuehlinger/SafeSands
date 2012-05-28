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

@implementation WeatherViewController

@synthesize weather;
@synthesize uvIndex;

CALayer *weatherLayer, *uvIndexLayer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.view setBackgroundColor: [UIColor colorWithPatternImage:[UIImage imageNamed:@"sandBackground.jpg"]]];
    
    weather = [[(SandsAppDelegate *)[[UIApplication sharedApplication] delegate] currentBeach] weather];

    weatherLayer = [CALayer layer];
    [self.view.layer addSublayer:weatherLayer];
    weatherLayer.backgroundColor = [UIColor colorWithRed:0 green:0.140625 blue:0.45703125 alpha:1].CGColor;
    weatherLayer.shadowOffset = CGSizeMake(0, 3);
    weatherLayer.frame = CGRectMake(20, 10, 280, 20);
    weatherLayer.cornerRadius = 10.0;
    weatherLayer.zPosition = -10;

    uvIndex = [[(SandsAppDelegate *)[[UIApplication sharedApplication] delegate] currentBeach] uvIndex];
    uvIndexLayer = [CALayer layer];
    [self.view.layer addSublayer:uvIndexLayer];
    uvIndexLayer.backgroundColor = [UIColor colorWithRed:0 green:0.140625 blue:0.45703125 alpha:1].CGColor;
    uvIndexLayer.shadowOffset = CGSizeMake(0, 3);
    uvIndexLayer.frame = CGRectMake(20, 120, 280, 20);
    uvIndexLayer.cornerRadius = 10.0;
    uvIndexLayer.zPosition = -10;
}

-(void)viewDidAppear:(BOOL)animated
{
    NSString *weatherText = [[NSString alloc] initWithString:@"Current Conditions:\n"];
    weatherText = [weatherText stringByAppendingFormat:@"%@\n", [[weather currentConditions] objectForKey:@"condition"]];
    weatherText = [weatherText stringByAppendingFormat:@"Air: %@°F\n", [[weather currentConditions] objectForKey:@"temp_f"]];
    weatherText = [weatherText stringByAppendingFormat:@"Water: %@°F\n", [[weather waterTemp] tempF]];
    
    CATextLayer *weatherTextLayer = [CATextLayer layer];
    [weatherTextLayer setForegroundColor:[[UIColor colorWithRed:1 green:1 blue:1 alpha:1] CGColor]];
    [weatherTextLayer setString:weatherText];
    [weatherTextLayer setFrame:CGRectMake(30, 20, 260, 80)];
    [weatherTextLayer setAlignmentMode:kCAAlignmentLeft];
    [weatherTextLayer setFont:@"Helvetica"];
    [weatherTextLayer setFontSize:20];
    [weatherTextLayer setContentsScale:[[UIScreen mainScreen] scale]];
    weatherTextLayer.shadowOffset = CGSizeMake(0, 0);
    weatherTextLayer.shadowRadius = 1;
    weatherTextLayer.shadowColor = [UIColor blackColor].CGColor;
    weatherTextLayer.shadowOpacity = 1;
    
    [self.view.layer addSublayer:weatherTextLayer];
    [weatherTextLayer setZPosition:1];
    
    CALayer *sublayer = [CALayer layer];
    sublayer.backgroundColor = [UIColor blueColor].CGColor;
    /*sublayer.shadowOffset = CGSizeMake(0, 3);
    sublayer.shadowRadius = 5.0;
    sublayer.shadowColor = [UIColor blackColor].CGColor;
    sublayer.shadowOpacity = 0.8;*/
    sublayer.frame = CGRectMake(230, 20, 60, 60);
    sublayer.borderColor = [UIColor blackColor].CGColor;
    sublayer.borderWidth = 2.0;
    sublayer.cornerRadius = 10.0;
    [self.view.layer addSublayer:sublayer];
    
    CALayer *imageLayer = [CALayer layer];
    imageLayer.frame = sublayer.bounds;
    imageLayer.cornerRadius = 10.0;
    UIImage *weatherImage = [[weather currentConditions] objectForKey:@"image"];
    imageLayer.contents = (id) weatherImage.CGImage;
    imageLayer.masksToBounds = YES;
    [imageLayer setContentsScale:[[UIScreen mainScreen] scale]];
    [sublayer addSublayer:imageLayer];
    
    
    NSString *uvIndexText = [[NSString alloc] initWithFormat:@"UV Index: %d\n", [[uvIndex index] intValue]];
    if ([uvIndex uvAlert])
        uvIndexText = [uvIndexText stringByAppendingFormat:@"Warning: UV Alert!\n"];
    
    CATextLayer *uvIndexTextLayer = [CATextLayer layer];
    [uvIndexTextLayer setForegroundColor:[[UIColor colorWithRed:1 green:1 blue:1 alpha:1] CGColor]];
    [uvIndexTextLayer setString:uvIndexText];
    [uvIndexTextLayer setFrame:CGRectMake(30, 130, 260, 80)];
    [uvIndexTextLayer setAlignmentMode:kCAAlignmentLeft];
    [uvIndexTextLayer setFont:@"Helvetica"];
    [uvIndexTextLayer setFontSize:20];
    [uvIndexTextLayer setContentsScale:[[UIScreen mainScreen] scale]];
    /*uvIndexTextLayer.shadowRadius = 5.0;
    uvIndexTextLayer.shadowColor = [UIColor blackColor].CGColor;
    uvIndexTextLayer.shadowOpacity = 0.8;*/
    [self.view.layer addSublayer:uvIndexTextLayer];
    [uvIndexTextLayer setZPosition:1];
    
    weatherLayer.frame = CGRectMake(20, 10, 280, 100);
    uvIndexLayer.frame = CGRectMake(20, 120, 280, 40);
    
    /*[UIView animateWithDuration: 1.0
                     animations: ^{
                         weatherLayer.frame = CGRectMake(20, 10, 280, 100);
                         uvIndexLayer.frame = CGRectMake(20, 120, 280, 100);
                     }
                     completion: ^(BOOL finished){
                         [UIView animateWithDuration: 1.0
                                          animations: ^{}];
                     }];*/
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
