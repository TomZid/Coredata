//
//  CoredataManager.h
//  CoreData
//
//  Created by tom on 09/01/2018.
//  Copyright © 2018 TZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^CoredataRecordHandle)(NSManagedObjectContext* context);

@interface CoredataManager : NSObject

/**
 Create a Coredata Database.

 @param resourceName The name of the 'momd' & 'sqlite',
 @return The CoredataManager instance with concrete sqlite and momd named given resourceName.
 */
- (instancetype)initWithResourceName:(NSString *)resourceName;

@property (nonatomic, readonly, strong) NSManagedObjectContext *mainQueueContext;


/**
 The name of the sqlite & momd.
 */
@property (nonatomic, readonly) NSString *resourceName;


/**
 The path to which
 */
@property (nonatomic, readonly) NSURL *persistentStoreUrl;


/**
 Perform coredata currently.

 @param handle The scope whete descript an entity (NSEntityDescription*) in Core Data.
 */
- (void)asyncWithBlock:(CoredataRecordHandle)handle;

/**
 Perform coredata serially.

 @param handle The scope whete descript an entity (NSEntityDescription*) in Core Data.
 */
- (void)syncWithBlock:(CoredataRecordHandle)handle;

@end

NS_ASSUME_NONNULL_END
