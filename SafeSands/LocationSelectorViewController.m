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
@synthesize adWhirlView;
@synthesize cancelButton;

CGRect searchBarFrame;
TidalStationDB *tidalDB;
SpinnerView *spinner;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        delegate = (SandsAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        
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
    
    if([(SandsAppDelegate *)[[UIApplication sharedApplication] delegate] hasAd])
        [self adjustAdSize];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adjustAdSize)
                                                 name:@"receivedAd"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(foundData)
                                                 name:@"foundData"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleError)
                                                 name:@"Connection Error"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleError)
                                                 name:@"Non-USA Country"
                                               object:nil];
    
    /*NSLog(@"SearchBarFrame = %f,%f,%f,%f",
          locationSearchBar.frame.origin.x,
          locationSearchBar.frame.origin.y,
          locationSearchBar.frame.size.width,
          locationSearchBar.frame.size.height);*/
    locationSearchBar.autoresizingMask = 0;
    searchBarFrame = locationSearchBar.frame;
    locationSearchController = [[UISearchDisplayController alloc] initWithSearchBar:locationSearchBar contentsController:self];
    locationSearchBar.delegate = self;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    if([(SandsAppDelegate *)[[UIApplication sharedApplication] delegate] hasAd])
        [self adjustAdSize];
    
    SandsAppDelegate *del = (SandsAppDelegate *)[[UIApplication sharedApplication] delegate];
    if([del currentBeach]) {
        [[del currentBeach] setDelegate:nil];
        [del setCurrentBeach:nil];
    }
}

- (void)viewDidUnload
{
    [self setUseCurrentLocationButton:nil];
    [self setLocationSearchBar:nil];
    [self setLocationSearchController:nil];
    [self setCancelButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)useCurrentLocation:(id)sender {
    [self performSearch:@"CurrentLocation"];
}

- (IBAction)cancelSearch:(id)sender {
    [cancelButton setHidden:YES];
    [spinner removeSpinner];
    spinner = nil;
    SandsAppDelegate *del = (SandsAppDelegate *)[[UIApplication sharedApplication] delegate];
    [[del currentBeach] setDelegate:nil];
    [del setCurrentBeach:nil];
}

-(void)performSearch:(NSString *)searchString {
    SandsAppDelegate *del = (SandsAppDelegate *)[[UIApplication sharedApplication] delegate];
    [del setCurrentBeach:[[Beach alloc] initWithString:searchString andDelegate:del]];
    spinner = [SpinnerView loadSpinnerIntoView:self.view];
    [spinner setCenter:CGPointMake(self.view.center.x, self.view.center.y-25)];
    [cancelButton setHidden:NO];
    [self.view bringSubviewToFront:adWhirlView];
}

-(void)foundData
{
    [cancelButton setHidden:YES];
    [spinner removeSpinner];
    spinner = nil;
    
    UITabBarController *dest = [[self storyboard] instantiateViewControllerWithIdentifier:@"mainTabController"];
    [self.navigationController pushViewController:dest animated:YES];
}

#pragma mark - SearchBarControllerDelegate methods

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    
    [UIView animateWithDuration:0.33 animations:^{
        searchBar.frame = CGRectMake(0, 0, self.view.frame.size.width, searchBar.frame.size.height);
         [locationSearchController setActive:YES animated:YES];
    }];
   
    
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [locationSearchController setActive:NO animated:NO];
    [UIView animateWithDuration:0.33 animations:^{
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
    NSString *searchString = [searchBar text];
    [self searchBarCancelButtonClicked:searchBar];
    [self performSearch:searchString];
}

#pragma mark - AdWhirl methods

-(void)adjustAdSize {
    /*if (adWhirlView) {
        [UIView beginAnimations:@"AdHide" context:nil];
        [UIView setAnimationDuration:0.2];
        CGRect hiddenFrame = adWhirlView.frame;
        hiddenFrame.origin.y = self.view.bounds.size.height;
        [adWhirlView setFrame:hiddenFrame];
        [UIView commitAnimations];
    }*/
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

/*-(void)onEnter {
    //1
    UINavigationController *viewController = [(SandsAppDelegate *)[[UIApplication sharedApplication] delegate] navController];
    //[[[[UIApplication sharedApplication] windows] lastObject] rootViewController];
    //2
    self.adWhirlView = [AdWhirlView requestAdWhirlViewWithDelegate:self];
    //3
    self.adWhirlView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    
    //4
    [adWhirlView updateAdWhirlConfig];
    //5
	CGSize adSize = [adWhirlView actualAdSize];
    //6
    CGSize winSize = self.view.bounds.size;
    //7
	self.adWhirlView.frame = CGRectMake((winSize.width/2)-(adSize.width/2),winSize.height-adSize.height,winSize.width,adSize.height);
    //8
	self.adWhirlView.clipsToBounds = YES;
    //9
    [viewController.view addSubview:adWhirlView];
    //10
    [viewController.view bringSubviewToFront:adWhirlView];
    //11
    //[super onEnter];
}

-(void)onExit {
    if (adWhirlView) {
        [adWhirlView removeFromSuperview];
        [adWhirlView replaceBannerViewWith:nil];
        [adWhirlView ignoreNewAdRequests];
        [adWhirlView setDelegate:nil];
        self.adWhirlView = nil;
    }
    //[super onExit];
}*/

#pragma mark - Error Handling

-(void)handleError
{
    [cancelButton setHidden:YES];
    if(spinner)
    {
        [spinner removeSpinner];
        spinner = nil;
    }
}


@end
