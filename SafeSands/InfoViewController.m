//
//  InfoViewController.m
//  SafeSands
//
//  Created by Christopher Uehlinger on 6/14/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import "InfoViewController.h"
#import "SandsAppDelegate.h"

@interface InfoViewController ()

@end

@implementation InfoViewController
@synthesize infoLabel;
@synthesize backButton;

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
	// Do any additional setup after loading the view.
    
    [infoLabel setText:@"SafeSands was designed and developed by Christopher Uehlinger"];
}

- (void)viewWillAppear:(BOOL)animated
{
    Beach *theBeach = [(SandsAppDelegate *)[[UIApplication sharedApplication] delegate] currentBeach];
    
    NSString *infoText = @"About SafeSands\n\n";
    
    infoText = [infoText stringByAppendingString:@"Weather provided by the Google Weather API.\n"];
    
    infoText = [infoText stringByAppendingFormat:@"Water Temperature provided by the NOAA station at: %@.\n", [[[[theBeach weather] waterTemp] station] name]];
    
    infoText = [infoText stringByAppendingString:@"UV Index provided by the EPA's UV Index API.\n"];
    
    if ([theBeach hasTidalReading]) {
        infoText = [infoText stringByAppendingFormat:@"Tidal Reading provided by the NOAA station at: %@.\n", [[[theBeach reading]  station] name]];
    }
    
    infoText = [infoText stringByAppendingString:@"Weather Alerts provided by the NWS Severe Weather Alerts feed.\n\n"];
    
    infoText = [infoText stringByAppendingString:@"SafeSands was designed and developed by Christopher Uehlinger."];
    [infoLabel setText:infoText];
    [infoLabel setBaselineAdjustment:UIBaselineAdjustmentNone];
}

- (void)viewDidUnload
{
    [self setBackButton:nil];
    [self setInfoLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)dismiss:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}
@end
