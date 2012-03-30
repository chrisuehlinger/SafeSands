//
//  SandsDataStore.h
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/29/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@protocol SandsDataStoreDelegate <NSObject>

@end

@interface SandsDataStore : NSObject{
    id<SandsDataStoreDelegate> delegate;
    
    NSString *datatype;
    
    BOOL databaseBuilt;
    int count;
    NSManagedObjectContext *context;
    NSManagedObjectModel *model;
}

@property int count;
@property BOOL databaseBuilt;
@property (strong, nonatomic) id<SandsDataStoreDelegate> delegate;
@property (strong, nonatomic) NSString *datatype;

-(id)initWithDelegate:(id<SandsDataStoreDelegate>)del andStoreName:(NSString *)name andDataType:(NSString *)type;
-(NSArray *)fetchItemsIfNecessary;
-(NSManagedObject *)fetchItem:(int)orderingValue;
- (NSManagedObject *)createItem;
- (void)removeItem:(NSManagedObject *)item;
-(void)databaseComplete;
@end
