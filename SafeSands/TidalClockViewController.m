//
//  TidalClockViewController.m
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/28/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import "TidalClockViewController.h"
#import "SandsAppDelegate.h"
#import "SpinnerView.h"
#import <QuartzCore/QuartzCore.h>

@implementation TidalClockViewController

@synthesize reading;
@synthesize clock;
@synthesize adWhirlView;

SpinnerView *spinner;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        hasReading=NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor: [UIColor colorWithPatternImage:[UIImage imageNamed:@"sandBackground.jpg"]]];
    CGRect clockFrame = self.view.frame;
    clockFrame.origin.y = 25;
    clock = [[TidalClockView alloc] initWithFrame:clockFrame];
    [self.clock setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0]];
    [self.view addSubview:clock];
}

- (void)viewWillAppear:(BOOL)animated
{
    if([(SandsAppDelegate *)[[UIApplication sharedApplication] delegate] hasAd])
        [self adjustAdSize];
    
    if([[(SandsAppDelegate *)[[UIApplication sharedApplication] delegate] currentBeach] hasTidalReading])
    {
        [spinner removeSpinner];
        reading = [[(SandsAppDelegate *)[[UIApplication sharedApplication] delegate] currentBeach] reading];
        [clock drawClockWithLastTide:[reading lastTide] andNextTide:[reading nextTide]];
    }else if([(SandsAppDelegate *)[[UIApplication sharedApplication] delegate] currentBeach] != nil)
    {
        spinner = [SpinnerView loadSpinnerIntoView:self.view];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(foundTides)
                                                     name:@"foundTides"
                                                   object:nil];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [spinner removeSpinner];
    spinner = nil;
}

- (void)viewDidUnload
{
    [self setClock:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [clock setNeedsDisplay];
}

-(void)createClockWithReading:(TidalReading *)r
{
    reading=r;
    hasReading=YES;
}

-(void)foundTides
{
    reading = [[(SandsAppDelegate *)[[UIApplication sharedApplication] delegate] currentBeach] reading];
    [clock drawClockWithLastTide:[reading lastTide] andNextTide:[reading nextTide]];
    [spinner removeSpinner];
}

#pragma mark - AdWhirl methods

-(void)adjustAdSize {
    NSLog(@"%@ is displaying the Ad.", self.navigationItem.title);
    adWhirlView = [(SandsAppDelegate *)[[UIApplication sharedApplication] delegate] adView];
    [self.view addSubview:adWhirlView];
	//1
	[UIView beginAnimations:@"AdResize" context:nil];
	[UIView setAnimationDuration:0.2];
    
    CGRect clockFrame = clock.frame;
    clockFrame.origin.y = 0;
    [clock setFrame:clockFrame];
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
