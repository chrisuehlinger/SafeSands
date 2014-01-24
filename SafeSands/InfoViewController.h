//
//  InfoViewController.h
//  SafeSands
//
//  Created by Christopher Uehlinger on 6/14/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoViewController : UIViewController

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *infoLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *backButton;

- (IBAction)dismiss:(id)sender;

@end
