//
//  XMLParser.h
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/19/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SandsParserDelegate <NSObject>
-(void)elementParsed:(NSMutableDictionary *)element;
-(void)parseComplete;
-(void)retrievedData:(NSData *)data;
-(void)handleConnectionError;
@end

@interface SandsParser : NSObject <NSURLConnectionDelegate, NSXMLParserDelegate>
{
    NSArray *containerItems;
    NSArray *fieldItems;
    bool justGetData;
    NSString *thePath;
    BOOL accumulatingParsedCharacterData;
    int depth;
}

@property (weak) id<SandsParserDelegate> delegate;

@property (strong, nonatomic) NSArray *containerItems;
@property (strong, nonatomic) NSArray *fieldItems;

@property (strong, nonatomic) NSURLConnection *xmlConnection;
@property (strong, nonatomic) NSMutableData *xmlData;

@property (strong, nonatomic) NSMutableString *currentParsedCharacterData;
@property (strong, nonatomic) NSMutableArray *currentItemObject;

-(id)initWithDataPath:(NSString *)path andDelegate:(id<SandsParserDelegate>)del;
-(id)initWithPath:(NSString *)path andDelegate:(id<SandsParserDelegate>)del andFields:(NSArray *)fields andContainers:(NSArray *)containers;
-(id)initWithFilePath:(NSString *)path andDelegate:(id<SandsParserDelegate>)del andFields:(NSArray *)fields andContainers:(NSArray *)containers;
-(void)repeatOperations;

@end
