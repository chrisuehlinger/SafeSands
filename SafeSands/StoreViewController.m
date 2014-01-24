//
//  StoreViewController.m
//  SafeSands
//
//  Created by Christopher Uehlinger on 7/24/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import "StoreViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SandsAppDelegate.h"
#import "SpinnerView.h"

@interface StoreViewController ()

@end

@implementation StoreViewController
@synthesize buyButton;
@synthesize cancelButton;
@synthesize adWhirlView;
@synthesize restoreButton;

SpinnerView *spinner;
CATextLayer *titleTextLayer;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dismissView)
                                                 name:@"purchaseComplete"
                                               object:nil];
    
    [buyButton setEnabled:NO];
    [restoreButton setEnabled:NO];
	[self.view setBackgroundColor: [UIColor colorWithPatternImage:[UIImage imageNamed:@"sandBackground.jpg"]]];
    
    CALayer *titleLayer = [CALayer layer];
    [self.view.layer addSublayer:titleLayer];
    titleLayer.backgroundColor = [UIColor colorWithRed:0 green:155.0/255.0 blue:219.0/255.0 alpha:1].CGColor;
    titleLayer.shadowOffset = CGSizeMake(0, 3);
    titleLayer.frame = CGRectMake(20, 20, 280, 40);
    titleLayer.cornerRadius = 10.0;
    titleLayer.zPosition = -10;
    
    CALayer *descriptionLayer = [CALayer layer];
    [self.view.layer addSublayer:descriptionLayer];
    descriptionLayer.backgroundColor = [UIColor colorWithRed:0 green:155.0/255.0 blue:219.0/255.0 alpha:1].CGColor;
    descriptionLayer.shadowOffset = CGSizeMake(0, 3);
    descriptionLayer.frame = CGRectMake(20, 75, 280, 240);
    descriptionLayer.cornerRadius = 10.0;
    descriptionLayer.zPosition = -10;
    
    titleTextLayer = [CATextLayer layer];
}

