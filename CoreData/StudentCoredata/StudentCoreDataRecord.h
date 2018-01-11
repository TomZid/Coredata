//
//  StudentCoreDataRecord.h
//  CoreData
//
//  Created by tom on 10/01/2018.
//  Copyright © 2018 TZ. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Student;

@interface StudentCoreDataRecord : NSObject
+ (instancetype)share;

- (void)addStudentName:(NSString*)name age:(NSInteger)age identifier:(NSInteger)identifier;
@end

@interface StudentCoreDataRecord (CoreData_delete)
- (BOOL)deleteRecoreDatas:(NSArray<Student*>*)array;
@end

@interface StudentCoreDataRecord (CoreData_fetch)
- (NSArray<Student*> *)fetchDataRecordResults;
@end
