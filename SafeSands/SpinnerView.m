//
//  SpinnerView.m
//  SafeSands
//
//  Created by Chris Uehlinger on 4/16/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import "SpinnerView.h"
#import <QuartzCore/QuartzCore.h>

@implementation SpinnerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+(SpinnerView *)loadSpinnerIntoView:(UIView *)superView{
	// Create a new view with the same frame size as the superView
    CGRect frame = CGRectMake(0, 0, 200, 200);
	SpinnerView *spinnerView = [[SpinnerView alloc] initWithFrame:frame];
    spinnerView.center = superView.center;
	// If something's gone wrong, abort!
	if(!spinnerView){ return nil; }

	// Add the spinner view to the superView. Boom.
	[superView addSubview:spinnerView];
    if(!spinnerView){ return nil; }
    
    CALayer *backgroundLayer = [CALayer layer];
    backgroundLayer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6].CGColor;
    backgroundLayer.shadowOffset = CGSizeMake(0, 3);
    backgroundLayer.frame = frame;
    backgroundLayer.cornerRadius = 10.0;
    [spinnerView.layer addSublayer:backgroundLayer];
    /*// Create a new image view, from the image made by our gradient method
    CALayer *background = [CALayer layer];
    [background setContents:(id)[[spinnerView addBackground] CGImage]];
	// Make a little bit of the superView show through
    //background.opacity = 0.7;
    background.cornerRadius = 10;
    [spinnerView.layer addSublayer:background];*/
    
	// This is the new stuff here ;)
    UIActivityIndicatorView *indicator =
    [[UIActivityIndicatorView alloc]
      initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
	// Set the resizing mask so it's not stretched
    /*indicator.autoresizingMask =
    UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleBottomMargin |
    UIViewAutoresizingFlexibleLeftMargin;*/
	// Place it in the middle of the view
    indicator.center = CGPointMake(spinnerView.center.x-spinnerView.frame.origin.x, spinnerView.center.y-spinnerView.frame.origin.y);
	// Add it into the spinnerView
    [spinnerView addSubview:indicator];
	// Start it spinning! Don't miss this step
	[indicator startAnimating];
    
    // Create a new animation
    CATransition *animation = [CATransition animation];
	// Set the type to a nice wee fade
	[animation setType:kCATransitionFade];
	// Add it to the superView
	[[superView layer] addAnimation:animation forKey:@"layerAnimation"];
    
	return spinnerView;
}

-(void)removeSpinner{
    // Add this in at the top of the method. If you place it after you've remove the view from the superView it won't work!
    CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[[[self superview] layer] addAnimation:animation forKey:@"layerAnimation"];
	// Take me the hells out of the superView!
	[super removeFromSuperview];
}

- (UIImage *)addBackground{
	// Create an image context (think of this as a canvas for our masterpiece) the same size as the view
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 1);
	// Our gradient only has two locations - start and finish. More complex gradients might have more colours
    size_t num_locations = 2;
	// The location of the colors is at the start and end
    CGFloat locations[2] = { 0.0, 1.0 };
	// These are the colors! That's two RBGA values
    CGFloat components[8] = {
        0.4,0.4,0.4, 0.8,
        0.1,0.1,0.1, 0.5 };
	// Create a color space
    CGColorSpaceRef myColorspace = CGColorSpaceCreateDeviceRGB();
	// Create a gradient with the values we've set up
    CGGradientRef myGradient = CGGradientCreateWithColorComponents (myColorspace, components, locations, num_locations);
	// Set the radius to a nice size, 80% of the width. You can adjust this
    float myRadius = (self.bounds.size.width*.8)/2;
	// Now we draw the gradient into the context. Think painting onto the canvas
    CGContextDrawRadialGradient (UIGraphicsGetCurrentContext(), myGradient, self.center, 0, self.center, myRadius, kCGGradientDrawsAfterEndLocation);
	// Rip the 'canvas' into a UIImage object
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	// And release memory
    CGColorSpaceRelease(myColorspace);
    CGGradientRelease(myGradient);
    UIGraphicsEndImageContext();
	// … obvious.
    return image;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