- (void)viewDidUnload
{
    [self setBuyButton:nil];
    [self setCancelButton:nil];
    [self setRestoreButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated{
    if ([SKPaymentQueue canMakePayments]) {
        SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers:
                                     [NSSet setWithObject: @"SafeSandsPro"]];
        request.delegate = self;
        [request start];
        
        [titleTextLayer setString:@"Loading..."];
    } else {
        UIAlertView *noPurchaseAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                  message:@"In-App Purchases are disabled on this device."
                                                                 delegate:nil
                                                        cancelButtonTitle:@"Dismiss"
                                                        otherButtonTitles:nil];
        [noPurchaseAlert show];
    }
    
    [titleTextLayer setForegroundColor:[[UIColor colorWithRed:1 green:1 blue:1 alpha:1] CGColor]];
    [titleTextLayer setWrapped:YES];
    [titleTextLayer setFrame:CGRectMake(30, 30, 260, 30)];
    [titleTextLayer setAlignmentMode:kCAAlignmentLeft];
    [titleTextLayer setFont:@"Helvetica"];
    [titleTextLayer setFontSize:24];
    [titleTextLayer setContentsScale:[[UIScreen mainScreen] scale]];
    [self.view.layer addSublayer:titleTextLayer];
    [buyButton setHidden:YES];
    [cancelButton setHidden:YES];
    [restoreButton setHidden:YES];
    
    if([(SandsAppDelegate *)[[UIApplication sharedApplication] delegate] hasAd])
        [self adjustAdSize];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - StoreKit methods

SKProduct *theProduct;

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    theProduct = [response.products objectAtIndex:0];

    [titleTextLayer setHidden:YES];
    [titleTextLayer setString:[theProduct localizedTitle]];
    [titleTextLayer setFont:@"Helvetica Bold"];
    titleTextLayer.shadowOffset = CGSizeMake(0, 0);
    titleTextLayer.shadowRadius = 1;
    titleTextLayer.shadowColor = [UIColor blackColor].CGColor;
    titleTextLayer.shadowOpacity = 1;
    [titleTextLayer setHidden:NO];
    
    [buyButton setHidden:NO];
    [cancelButton setHidden:NO];
    [restoreButton setHidden:NO];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:theProduct.priceLocale];
    NSString *formattedPrice = [numberFormatter stringFromNumber:theProduct.price];
    
    CATextLayer *priceTextLayer = [CATextLayer layer];
    [priceTextLayer setForegroundColor:[[UIColor colorWithRed:1 green:1 blue:1 alpha:1] CGColor]];
    [priceTextLayer setString:formattedPrice];
    [priceTextLayer setWrapped:YES];
    [priceTextLayer setFrame:CGRectMake(30, 30, 260, 30)];
    [priceTextLayer setAlignmentMode:kCAAlignmentRight];
    [priceTextLayer setFont:@"Helvetica"];
    [priceTextLayer setFontSize:24];
    [priceTextLayer setContentsScale:[[UIScreen mainScreen] scale]];
    priceTextLayer.shadowOffset = CGSizeMake(0, 0);
    priceTextLayer.shadowRadius = 1;
    priceTextLayer.shadowColor = [UIColor blackColor].CGColor;
    priceTextLayer.shadowOpacity = 1;
    [self.view.layer addSublayer:priceTextLayer];
    
    CATextLayer *descriptionTextLayer = [CATextLayer layer];
    [descriptionTextLayer setForegroundColor:[[UIColor colorWithRed:1 green:1 blue:1 alpha:1] CGColor]];
    [descriptionTextLayer setString:[theProduct localizedDescription]];
    [descriptionTextLayer setWrapped:YES];
    [descriptionTextLayer setFrame:CGRectMake(30, 83, 260, 230)];
    [descriptionTextLayer setAlignmentMode:kCAAlignmentLeft];
    [descriptionTextLayer setFont:@"Helvetica"];
    [descriptionTextLayer setFontSize:21];
    [descriptionTextLayer setContentsScale:[[UIScreen mainScreen] scale]];
    descriptionTextLayer.shadowOffset = CGSizeMake(0, 0);
    descriptionTextLayer.shadowRadius = 1;
    descriptionTextLayer.shadowColor = [UIColor blackColor].CGColor;
    descriptionTextLayer.shadowOpacity = 1;
    [self.view.layer addSublayer:descriptionTextLayer];
    
    [buyButton setEnabled:YES];
    [restoreButton setEnabled:YES];
}

- (void)dismissView
{
    if (spinner) {
        [spinner removeSpinner];
        spinner = nil;
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark Interactions

- (IBAction)makePurchase:(id)sender {
    [buyButton setEnabled:NO];
    [cancelButton setEnabled:NO];
    [restoreButton setEnabled:NO];
    
    SKProduct *selectedProduct = theProduct;
    SKPayment *payment = [SKPayment paymentWithProduct:selectedProduct];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
    spinner = [SpinnerView loadSpinnerIntoView:self.view];
    [spinner setCenter:CGPointMake(self.view.center.x, self.view.center.y-25)];
}

- (IBAction)cancelPurchase:(id)sender {
    [self dismissView];
}

- (IBAction)restorePurchase:(id)sender {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    
    [buyButton setEnabled:NO];
    [cancelButton setEnabled:NO];
    [restoreButton setEnabled:NO];
    
    spinner = [SpinnerView loadSpinnerIntoView:self.view];
    [spinner setCenter:CGPointMake(self.view.center.x, self.view.center.y-25)];
}

-(void)adjustAdSize {
    /*if (adWhirlView) {
     [UIView beginAnimations:@"AdHide" context:nil];
     [UIView setAnimationDuration:0.2];
     CGRect hiddenFrame = adWhirlView.frame;
     hiddenFrame.origin.y = self.view.bounds.size.height;
     [adWhirlView setFrame:hiddenFrame];
     [UIView commitAnimations];
     }*/
    NSLog(@"Store View is displaying the Ad.");
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
