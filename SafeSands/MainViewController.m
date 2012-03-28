//
//  MainViewController.m
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/9/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import "MainViewController.h"

@implementation MainViewController

@synthesize weatherImageView;
@synthesize placemarkDisplay, placemarkButton, placemarkActivityIndicator;
@synthesize weatherDisplay, weatherButton, weatherActivityIndicator;
@synthesize tidalDisplay, tidalButton, tidalActivityIndicator;
@synthesize ripTideDisplay, ripTideButton, ripTideActivityIndicator;
@synthesize beach;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self placemarkDisplay] setText:@"Finding Location..."];
    [[self placemarkActivityIndicator] startAnimating];
    [[self placemarkButton] setEnabled:NO];
    [[self placemarkDisplay] setUserInteractionEnabled: NO];
    
    [[self weatherDisplay] setText:@"Finding Weather..."];
    [[self weatherActivityIndicator] startAnimating];
    [[self weatherButton] setEnabled:NO];
    [[self weatherDisplay] setUserInteractionEnabled: NO];
    
    [[self tidalDisplay] setText:@"Finding Tides..."];
    [[self tidalActivityIndicator] startAnimating];
    [[self tidalButton] setEnabled:NO];
    [[self tidalDisplay] setUserInteractionEnabled: NO];
    
    [[self ripTideDisplay] setText:@"Finding Alerts...\n(not yet implemented)"];
    [[self ripTideActivityIndicator] startAnimating];
    [[self ripTideButton] setEnabled:NO];
    [[self ripTideDisplay] setUserInteractionEnabled: NO];
}

- (void)viewDidUnload
{
    [self setBeach:nil]; 
    [self setPlacemarkDisplay:nil];
    [self setPlacemarkActivityIndicator:nil];
    [self setPlacemarkButton:nil];
    [self setWeatherDisplay:nil];
    [self setWeatherButton:nil];
    [self setWeatherActivityIndicator:nil];
    [self setTidalDisplay:nil];
    [self setTidalButton:nil];
    [self setTidalActivityIndicator:nil];
    [self setRipTideDisplay:nil];
    [self setRipTideButton:nil];
    [self setRipTideActivityIndicator:nil];
    [self setWeatherImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)clickPlacemarkButton:(id)sender {
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *theID = [segue identifier];
    NSLog(@"%@", theID);
    if([theID isEqualToString:@"placemarkSegue"])
    {
        PlacemarkViewController *dest = [segue destinationViewController];
        [dest setPlacemark:[beach placemark]];
    }else if ([theID isEqualToString:@"weatherSegue"]) {
        WeatherViewController *dest = [segue destinationViewController];
        [dest setWeather:[beach weather]];
    }else if ([theID isEqualToString:@"tidalSegue"]) {
        TidalClockViewController *dest = [segue destinationViewController];
        [dest setReading:[beach reading]];
    }
}

#pragma mark - beachDelegate methods

-(void)foundPlacemark:(NSString *)newText
{
    [[self placemarkDisplay] setText:newText];
    [[self placemarkActivityIndicator] stopAnimating];
    [[self placemarkButton] setEnabled:YES];
}

-(void)foundWeather:(NSString *)newText andImage:(UIImage *)theImage
{
    [[self weatherDisplay] setText:newText];
    //[[self weatherImageView] setImage:theImage];
    [[self weatherActivityIndicator] stopAnimating];
    [[self weatherButton] setEnabled:YES];
    [[self weatherButton] setImage:theImage forState:UIControlStateNormal];
}

-(void)foundTides:(NSString *)newText
{
    [[self tidalDisplay] setText:newText];
    [[self tidalActivityIndicator] stopAnimating];
    [[self tidalButton] setEnabled:YES];
}

@end
