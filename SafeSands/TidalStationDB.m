//
//  TidalStationDB.m
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/13/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import "TidalStationDB.h"

@implementation TidalStationDB

@synthesize kmzConnection, kmzData;
@synthesize delegate;

static NSString * const coopsURL = @"http://tidesandcurrents.noaa.gov/cdata/StationListFormat?type=Current%20Data&filter=active&format=kml";
BOOL databaseBuilt;

-(id)initWithDelegate:(id<tidalStationDBDelegate>)del
{
    delegate = del;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveChanges) name:@"aboutToEnterBackground" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveChanges) name:@"aboutToTerminate" object:nil];
    
    model = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    NSString *dbPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingFormat:@"/tidalStations.data"];
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
    
    /*NSURLRequest *kmzRequest = [NSURLRequest requestWithURL:[NSURL URLWithString: coopsURL]];
    kmzConnection = [[NSURLConnection alloc] initWithRequest:kmzRequest delegate:self];
    NSAssert(kmzConnection != nil, @"Could not establish connection");*/
    
    if (!databaseBuilt) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [metadata setObject:[[NSDate alloc] initWithTimeIntervalSinceNow:0] forKey:@"dateStarted"];
        [[context persistentStoreCoordinator] setMetadata:metadata forPersistentStore:[[[context persistentStoreCoordinator] persistentStores] objectAtIndex:0]];
        [self saveChanges];
        fieldElements = [NSArray arrayWithObjects:@"nametag", @"coordinates", @"stnid", nil];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"pred" ofType:@"kml"];
        stationParser = [[SandsParser alloc] initWithFilePath:filePath
                                                  andDelegate:self
                                                    andFields:fieldElements
                                                andContainers:[NSArray arrayWithObject:@"Placemark"]];
    }else
        [NSThread detachNewThreadSelector:@selector(databaseAlreadyBuilt) toTarget:self withObject:nil];
    
    return self;
}

-(void)databaseAlreadyBuilt
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{[delegate databaseBuilt];});
}

-(TidalStation *)closestStationTo:(CLPlacemark *)placemark
{
    NSInteger minDist = INFINITY;
    TidalStation *closestStation;
    while (databaseBuilt == NO) {
        NSLog(@"Station DB not built.");
        [NSThread sleepForTimeInterval:1.0];
    }
    
    int i;
    for (i=1; i<count; i++) {
        TidalStation *thisStation = [self fetchStation:i];
        NSInteger thisDist = [placemark.location distanceFromLocation:thisStation.location];
        if( thisDist < minDist && thisDist > -1) {
            closestStation = thisStation;
            minDist = thisDist;
            //NSLog(@"%d %@ %d", i, [closestStation name], minDist);
        }
    }
    return closestStation;
}

#pragma mark - SandsParserDelegate methods

-(void)elementParsed:(NSMutableDictionary *)element
{
    [[self createStation] setName:[element objectForKey:@"nametag"]
                      coordinates:[element objectForKey:@"coordinates"]
                        stationID:[element objectForKey:@"stnid"]];
}

-(void)parseComplete
{
    
    NSMutableDictionary *newMetadata = [[NSMutableDictionary alloc] initWithDictionary:[[context persistentStoreCoordinator] metadataForPersistentStore:[[[context persistentStoreCoordinator] persistentStores] objectAtIndex:0]]];
    [newMetadata setObject:[[NSDate alloc] initWithTimeIntervalSinceNow:0] forKey:@"dateCompleted"];
    [newMetadata setObject:[NSNumber numberWithInt:count] forKey:@"count"];
    [[context persistentStoreCoordinator] setMetadata:newMetadata forPersistentStore:[[[context persistentStoreCoordinator] persistentStores] objectAtIndex:0]];
    [self saveChanges];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    databaseBuilt=YES;
    NSLog(@"Station DB built.");
    [delegate databaseBuilt];
}

-(void)retrievedImageData:(NSData *)data
{
    NSLog(@"This shouldn't happen: TidalStationDB");
}

#pragma mark - CoreData methods

-(BOOL)saveChanges
{
    NSError *err = nil;
    BOOL successful = [context save:&err];
    if (!successful) {
        NSLog(@"Error saving: %@", [err localizedDescription]);
    }
    return successful;
}
                       
-(TidalStation *)fetchStation:(int)orderingValue
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *e = [[model entitiesByName] objectForKey:@"TidalStation"];
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

- (NSArray *)fetchStationsIfNecessary
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *e = [[model entitiesByName] objectForKey:@"TidalStation"];
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
    NSArray *stations = [[NSMutableArray alloc] initWithArray:result];
    count = [stations count];
    NSLog(@"Count: %d", count);
    return stations;
}

- (TidalStation *)createStation
{
    TidalStation *theStation = [NSEntityDescription insertNewObjectForEntityForName:@"TidalStation"
                                                  inManagedObjectContext:context];
    count++;
    [theStation setOrderingValue:[NSNumber numberWithInt:count]];
    return theStation;
}

- (void)removeStation:(TidalStation *)theStation
{
    [context deleteObject:theStation];
    count--;
}

@end
