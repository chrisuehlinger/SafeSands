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

@implementation TidalClockViewController

@synthesize reading;
@synthesize clock;

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
    [clock setBackgroundColor: [UIColor colorWithPatternImage:[UIImage imageNamed:@"sandBackground.jpg"]]];
}

- (void)viewWillAppear:(BOOL)animated
{
    if([[(SandsAppDelegate *)[[UIApplication sharedApplication] delegate] currentBeach] hasTidalReading])
    {
        [spinner removeSpinner];
        reading = [[(SandsAppDelegate *)[[UIApplication sharedApplication] delegate] currentBeach] reading];
        [clock drawClockWithLastTide:[reading lastTide] andNextTide:[reading nextTide]];
    }else
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

@end
