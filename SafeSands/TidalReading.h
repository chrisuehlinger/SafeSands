//
//  TidalReading.h
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/13/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "TidalStation.h"
#import "TidalStationDB.h"

@protocol tidalDelegate
-(void)foundTides;
@end

@interface TidalReading : NSObject<tidalStationDBDelegate, NSURLConnectionDelegate, NSXMLParserDelegate>{
    
    id<tidalDelegate> delegate;
    NSMutableArray *readings;
    
    TidalStationDB *tidalDB;
    TidalStation *station;
    
    NSURLConnection *tideConnection;
    NSMutableData *tideData;
    
    NSArray * fieldElements;
    
    // parser properties
    NSMutableString *currentParsedCharacterData;
    NSMutableDictionary *currentItemObject;
    BOOL accumulatingParsedCharacterData;
}

@property (strong, nonatomic) id<tidalDelegate> delegate;
@property (strong, nonatomic) NSMutableArray *readings;
@property (strong, nonatomic) NSURLConnection *tideConnection;
@property (strong, nonatomic) NSMutableData *tideData;
@property (strong, nonatomic) TidalStationDB *tidalDB;

@property (nonatomic, retain) NSMutableString *currentParsedCharacterData;
@property (nonatomic, retain) NSMutableDictionary *currentItemObject;

-(id)initWithPlacemark:(CLPlacemark *)placemark;// andTidalDB:(TidalStationDB *)database;
-(void)databaseBuilt;

@end
