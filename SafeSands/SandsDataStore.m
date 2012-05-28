//
//  SandsDataStore.m
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/29/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import "SandsDataStore.h"

@implementation SandsDataStore

@synthesize delegate;
@synthesize count;
@synthesize datatype;
@synthesize databaseBuilt;

-(id)initWithDelegate:(id<SandsDataStoreDelegate>)del andStoreName:(NSString *)name andDataType:(NSString *)type
{
    delegate = del;
    datatype=type;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveChanges) name:@"aboutToEnterBackground" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveChanges) name:@"aboutToTerminate" object:nil];

    model = [NSManagedObjectModel mergedModelFromBundles:nil];

    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    //NSString *dbPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingFormat:@"/%@", name];
    NSString *dbPath = [[NSBundle mainBundle] pathForResource:name ofType:@"data"];
    NSURL *dbURL = [NSURL fileURLWithPath: dbPath];
    NSError *error = nil;
    if(![psc addPersistentStoreWithType:NSSQLiteStoreType
                          configuration:nil
                                    URL:dbURL
                                options:nil
                                  error:&error])
    {[NSException raise:@"Create Failed" format:@"Reason: %@", [error localizedDescription]];}

    NSMutableDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:[psc metadataForPersistentStore:[[psc persistentStores] objectAtIndex:0]]];

    NSDate *dateCompleted = [metadata objectForKey:@"dateCompleted"];

    if (dateCompleted && [dateCompleted timeIntervalSinceNow] > -2592000) {
        NSLog(@"Opening database.");
        databaseBuilt = YES;
        count = [[metadata objectForKey:@"count"] intValue];
    }else {
        NSLog(@"Creating new database.");
        databaseBuilt = NO;
        if ([metadata objectForKey:@"dateStarted"]) {
            NSLog(@"Old Database was corrupt.");
            if(![psc removePersistentStore:[[psc persistentStores] objectAtIndex:0] 
                                     error:&error])
                [NSException raise:@"Removal Failed" format:@"Reason: %@", [error localizedDescription]];
            if(![psc addPersistentStoreWithType:NSSQLiteStoreType
                                  configuration:nil
                                            URL:dbURL
                                        options:nil
                                          error:&error])
                [NSException raise:@"Create Failed" format:@"Reason: %@", [error localizedDescription]];
            metadata = [[NSMutableDictionary alloc] initWithDictionary:[psc metadataForPersistentStore:[[psc persistentStores] objectAtIndex:0]]];
        }
    }

    context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator:psc];
    [context setUndoManager:nil];

    if (!databaseBuilt) {
        [metadata setObject:[[NSDate alloc] initWithTimeIntervalSinceNow:0] forKey:@"dateStarted"];
        [[context persistentStoreCoordinator] setMetadata:metadata forPersistentStore:[[[context persistentStoreCoordinator] persistentStores] objectAtIndex:0]];
        [self saveChanges];
    }
    
    return self;
}

#pragma mark - Core Data Methods

-(BOOL)saveChanges
{
    NSError *err = nil;
    BOOL successful = [context save:&err];
    if (!successful) {
        NSLog(@"Error saving: %@", [err localizedDescription]);
    }
    return successful;
}

-(NSArray *)fetchItemsIfNecessary
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *e = [[model entitiesByName] objectForKey:datatype];
    [request setEntity:e];
    
    NSSortDescriptor *sd = [NSSortDescriptor
                            sortDescriptorWithKey:@"orderingValue"
                            ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sd]];
    NSError *error;
    NSArray *result = [context executeFetchRequest:request error:&error];
    if (!result) {
        [NSException raise:@"Fetch failed"
                    format:@"Reason: %@", [error localizedDescription]];
    }
    NSArray *items = [[NSMutableArray alloc] initWithArray:result];
    count = [items count];
    //NSLog(@"Count: %d", count);
    return items;
}

-(NSManagedObject *)fetchItem:(int)orderingValue
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *e = [[model entitiesByName] objectForKey:datatype];
    [request setEntity:e];
    NSPredicate *p = [NSPredicate predicateWithFormat:@"orderingValue == %d", orderingValue];
    [request setPredicate:p];
    
    NSError *error;
    NSArray *result = [context executeFetchRequest:request error:&error];
    if (!result) {
        [NSException raise:@"Fetch failed"
                    format:@"Reason: %@", [error localizedDescription]];
    }else if ([result count] == 0) {
        [NSException raise:@"No items fetched"
                    format:@"Reason: %@", [error localizedDescription]];
    }
    return [result objectAtIndex:0];
}

- (NSManagedObject *)createItem
{
    NSManagedObject *item = [NSEntityDescription insertNewObjectForEntityForName:datatype
                                                             inManagedObjectContext:context];
    count++;
    return item;
}

- (void)removeItem:(NSManagedObject *)item
{
    [context deleteObject:item];
    count--;
}

-(void)databaseComplete
{
    NSMutableDictionary *newMetadata = [[NSMutableDictionary alloc] initWithDictionary:[[context persistentStoreCoordinator] metadataForPersistentStore:[[[context persistentStoreCoordinator] persistentStores] objectAtIndex:0]]];
    [newMetadata setObject:[[NSDate alloc] initWithTimeIntervalSinceNow:0] forKey:@"dateCompleted"];
    [newMetadata setObject:[NSNumber numberWithInt:count] forKey:@"count"];
    [[context persistentStoreCoordinator] setMetadata:newMetadata forPersistentStore:[[[context persistentStoreCoordinator] persistentStores] objectAtIndex:0]];
    [self saveChanges];
    databaseBuilt=YES;
}

@end
