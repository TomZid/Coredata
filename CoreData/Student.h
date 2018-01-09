//
//  Student.h
//  CoreData
//
//  Created by tom on 09/01/2018.
//  Copyright © 2018 TZ. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface Student : NSManagedObject
@property (nonatomic, assign) int16_t studentId;
@property (nonatomic, assign) int16_t studentAge;
@property (nonatomic, strong) NSString *studentName;
@end
