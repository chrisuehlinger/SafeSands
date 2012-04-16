//
//  AlertViewController.m
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/30/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import "AlertViewController.h"

@implementation AlertViewController

@synthesize alerts;
@synthesize scrollView;

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
    if(alerts != NULL){
        [self setUpScrollView:alerts];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)setUpScrollView:(Alerts *)a
{
    [scrollView setPagingEnabled:YES];
    NSInteger numberOfViews;
    if ([[alerts alerts] count] > 0) {
        numberOfViews = [[alerts alerts] count];
        for (int i = 0; i < numberOfViews; i++) {
            NSMutableDictionary *theAlert = [[alerts alerts] objectAtIndex:i];
            NSString *displayText = [[NSString alloc] init];
            displayText = [displayText stringByAppendingFormat:@"%@\n", [theAlert objectForKey:@"title"]];
            displayText = [displayText stringByAppendingFormat:@"Status: %@\n", [theAlert objectForKey:@"cap:status"]];
            displayText = [displayText stringByAppendingFormat:@"Urgency: %@\n", [theAlert objectForKey:@"cap:urgency"]];
            displayText = [displayText stringByAppendingFormat:@"Areas Affected: %@\n", [theAlert objectForKey:@"cap:areaDesc"]];
            displayText = [displayText stringByAppendingFormat:@"Summary: %@\n", [theAlert objectForKey:@"summary"]];
            
            CGFloat yOrigin = i * self.view.frame.size.height;
            UILabel *alertView = [[UILabel alloc] initWithFrame:CGRectMake(yOrigin, 0, self.view.frame.size.width, self.view.frame.size.height)];
            [alertView setText:displayText];
            alertView.backgroundColor = [UIColor colorWithRed:1 green:0.1 blue:0.1 alpha:1];
            [scrollView addSubview:alertView];
        }
    }else {
        numberOfViews = 1;
        UILabel *noAlertView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [noAlertView setText:@"No Alerts found for this area."];
        noAlertView.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1];
        [scrollView addSubview:noAlertView];
    }
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width * numberOfViews, self.view.frame.size.height);
}

@end
