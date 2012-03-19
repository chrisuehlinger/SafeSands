//
//  TidalStation.h
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/13/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreData/CoreData.h>

@interface TidalStation : NSManagedObject{
    
    NSString *name;
    CLLocation *location;
    NSData *locationData;
    NSString *stationID;
    NSNumber *orderingValue;
    NSNumber *latitude;
    NSNumber *longtitude;
}

@property (strong, nonatomic) NSNumber *latitude;
@property (strong, nonatomic) NSNumber *longtitude;
@property (strong, nonatomic) NSNumber *orderingValue;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) NSString *stationID;

-(void)awakeFromFetch;
-(id)initWithName:(NSString *)theName coordinates:(NSString *)coords stationID:(NSString *)stnID;
-(void)setName:(NSString *)theName coordinates:(NSString *)coords stationID:(NSString *)stnID;

@end
