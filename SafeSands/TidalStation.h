//
//  TidalStation.h
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/13/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface TidalStation : NSObject{
    NSString *name;
    CLLocation *location;
    NSString *stationID;
}

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) NSString *stationID;

-(id)initWithName:(NSString *)theName coordinates:(NSString *)coords stationID:(NSString *)stnID;

@end
