//
//  AlertViewController.m
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/30/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import "AlertViewController.h"
#import "SandsAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "SpinnerView.h"
#import "Beach.h"

@implementation AlertViewController

@synthesize alerts;
@synthesize scrollView;
@synthesize pageControl;
@synthesize adWhirlView;

NSInteger numberOfViews;
NSMutableArray *alertViews;

SpinnerView *spinner;

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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adjustAdSize)
                                                 name:@"receivedAd"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(foundAlerts)
                                                 name:@"foundAlerts"
                                               object:nil];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[(SandsAppDelegate *)[[UIApplication sharedApplication] delegate] currentBeach] hasAlerts] )
    {
        alerts = [[(SandsAppDelegate *)[[UIApplication sharedApplication] delegate] currentBeach] alerts];
        [self setUpScrollView:alerts];
    }else
    {
        spinner = [SpinnerView loadSpinnerIntoView:self.view];
    }
    
    if([(SandsAppDelegate *)[[UIApplication sharedApplication] delegate] hasAd])
        [self adjustAdSize];
}

-(void)foundAlerts
{
    alerts = [[(SandsAppDelegate *)[[UIApplication sharedApplication] delegate] currentBeach] alerts];
    [self setUpScrollView:alerts];
    [spinner removeSpinner];
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void)viewDidDisappear:(BOOL)animated
{
    [spinner removeSpinner];
    spinner = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)setUpScrollView:(Alerts *)a
{    
    alertViews = [[NSMutableArray alloc] init];
    
    if ([[alerts alerts] count] > 0) {
        numberOfViews = [[alerts alerts] count];
        for (int i = 0; i < numberOfViews; i++) {
            NSMutableDictionary *theAlert = [[alerts alerts] objectAtIndex:i];
            NSString *displayText = [[NSString alloc] init];
            displayText = [displayText stringByAppendingFormat:@"%@\n", [theAlert objectForKey:@"cap:event"]];
            //displayText = [displayText stringByAppendingFormat:@"Status: %@ ", [theAlert objectForKey:@"cap:status"]];
            //displayText = [displayText stringByAppendingFormat:@"Urgency: %@\n", [theAlert objectForKey:@"cap:urgency"]];
            displayText = [displayText stringByAppendingFormat:@"Areas Affected: %@\n", [theAlert objectForKey:@"cap:areaDesc"]];
            displayText = [displayText stringByAppendingFormat:@"Summary: %@\n", [theAlert objectForKey:@"summary"]];
            
            UIView *alertView = [[UIView alloc] initWithFrame:self.view.frame];
            CALayer *alertLayer = [CALayer layer];
            [alertView.layer addSublayer:alertLayer];
            alertLayer.backgroundColor = [UIColor colorWithRed:0 green:155.0/255.0 blue:219.0/255.0 alpha:1].CGColor;
            alertLayer.shadowOffset = CGSizeMake(0, 3);
            alertLayer.frame = CGRectMake(15, 15, 290, 295);
            alertLayer.cornerRadius = 10.0;
            alertLayer.zPosition = -10;
            
            CATextLayer *alertTextLayer = [CATextLayer layer];
            [alertTextLayer setForegroundColor:[[UIColor colorWithRed:1 green:1 blue:1 alpha:1] CGColor]];
            [alertTextLayer setString:displayText];
            [alertTextLayer setWrapped:YES];
            [alertTextLayer setFrame:CGRectMake(25, 25, 270, 270)];
            [alertTextLayer setAlignmentMode:kCAAlignmentLeft];
            [alertTextLayer setFont:@"Helvetica"];
            [alertTextLayer setFontSize:18];
            [alertTextLayer setContentsScale:[[UIScreen mainScreen] scale]];
            alertTextLayer.shadowOffset = CGSizeMake(0, 0);
            alertTextLayer.shadowRadius = 1;
            alertTextLayer.shadowColor = [UIColor blackColor].CGColor;
            alertTextLayer.shadowOpacity = 1;
            
            [alertView.layer addSublayer:alertTextLayer];
            [alertTextLayer setZPosition:1];
            
            [alertViews addObject:alertView];
        }
    }else {
        numberOfViews = 1;
        UIView *noAlertView = [[UIView alloc] initWithFrame:self.view.frame];
        CALayer *alertLayer = [CALayer layer];
        [noAlertView.layer addSublayer:alertLayer];
        alertLayer.backgroundColor = [UIColor colorWithRed:0 green:155.0/255.0 blue:219.0/255.0 alpha:1].CGColor;
        alertLayer.shadowOffset = CGSizeMake(0, 3);
        alertLayer.frame = CGRectMake(15, 15, 290, 40);
        alertLayer.cornerRadius = 10.0;
        alertLayer.zPosition = -10;
        
        CATextLayer *alertTextLayer = [CATextLayer layer];
        [alertTextLayer setForegroundColor:[[UIColor colorWithRed:1 green:1 blue:1 alpha:1] CGColor]];
        [alertTextLayer setString:@"No Alerts found for this area."];
        [alertTextLayer setWrapped:YES];
        [alertTextLayer setFrame:CGRectMake(25, 25, 270, 20)];
        [alertTextLayer setAlignmentMode:kCAAlignmentLeft];
        [alertTextLayer setFont:@"Helvetica"];
        [alertTextLayer setFontSize:20];
        [alertTextLayer setContentsScale:[[UIScreen mainScreen] scale]];
        alertTextLayer.shadowOffset = CGSizeMake(0, 0);
        alertTextLayer.shadowRadius = 1;
        alertTextLayer.shadowColor = [UIColor blackColor].CGColor;
        alertTextLayer.shadowOpacity = 1;
        
        [noAlertView.layer addSublayer:alertTextLayer];
        [alertTextLayer setZPosition:1];
        [alertViews addObject:noAlertView];
    }
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width * numberOfViews, self.view.frame.size.height);
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
    
    pageControl.numberOfPages = numberOfViews;
    pageControl.currentPage = 0;
    
    // pages are created on demand
    // load the visible page
    // load the page on either side to avoid flashes when the user starts scrolling
    //
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
}

- (void)loadScrollViewWithPage:(int)page
{
    if (page < 0)
        return;
    if (page >= numberOfViews)
        return;
    
    // replace the placeholder if necessary
    UIView *alertView = [alertViews objectAtIndex:page];
    
    // add the controller's view to the scroll view
    if (alertView.superview == nil)
    {
        CGRect frame = scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        alertView.frame = frame;
        [scrollView addSubview:alertView];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    if (pageControlUsed)
    {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
	
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    // A possible optimization would be to unload the views+controllers which are no longer visible
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

- (IBAction)changePage:(id)sender
{
    int page = pageControl.currentPage;
	
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
	// update the scroll view to the appropriate page
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
    
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    pageControlUsed = YES;
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
