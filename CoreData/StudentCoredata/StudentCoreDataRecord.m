//
//  StudentCoreDataRecord.m
//  CoreData
//
//  Created by tom on 10/01/2018.
//  Copyright © 2018 TZ. All rights reserved.
//

#import "StudentCoreDataRecord.h"
#import "CoredataManager.h"
#import "Student.h"

#define K_ENTITUNAME @"Student"

@interface StudentCoreDataRecord ()
@property (nonatomic, strong) CoredataManager *coreData;
@end

@implementation StudentCoreDataRecord
+ (instancetype)share {
    static id s;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s = [[self alloc] init];
    });
    return s;
}

- (instancetype)init {
    if (self = [super init]) {
        _coreData = [[CoredataManager alloc] initWithResourceName:K_ENTITUNAME];
    }
    return self;
}

@end


@implementation StudentCoreDataRecord (CoreData_create)
- (void)addStudentName:(NSString*)name age:(NSInteger)age identifier:(NSInteger)identifier {
    if (_coreData) {
        [_coreData asyncWithBlock:^(NSManagedObjectContext * _Nonnull context) {
            Student *s = [NSEntityDescription insertNewObjectForEntityForName:K_ENTITUNAME inManagedObjectContext:context];
            s.studentId = identifier;
            s.studentAge = age;
            s.studentName = name;
        }];
    }
}

@end


@implementation StudentCoreDataRecord (CoreData_delete)
- (BOOL)deleteRecoreDatas:(NSArray<Student*>*)array {
    [self.coreData syncWithBlock:^(NSManagedObjectContext * _Nonnull context) {
        [array enumerateObjectsUsingBlock:^(Student * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [context deleteObject:obj];
        }];
    }];
    return true;
}

@end


@implementation StudentCoreDataRecord (CoreData_fetch)
- (NSArray<Student*> *)fetchDataRecordResults {
    return [self fetchDataWithContext:self.coreData.mainQueueContext];
}

- (void)fetchAsyncDataRecordResult:(void(^)(NSArray<Student*>* array))complete {
    __weak typeof(self) ws = self;
    [self.coreData asyncWithBlock:^(NSManagedObjectContext * _Nonnull context) {
        NSArray *array = [ws fetchDataWithContext:context];
        if (complete) {
            complete(array);
        }
    }];
}

- (NSArray<Student*> *)fetchDataWithContext:(NSManagedObjectContext*)context {
    NSFetchRequest *request = [self fetchRequest];
    NSError *error = nil;
    NSArray *array = [self.coreData.mainQueueContext executeFetchRequest:request error:&error];
    if (error) {
#ifdef DEBUG
        NSLog(@"⚠️⚠️ %s \n ERROR:%@ \n", __PRETTY_FUNCTION__, error);
#endif
    }
    return array;
}

- (NSFetchRequest*)fetchRequest {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:K_ENTITUNAME];
    return request;
}

@end


@implementation StudentCoreDataRecord (CoreData_update)
- (void)updateDataRecord:(NSArray<Student*>*)array {
    NSError *error = nil;
    [self.coreData.mainQueueContext save:&error];
}

@end
