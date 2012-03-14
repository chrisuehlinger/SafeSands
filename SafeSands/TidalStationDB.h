//
//  TidalStationDB.h
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/13/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "TidalStation.h"
#import "TidalReading.h"

@protocol tidalStationDBDelegate <NSObject>

-(void)databaseBuilt;

@end

@interface TidalStationDB : NSObject<NSXMLParserDelegate>{
    
    id<tidalStationDBDelegate> delegate;
    
    NSArray *fieldElements;
    NSMutableArray *stations;
    
    // parser properties
    NSMutableString *currentParsedCharacterData;
    NSMutableDictionary *currentItemObject;
    BOOL accumulatingParsedCharacterData;
    BOOL didAbortParsing;
}

@property (strong, nonatomic) id<tidalStationDBDelegate> delegate;

@property (strong, nonatomic) NSMutableString *currentParsedCharacterData;
@property (strong, nonatomic) NSMutableDictionary *currentItemObject;

-(id)initWithDelegate:(id)del;
-(TidalReading *)retrieveTidalData:(CLPlacemark *)placemark;

@end
