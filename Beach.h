//
//  Beach.h
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/13/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Weather.h"

@protocol beachDelegate
-(void)upDateText:(NSString *)newText;
@end

@interface Beach : NSObject<CLLocationManagerDelegate, weatherDelegate>
{
    id<beachDelegate> delegate;
    CLPlacemark *placemark;
    Weather *weather;
    
    CLGeocoder *geocoder;
    CLLocationManager *locationManager;
}

@property (nonatomic, strong) id<beachDelegate> delegate;
@property (strong, nonatomic) CLPlacemark *placemark;
@property (strong, nonatomic) Weather *weather;

- (id)initWithString:(NSString *)locationString;

@end
