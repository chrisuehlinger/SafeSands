//
//  Alerts.h
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/29/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "SandsParser.h"

@protocol AlertsDelegate <NSObject>
-(void)foundAlerts;
-(void)handleError:(SandsError)error;
@end

@interface Alerts : NSObject<SandsParserDelegate>{
    NSMutableArray *alerts;
    CLPlacemark *placemark;
    NSArray *fieldElements;
    NSString *headlines;
}

@property (weak) id<AlertsDelegate> delegate;

@property (strong, nonatomic) SandsParser *alertParser;
@property (strong, nonatomic) CLPlacemark *placemark;
@property (strong, nonatomic) NSMutableArray *alerts;
@property (strong, nonatomic) NSString *headlines;

-(id)initWithPlacemark:(CLPlacemark *)p andDelegate:(id<AlertsDelegate>)del;


@end
