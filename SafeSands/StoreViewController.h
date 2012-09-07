//
//  StoreViewController.h
//  SafeSands
//
//  Created by Christopher Uehlinger on 7/24/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "AdWhirlView.h"

@interface StoreViewController : UIViewController<SKProductsRequestDelegate>


@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) AdWhirlView *adWhirlView;
@property (weak, nonatomic) IBOutlet UIButton *restoreButton;

- (IBAction)makePurchase:(id)sender;
- (IBAction)cancelPurchase:(id)sender;
- (IBAction)restorePurchase:(id)sender;


@end
