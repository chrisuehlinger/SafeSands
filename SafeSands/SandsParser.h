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

@end

@interface SandsParser : NSObject <NSURLConnectionDelegate, NSXMLParserDelegate>
{
    id<SandsParserDelegate> delegate;
    NSArray *containerItems;
    NSArray *fieldItems;
    
    // parser properties
    NSMutableString *currentParsedCharacterData;
    NSMutableDictionary *currentItemObject;
    BOOL accumulatingParsedCharacterData;
}

@property (strong, nonatomic) id<SandsParserDelegate> delegate;

@property (strong, nonatomic) NSArray *containerItems;
@property (strong, nonatomic) NSArray *fieldItems;

@property (strong, nonatomic) NSURLConnection *xmlConnection;
@property (strong, nonatomic) NSMutableData *xmlData;

@property (strong, nonatomic) NSMutableString *currentParsedCharacterData;
@property (strong, nonatomic) NSMutableDictionary *currentItemObject;


-(id)initWithPath:(NSString *)path andDelegate:(id<SandsParserDelegate>)del andFields:(NSArray *)fields andContainers:(NSArray *)containers;
-(id)initWithFilePath:(NSString *)path andDelegate:(id<SandsParserDelegate>)del andFields:(NSArray *)fields andContainers:(NSArray *)containers;
-(void)repeatOperations;

@end
