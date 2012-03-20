//
//  TidalStationDB.h
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/13/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreData/CoreData.h>
#import "TidalStation.h"
#import "SandsParser.h"

@protocol tidalStationDBDelegate <NSObject>

-(void)databaseBuilt;

@end

@interface TidalStationDB : NSObject<SandsParserDelegate>{
    
    id<tidalStationDBDelegate> delegate;
    SandsParser *stationParser;
    
    int count;
    NSArray *fieldElements;
    NSManagedObjectContext *context;
    NSManagedObjectModel *model;
}

@property (strong, nonatomic) id<tidalStationDBDelegate> delegate;

@property (strong, nonatomic) NSURLConnection *kmzConnection;
@property (strong, nonatomic) NSMutableData *kmzData;

-(id)initWithDelegate:(id<tidalStationDBDelegate>)del;
-(NSArray *)fetchStationsIfNecessary;
-(TidalStation *)closestStationTo:(CLPlacemark *)placemark;
-(TidalStation *)fetchStation:(int)orderingValue;

@end
