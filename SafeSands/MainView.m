//
//  MainView.m
//  SafeSands
//
//  Created by Christopher Uehlinger on 4/16/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import "MainView.h"

@implementation MainView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
}
*/

-(void)drawPlacemark
{
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"sandBackground.jpg"]];
    
    mainLayer = [[CALayer alloc] init];
    [self.layer addSublayer:mainLayer];
    mainLayer.backgroundColor = [UIColor grayColor].CGColor;
    mainLayer.shadowOffset = CGSizeMake(0, 3);
    /*mainLayer.shadowRadius = 5.0;
     mainLayer.shadowColor = [UIColor blackColor].CGColor;
     mainLayer.shadowOpacity = 0.8;*/
    mainLayer.frame = CGRectMake(20, 10, 280, 40);
    //mainLayer.borderColor = [UIColor blackColor].CGColor;
    //mainLayer.borderWidth = 2.0;
    mainLayer.cornerRadius = 10.0;
    mainLayer.zPosition = -10;
}

-(void)animateChange
{
    [UIView animateWithDuration:0.5 animations:^{
        mainLayer.frame = CGRectMake(20, 10, 280, 400);
    }];
}



@end
