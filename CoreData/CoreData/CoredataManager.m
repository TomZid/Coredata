//
//  CoredataManager.m
//  CoreData
//  https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/CoreData/Concurrency.html#//apple_ref/doc/uid/TP40001075-CH24-SW3
//  Created by tom on 09/01/2018.
//  Copyright © 2018 TZ. All rights reserved.
//

#import "CoredataManager.h"

static NSString *K_MANAGEDOBJECTMODELEXTENSION = @"momd";
#define SDK_NAME [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleExecutableKey]

@interface CoredataManager ()
@property (nonatomic, readwrite, strong) NSManagedObjectContext *masterContext;
@property (nonatomic, readwrite, strong) NSString *resourceName;
@property (nonatomic, readwrite, strong) NSURL *persistentStoreUrl;

@property (nonatomic, readwrite, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readwrite, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, readwrite, strong) NSManagedObjectContext *mainQueueContext;

@end

@implementation CoredataManager
#pragma mark - getter
- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
    NSURL *bundleUrl = [[NSBundle mainBundle] URLForResource:SDK_NAME
                                               withExtension:@"bundle"];
    NSBundle *bundle = bundleUrl ? [NSBundle bundleWithURL:bundleUrl] : [NSBundle mainBundle];
    NSURL *url = [bundle URLForResource:self.resourceName withExtension:K_MANAGEDOBJECTMODELEXTENSION];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:url];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];

//    //CoreData是建立在SQLite之上的，数据库名称需与Xcdatamodel文件同名
//    NSURL *storeUrl = [[self SDKDocumentDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", self.resourceName]];
//    NSError *error;
//    BOOL res = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error];
//    if (!res) {
//        abort();
//    }

    return _persistentStoreCoordinator;
}

#pragma mark - init
- (instancetype)initWithResourceName:(NSString *)resourceName {
    if (self = [super init]) {
        self.resourceName = resourceName;
        [self configCoredata];
    }
    return self;
}

- (void)configCoredata {
    [self configContext];
    [self configPersistentStoreCoordinator];
}

- (void)configContext {
    //The paramter being passed in as part of the initialization determines the type of XXX is returned.
    _masterContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    _masterContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
    _masterContext.persistentStoreCoordinator = self.persistentStoreCoordinator;

    _mainQueueContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    _mainQueueContext.parentContext = _masterContext;
}

- (void)configPersistentStoreCoordinator {
    BOOL storeWasRecreated = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self.persistentStoreUrl path]]) {
        NSError *storeMetadataError = nil;
        NSDictionary *storeMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:self.persistentStoreUrl options:nil error:&storeMetadataError];

        // If store is incompatible with the managed object model, remove the store file
        if (storeMetadataError || ![self.managedObjectModel isConfiguration:nil compatibleWithStoreMetadata:storeMetadata]) {
            storeWasRecreated = YES;
            NSError *removeStoreError = nil;
            if (![[NSFileManager defaultManager] removeItemAtURL:self.persistentStoreUrl error:&removeStoreError]) {
#ifdef DEBUG
                NSLog(@"Error removing store file at URL '%@': %@, %@", self.persistentStoreUrl, removeStoreError, [removeStoreError userInfo]);
#endif
            }
        }
    }
    NSError *addStoreError = nil;
    NSPersistentStore *store = [self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:self.persistentStoreUrl options:nil error:&addStoreError];
    if (!store) {
#ifdef DEBUG
        NSLog(@"Unable to add store: %@, %@", addStoreError, [addStoreError userInfo]);
#endif
    }
}

#pragma mark - Utility
- (NSURL*)SDKDocumentDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)persistentStoreUrl {
    if (_persistentStoreUrl) {
        return _persistentStoreUrl;
    }
    _persistentStoreUrl = [[self SDKDocumentDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@,sqlite", self.resourceName]];
    return _persistentStoreUrl;
}

#pragma mark - context action
- (void)saveMainContext {
    [self saveContext:self.mainQueueContext];
}

- (void)saveContext:(NSManagedObjectContext*)context {
    if (context && [context hasChanges]) {
        NSError *error = NSError.new;
        BOOL res = [context save:&error];
        if (!res) {
#ifdef DEBUG
            NSLog(@"⚠️⚠️%s \n Error saving context: %@ %@ %@ \n⚠️⚠️", __PRETTY_FUNCTION__, self, error, [error userInfo]);
#endif
        }
        [self saveContext:context.parentContext];
    }
}

- (void)asyncWithBlock:(CoredataRecordHandle)handle {
    if (handle) {
        NSManagedObjectContext *mainContext = self.mainQueueContext;
        [self.mainQueueContext performBlock:^{
            handle(mainContext);
            [self saveContext:mainContext];
        }];
    }
}

- (void)syncWithBlock:(CoredataRecordHandle)handle {
    if (handle) {
        handle(self.mainQueueContext);
        [self saveMainContext];
    }
}

@end
