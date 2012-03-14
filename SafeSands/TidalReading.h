//
//  TidalReading.h
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/13/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TidalReading : NSObject<NSURLConnectionDelegate, NSXMLParserDelegate>{
    
    NSMutableArray *readings;
    
    NSURLConnection *tideConnection;
    NSMutableData *tideData;
    
    NSArray * fieldElements;
    
    // parser properties
    NSMutableString *currentParsedCharacterData;
    NSMutableDictionary *currentItemObject;
    BOOL accumulatingParsedCharacterData;
}

@property (strong, nonatomic) NSMutableArray *readings;
@property (strong, nonatomic) NSURLConnection *tideConnection;
@property (strong, nonatomic) NSMutableData *tideData;

@property (nonatomic, retain) NSMutableString *currentParsedCharacterData;
@property (nonatomic, retain) NSMutableDictionary *currentItemObject;

-(id)initWithStationID:(NSString *)stnID;

@end
