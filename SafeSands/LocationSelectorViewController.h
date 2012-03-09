//
//  LocationSelectorViewController.h
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/9/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"

@interface LocationSelectorViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *locationField;
@property (weak, nonatomic) IBOutlet UIButton *enterButton;
@property (weak, nonatomic) IBOutlet UIButton *useCurrentLocationButton;

-(IBAction)clickEnterButton:(id)sender;
-(IBAction)clickUseCurrentLocationButton:(id)sender;

@end
