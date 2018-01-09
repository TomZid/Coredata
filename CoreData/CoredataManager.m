//
//  CoredataManager.m
//  CoreData
//
//  Created by tom on 09/01/2018.
//  Copyright © 2018 TZ. All rights reserved.
//

#import "CoredataManager.h"

@interface CoredataManager ()
@property (nonatomic, readwrite, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readwrite, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, readwrite, strong) NSManagedObjectContext *context;

@end

@implementation CoredataManager
+ (instancetype)share {
    static id c;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        c = [[CoredataManager alloc] init];
    });
    return c;
}


- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel) {
        return  _managedObjectModel;
    }
    NSURL *modelUrl = [[NSBundle mainBundle] URLForResource:@"CoreData"
                                              withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelUrl];
    return _managedObjectModel;
}

- (NSManagedObjectContext *)context {
    if (_context) {
        return _context;
    }
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    if (coordinator) {
        _context = [[NSManagedObjectContext alloc] init];
        [_context setPersistentStoreCoordinator:coordinator];
    }
    return _context;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    //CoreData是建立在SQLite之上的，数据库名称需与Xcdatamodel文件同名
    NSURL *storeUrl = [[self SDKDocumentDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", ManagerObjectModelFileName]];
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];

    NSError *error = NSError.new;
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        abort();
    }
    return _persistentStoreCoordinator;
}

- (NSURL*)SDKDocumentDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)saveContext {

}
@end
