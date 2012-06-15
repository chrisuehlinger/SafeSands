//
//  LocationSelectorViewController.h
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/9/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <iAd/iAd.h>
#import "Beach.h"
#import "SandsAppDelegate.h"

@interface LocationSelectorViewController : UIViewController<UISearchBarDelegate, UISearchDisplayDelegate, ADBannerViewDelegate>{
    ADBannerView *adView;
    bool bannerIsVisible, adIsLoaded, bannerShouldShow;
    SandsAppDelegate *delegate;
}

@property (weak, nonatomic) IBOutlet UIButton *useCurrentLocationButton;
@property (weak, nonatomic) IBOutlet UISearchBar *locationSearchBar;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *locationSearchController;


- (IBAction)useCurrentLocation:(id)sender;
-(void)showBanner;
-(void)hideBanner;
-(bool)iAdIsAvailable;
-(float)getAdHeight;

@end
