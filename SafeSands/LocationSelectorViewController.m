//
//  LocationSelectorViewController.m
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/9/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import "LocationSelectorViewController.h"
#import "SandsAppDelegate.h"
#import "SpinnerView.h"

@implementation LocationSelectorViewController
@synthesize useCurrentLocationButton;
@synthesize locationSearchBar;
@synthesize locationSearchController;

CGRect searchBarFrame;
TidalStationDB *tidalDB;
SpinnerView *spinner;

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
    [self.view setBackgroundColor: [UIColor colorWithPatternImage:[UIImage imageNamed:@"sandBackground.jpg"]]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(foundData)
                                                 name:@"foundData"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleConnectionError)
                                                 name:@"Connection Error"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNonUSACountryError)
                                                 name:@"Non-USA Country"
                                               object:nil];
    
    NSLog(@"SearchBarFrame = %f,%f,%f,%f",
          locationSearchBar.frame.origin.x,
          locationSearchBar.frame.origin.y,
          locationSearchBar.frame.size.width,
          locationSearchBar.frame.size.height);
    locationSearchBar.autoresizingMask = 0;
    searchBarFrame = locationSearchBar.frame;
    //tidalDB = [[TidalStationDB alloc] init];
    locationSearchController = [[UISearchDisplayController alloc] initWithSearchBar:locationSearchBar contentsController:self];
    locationSearchBar.delegate = self;
    
}


- (void)viewDidUnload
{
    [self setUseCurrentLocationButton:nil];
    [self setLocationSearchBar:nil];
    [self setLocationSearchController:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
      //  locationSearchBar.frame = CGRectMake(110, 92, 260, 44);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    //NSLog(@"Rotation from %@", [fromInterfaceOrientation] );
    NSLog(@"SearchBarFrame = %f,%f,%f,%f",
          locationSearchBar.frame.origin.x,
          locationSearchBar.frame.origin.y,
          locationSearchBar.frame.size.width,
          locationSearchBar.frame.size.height);
}

#pragma mark - SearchBarControllerDelegate methods

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [UIView animateWithDuration:0.5 animations:^{
        searchBar.frame = CGRectMake(0, 0, self.view.frame.size.width, searchBar.frame.size.height);
        [locationSearchController setActive:YES animated:NO];
    }];
    
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [locationSearchController setActive:NO animated:NO];
    [UIView animateWithDuration:0.5 animations:^{
        searchBar.frame = searchBarFrame;
    }];
    [searchBar resignFirstResponder];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    [self searchBarCancelButtonClicked:searchBar];
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    
    SandsAppDelegate *del = (SandsAppDelegate *)[[UIApplication sharedApplication] delegate];
    [del setCurrentBeach:[[Beach alloc] initWithString:[searchBar text] andDelegate:del]];
    spinner = [SpinnerView loadSpinnerIntoView:self.view];
    [self searchBarCancelButtonClicked:searchBar];
}

- (IBAction)useCurrentLocation:(id)sender {
    SandsAppDelegate *del = (SandsAppDelegate *)[[UIApplication sharedApplication] delegate];
    [del setCurrentBeach:[[Beach alloc] initWithString:@"CurrentLocation" andDelegate:del]];
    spinner = [SpinnerView loadSpinnerIntoView:self.view];
}

-(void)foundData
{
    [spinner removeSpinner];
    
    UITabBarController *dest = [[self storyboard] instantiateViewControllerWithIdentifier:@"mainTabController"];
    [self.navigationController pushViewController:dest animated:YES];
}

-(void)handleConnectionError
{
    if(spinner)
    {
        NSLog(@"Connection Error");
        
        SandsAppDelegate *del = (SandsAppDelegate *)[[UIApplication sharedApplication] delegate];
        del.currentBeach.delegate = nil;
        del.currentBeach = nil;
        
        [spinner removeSpinner];
        spinner = nil;
        
        UIAlertView *noConnectionAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                    message:@"Connection Error. Please ensure that you have an internet connection."
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
        [noConnectionAlert show];
    }
}

-(void)handleNonUSACountryError
{
    if(spinner)
    {
        NSLog(@"Non-USA Country Error");
        
        SandsAppDelegate *del = (SandsAppDelegate *)[[UIApplication sharedApplication] delegate];
        del.currentBeach.delegate = nil;
        del.currentBeach = nil;
        
        [spinner removeSpinner];
        spinner = nil;
        
        UIAlertView *nonUSAAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"SafeSands can only report on conditions within the USA."
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
        [nonUSAAlert show];
    }
}

@end
