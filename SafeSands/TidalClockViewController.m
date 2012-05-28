//
//  TidalClockViewController.m
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/28/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import "TidalClockViewController.h"
#import "SandsAppDelegate.h"

@implementation TidalClockViewController

@synthesize reading;
@synthesize clock;

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
    
    reading = [[(SandsAppDelegate *)[[UIApplication sharedApplication] delegate] currentBeach] reading];
    [clock drawClockWithLastTide:[reading lastTide] andNextTide:[reading nextTide]];
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

@end
