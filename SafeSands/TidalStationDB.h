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

@protocol tidalStationDBDelegate <NSObject>

-(void)databaseBuilt;

@end

@interface TidalStationDB : NSObject<NSXMLParserDelegate>{
    
    id<tidalStationDBDelegate> delegate;
    
    int count;
    NSArray *fieldElements;
    NSManagedObjectContext *context;
    NSManagedObjectModel *model;
    
    // parser properties
    NSMutableString *currentParsedCharacterData;
    NSMutableDictionary *currentItemObject;
    BOOL accumulatingParsedCharacterData;
    BOOL didAbortParsing;
}

@property (strong, nonatomic) id<tidalStationDBDelegate> delegate;

@property (strong, nonatomic) NSURLConnection *kmzConnection;
@property (strong, nonatomic) NSMutableData *kmzData;

@property (strong, nonatomic) NSMutableString *currentParsedCharacterData;
@property (strong, nonatomic) NSMutableDictionary *currentItemObject;

-(id)initWithDelegate:(id<tidalStationDBDelegate>)del;
-(NSArray *)fetchStationsIfNecessary;
-(TidalStation *)closestStationTo:(CLPlacemark *)placemark;
-(TidalStation *)fetchStation:(int)orderingValue;

@end
