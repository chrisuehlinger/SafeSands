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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prepareToDie) name:@"aboutToEnterBackground" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prepareToDie) name:@"aboutToTerminate" object:nil];
    
    model = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    NSString *dbPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingFormat:@"/tidalStations.data"];
    NSURL *dbURL = [NSURL fileURLWithPath: dbPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    
    if ([fileManager fileExistsAtPath:dbPath]) {
        NSLog(@"Opening database.");
        databaseBuilt = YES;
    }else {
        NSLog(@"Creating new database.");
        databaseBuilt = NO;
    }
    
    if(![psc addPersistentStoreWithType:NSSQLiteStoreType
                          configuration:nil
                                    URL:dbURL
                                options:nil
                                  error:&error])
    {[NSException raise:@"Create Failed" format:@"Reason: %@", [error localizedDescription]];}
    
    context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator:psc];
    [context setUndoManager:nil];
    
    fieldElements = [NSArray arrayWithObjects:@"nametag", @"coordinates", @"stnid", nil];
    
    /*NSURLRequest *kmzRequest = [NSURLRequest requestWithURL:[NSURL URLWithString: coopsURL]];
    kmzConnection = [[NSURLConnection alloc] initWithRequest:kmzRequest delegate:self];
    NSAssert(kmzConnection != nil, @"Could not establish connection");*/
    
    if (!databaseBuilt) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"pred" ofType:@"kml"];
        stationParser = [[SandsParser alloc] initWithFilePath:filePath
                                                  andDelegate:self
                                                    andFields:fieldElements
                                                andContainers:[NSArray arrayWithObject:@"Placemark"]];
    }else{
        NSLog(@"Moving on!");
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:@"TidalStation" inManagedObjectContext:context]];
        
        [request setIncludesSubentities:NO]; //Omit subentities. Default is YES (i.e. include subentities)
        
        NSError *err;
        count = [context countForFetchRequest:request error:&err];
        NSLog(@"count = %d", count);
        [NSThread detachNewThreadSelector:@selector(databaseAlreadyBuilt) toTarget:self withObject:nil];
    }
    
    return self;
}

-(void)databaseAlreadyBuilt
{
    [NSThread sleepForTimeInterval:1.0];
    dispatch_async(dispatch_get_main_queue(), ^{
        [delegate databaseBuilt];
    });
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
    [self saveChanges];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    databaseBuilt=YES;
    NSLog(@"Station DB built.");
    [delegate databaseBuilt];
}

#pragma mark - CoreData methods

-(void)prepareToDie;
{
    NSLog(@"Saving changes before termination.");
    [self saveChanges];
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

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
