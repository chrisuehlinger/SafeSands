//
//  SandsTabBarController.m
//  SafeSands
//
//  Created by Christopher Uehlinger on 6/25/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import "SandsTabBarController.h"
#import "SandsAppDelegate.h"

@interface SandsTabBarController ()

@end

@implementation SandsTabBarController

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
    
    [[self navigationItem] setTitle:[[[[self viewControllers] objectAtIndex:0] navigationItem] title]];
    self.navigationController.navigationBar.backItem.title = @"Back";
    [self setDelegate:self];
    
    if([[(SandsAppDelegate *)[[UIApplication sharedApplication] delegate] currentBeach] hasAlerts])
        [self foundAlerts];
    else
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(foundAlerts)
                                                     name:@"foundAlerts"
                                                   object:nil];
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

-(void)foundAlerts
{
    Alerts *alerts = [[(SandsAppDelegate *)[[UIApplication sharedApplication] delegate] currentBeach] alerts];
    if ([[alerts alerts] count] > 0)
        [[[self.viewControllers objectAtIndex:3] tabBarItem] setBadgeValue:[NSString stringWithFormat:@"%d",[[alerts alerts] count]]];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    [[self navigationItem] setTitle:[[viewController navigationItem] title]];
}

@end
