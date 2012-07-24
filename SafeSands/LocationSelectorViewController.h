//
//  LocationSelectorViewController.h
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/9/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AdWhirlView.h"
#import "Beach.h"
#import "SandsAppDelegate.h"

@interface LocationSelectorViewController : UIViewController<UISearchBarDelegate, UISearchDisplayDelegate>{
    AdWhirlView *adWhirlView;
    bool bannerIsVisible, adIsLoaded, bannerShouldShow;
    SandsAppDelegate *delegate;
}

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *useCurrentLocationButton;
@property (unsafe_unretained, nonatomic) IBOutlet UISearchBar *locationSearchBar;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *locationSearchController;
@property (strong, nonatomic) AdWhirlView *adWhirlView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

- (IBAction)useCurrentLocation:(id)sender;
- (IBAction)cancelSearch:(id)sender;

@end
