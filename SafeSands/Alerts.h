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

@end

@interface Alerts : NSObject<SandsParserDelegate>{
    id<AlertsDelegate> delegate;
    NSMutableArray *alerts;
    CLPlacemark *placemark;
    
    SandsParser *alertParser;
    NSArray *fieldElements;
    NSString *headlines;
}

@property (strong, nonatomic) id<AlertsDelegate> delegate;

@property (strong, nonatomic) CLPlacemark *placemark;
@property (strong, nonatomic) NSMutableArray *alerts;
@property (strong, nonatomic) NSString *headlines;

-(id)initWithPlacemark:(CLPlacemark *)p andDelegate:(id<AlertsDelegate>)del;


@end
