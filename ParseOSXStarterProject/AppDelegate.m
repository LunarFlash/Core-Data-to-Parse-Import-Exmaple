#import <ParseOSX/Parse.h>

#import "AppDelegate.h"
#import "PlaceMgr.h"
#import "Place.h"
#import "TagMgr.h"
#import "Tag.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize places;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // ****************************************************************************
    // Uncomment and fill in with your Parse credentials:
    // [Parse setApplicationId:@"your_application_id" clientKey:@"your_client_key"];
    //
    // If you are using Facebook, uncomment and fill in with your Facebook App Id:
    // [PFFacebookUtils initializeWithApplicationId:@"your_facebook_app_id"];
    // ****************************************************************************
    
    
    
    [PFUser enableAutomaticUser];

    //PFACL *defaultACL = [PFACL ACL];

    // If you would like all objects to be private by default, remove this line.
    //[defaultACL setPublicReadAccess:YES];

    //[PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];

    //[PFAnalytics trackAppOpenedWithLaunchOptions:nil];
    
    
    // -- Parse import code starts here
    // 1 Grab an array of all the places in the db
    
    
    //Core Data
    NSManagedObjectContext *context;
    
    if (context == nil) {
        context = [(AppDelegate *)[[NSApplication sharedApplication] delegate] managedObjectContext];
    }
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Place"
                                              inManagedObjectContext:context];
    
    // Create fetchrequest to fetch data
    // Test listing all Places from the store
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
   
    
    [fetchRequest setEntity:entity];
    NSError *error;
    places = [context executeFetchRequest:fetchRequest error:&error];
  
    /*

    @dynamic latitude;
    @dynamic longitude;
 
 
  
   
    @dynamic tags;
    */
    
    
    [places enumerateObjectsUsingBlock:^(Place *place, NSUInteger idx, BOOL *stop) {
        [PlaceMgr NSLogMe:place];
        
        // 1 First see if this place already exists in Parse
        
        
        
        PFObject *pfPlace = [PFObject objectWithClassName:@"Place"];
        if (place.name) pfPlace[@"name"] = place.name;
        if (place.details) pfPlace[@"details"] = place.details;
        if (place.address) pfPlace[@"address"] = place.address;
        if (place.city) pfPlace[@"city"] = place.city;
        if (place.country) pfPlace[@"country"] = place.country;
        if (place.phone) pfPlace[@"phone"] = place.phone;
        if (place.state) pfPlace[@"state"] = place.state;
        if (place.website) pfPlace[@"website"] = place.website;
        if (place.zip) pfPlace[@"zip"] = place.zip;
        if (place.type) pfPlace[@"type"] = place.type;
        //if (place.tags) pfPlace[@"tags"] = [place.tags allObjects];
        
        if (place.latitude && place.longitude) {
        PFGeoPoint *coordinates = [PFGeoPoint geoPointWithLatitude:[place.latitude doubleValue] longitude:[place.longitude doubleValue]];
        pfPlace[@"coordinates"] = coordinates;
        }
       
        
        
        [pfPlace saveInBackground];
        
        
    }];
    
    
    
    
    
    
    
    
    
    
}


- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack
// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Places" withExtension:@"mom"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}



// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    //sql lite has 3 files in ios 7 so we need to copy them if they dont already exist.
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Eleuthera.sqlite"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]]) {
        NSURL *preloadURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Places" ofType:@"sqlite"]];
        
        NSError* err = nil;
        
        if (![[NSFileManager defaultManager] copyItemAtURL:preloadURL toURL:storeURL error:&err]) {
            NSLog(@"Oops, could copy preloaded data");
        }
    }
    
    NSURL *walURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Eleuthera.sqlite-wal"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[walURL path]]) {
        NSURL *preloadURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Places" ofType:@"sqlite-wal"]];
        
        NSError* err = nil;
        
        if (![[NSFileManager defaultManager] copyItemAtURL:preloadURL toURL:walURL error:&err]) {
            NSLog(@"Oops, could copy preloaded data");
        }
    }
    /*//shm file is actually not needed
     NSURL *shmURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Eleuthera.sqlite-shm"];
     if (![[NSFileManager defaultManager] fileExistsAtPath:[shmURL path]]) {
     NSURL *preloadURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Places" ofType:@"sqlite-shm"]];
     
     NSError* err = nil;
     
     if (![[NSFileManager defaultManager] copyItemAtURL:preloadURL toURL:shmURL error:&err]) {
     NSLog(@"Oops, could copy preloaded data");
     }
     }
     */
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}



#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
@end
