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
#import "TidalReading.h"

@protocol beachDelegate
-(void)foundPlacemark:(NSString *)newText;
-(void)foundWeather:(NSString *)newText andImage:(UIImage *)theImage;
-(void)foundTides:(NSString *)newText;
//-(void)foundWarningst;
@end

@interface Beach : NSObject<CLLocationManagerDelegate, weatherDelegate, tidalDelegate> 
{
    id<beachDelegate> delegate;
    CLPlacemark *placemark;
    Weather *weather;
    TidalReading *reading;
    
    CLGeocoder *geocoder;
    CLLocationManager *locationManager;
}

@property (nonatomic, strong) id<beachDelegate> delegate;
@property (strong, nonatomic) CLPlacemark *placemark;
@property (strong, nonatomic) Weather *weather;
@property (strong, nonatomic) TidalReading *reading;

- (id)initWithString:(NSString *)locationString andDelegate:(id<beachDelegate>)del;

@end