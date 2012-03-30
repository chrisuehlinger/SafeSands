//
//  WaterTempStation.h
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/29/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

@class WaterTempStation;

@protocol WaterTempStationDelegate <NSObject>

-(void)stationLocationFound:(WaterTempStation *)theStation;

@end

@interface WaterTempStation : NSManagedObject{
    id<WaterTempStationDelegate> delegate;
    NSString *name;
    NSNumber * latitude;
    CLLocation *location;
    NSNumber * longitude;
    NSNumber * orderingValue;
    NSString * stationID;
    
    CLGeocoder *geocoder;
}

@property (strong, nonatomic) id<WaterTempStationDelegate> delegate;
@property (strong, nonatomic) NSString * name;
@property (strong, nonatomic) NSNumber * latitude;
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) NSNumber * longitude;
@property (strong, nonatomic) NSNumber * orderingValue;
@property (strong, nonatomic) NSString * stationID;

-(void)awakeFromFetch;
-(id)initWithName:(NSString *)theName stationID:(NSString *)stnID andDelegate:(id<WaterTempStationDelegate>)del;
-(void)setName:(NSString *)theName stationID:(NSString *)stnID andDelegate:(id<WaterTempStationDelegate>)del;

@end
