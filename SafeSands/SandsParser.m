//
//  SandsParser.m
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/19/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import "SandsParser.h"

@implementation SandsParser

@synthesize containerItems, fieldItems;
@synthesize delegate, xmlConnection, xmlData;
@synthesize currentParsedCharacterData, currentItemObject;

NSString *thePath;

-(id)initWithPath:(NSString *)path andDelegate:(id<SandsParserDelegate>)del andFields:(NSArray *)fields andContainers:(NSArray *)containers
{
    thePath=path;
    justGetData = NO;
    currentParsedCharacterData = [[NSMutableString alloc] init];
    thePath = path;
    delegate = del;
    fieldItems = [[NSArray alloc] initWithArray:fields];
    containerItems = [[NSArray alloc] initWithArray:containers];
    NSURLRequest *xmlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString: path]];
    xmlConnection = [[NSURLConnection alloc] initWithRequest:xmlRequest delegate:self];
    NSAssert(xmlConnection != nil, @"Could not establish connection");
    return self;
}

-(id)initWithFilePath:(NSString *)path andDelegate:(id<SandsParserDelegate>)del andFields:(NSArray *)fields andContainers:(NSArray *)containers
{
    thePath=path;
    justGetData = NO;
    currentParsedCharacterData = [[NSMutableString alloc] init];
    thePath = path;
    delegate = del;
    fieldItems = [[NSArray alloc] initWithArray:fields];
    containerItems = [[NSArray alloc] initWithArray:containers];
    xmlData = [NSData dataWithContentsOfFile:path];
    NSLog(@"Have file data: %d bytes", [xmlData length]);
    
    [NSThread detachNewThreadSelector:@selector(parseData:)
                             toTarget:self
                           withObject:xmlData];
    return self;
}

-(id)initWithDataPath:(NSString *)path andDelegate:(id<SandsParserDelegate>)del{
    thePath=path;
    justGetData = YES;
    thePath = path;
    delegate = del;
    NSURLRequest *xmlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString: path]];
    xmlConnection = [[NSURLConnection alloc] initWithRequest:xmlRequest delegate:self];
    NSAssert(xmlConnection != nil, @"Could not establish connection");
    return self;
}

-(void)repeatOperations
{
    NSURLRequest *xmlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString: thePath]];
    xmlConnection = [[NSURLConnection alloc] initWithRequest:xmlRequest delegate:self];
    NSAssert(xmlConnection != nil, @"Could not establish connection");
}

-(void)parseData:(NSData *)data {
    depth=-1;
    currentItemObject = [[NSMutableArray alloc] init];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    [parser parse];
    //NSLog(@"Parsing: %@", thePath);
}

#pragma mark - NSURLConnectionDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if(!xmlData) xmlData = [[NSMutableData alloc] init];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.xmlData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self setXmlConnection:nil];
    
    if (justGetData){
        [delegate retrievedData:xmlData];
        NSLog(@"Have image data, %d bytes", xmlData.length);
    }else{
        [NSThread detachNewThreadSelector:@selector(parseData:) toTarget:self withObject:xmlData];
        NSLog(@"Have xml data, %d bytes", xmlData.length);
    }
    
    [self setXmlData:nil];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self setXmlConnection:nil];
    [self setXmlData:nil];
    [NSException raise:@"Connection Failed" format:@"Reason: %@", [error localizedDescription]];
}

#pragma mark - NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    //NSLog(@"%s %@", __FUNCTION__, elementName);
    
    if ([containerItems containsObject:elementName]){
        [self.currentItemObject addObject:[[NSMutableDictionary alloc] init]];
        depth++;
    }
    else if ([fieldItems containsObject:elementName]) {
        if ([attributeDict objectForKey:@"data"]) {
            [[[self currentItemObject] lastObject] setObject:[NSString stringWithFormat:[attributeDict objectForKey:@"data"]] forKey:elementName];
            //NSLog(@"%@: %@", elementName, [attributeDict objectForKey:@"data"]);
        }
        accumulatingParsedCharacterData = YES;
        // reset character accumulator
        [currentParsedCharacterData setString:@""];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {     
    //NSLog(@"%s (%@) data: %@", __FUNCTION__, elementName, currentParsedCharacterData);
    
    if ([fieldItems containsObject:elementName] && self.currentParsedCharacterData){
        if([[currentItemObject lastObject] objectForKey:elementName]){
            int i=1;
            NSString *newName = [NSString stringWithFormat:@"%@-%d", elementName, i];
            while ([[currentItemObject lastObject] objectForKey:newName]) {
                newName = [NSString stringWithFormat:@"%@-%d", elementName, ++i];
            }
            [[self.currentItemObject lastObject] setObject:self.currentParsedCharacterData forKey:newName];
        }else
            [[self.currentItemObject lastObject] setObject:self.currentParsedCharacterData forKey:elementName];
        currentParsedCharacterData = [[NSMutableString alloc] init];
    }else if ([containerItems containsObject:elementName]){
        [[currentItemObject lastObject] setObject:elementName forKey:@"containerName"];
        if (depth==0){
            NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithDictionary: [currentItemObject objectAtIndex:0]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate elementParsed:result];
            });
        }else 
            [[currentItemObject objectAtIndex:depth-1] setObject:[currentItemObject objectAtIndex:depth] forKey:elementName];
        
        [currentItemObject removeObjectAtIndex:depth];
        depth--;
    }
    // Stop accumulating parsed character data. We won't start again until specific elements begin.
    accumulatingParsedCharacterData = NO;
}

-(void)parserDidEndDocument:(NSXMLParser *)parser
{
    dispatch_async(dispatch_get_main_queue(), ^{[delegate parseComplete];});
}

// The parser delivers parsed character data (PCDATA) in chunks, not necessarily all at once. 
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    //NSLog(@"%s [%@](%@)", __FUNCTION__, accumulatingParsedCharacterData ? @"true" : @"false", string);
    if (accumulatingParsedCharacterData) {
        [self.currentParsedCharacterData appendString:string];
        //NSLog(@"%@", self.currentParsedCharacterData);
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    // We abort parsing if we get more than kMaximumNumberOfItemsToParse. 
    // We use the didAbortParsing flag to avoid treating this as an error. 
    [NSException raise:@"XML Parse Failed" format:@"Reason: %@", [parseError localizedDescription]];
}


@end
