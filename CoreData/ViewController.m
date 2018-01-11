//
//  ViewController.m
//  CoreData
//
//  Created by tom on 09/01/2018.
//  Copyright © 2018 TZ. All rights reserved.
//

#import "ViewController.h"
#import "StudentCoreDataRecord.h"
#import <CoreData/CoreData.h>
#import "Student.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *datasource;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController
#pragma mark - UI
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self requestData];
}

// COREDATA RETRIEVE
- (void)requestData {
    StudentCoreDataRecord *r = [StudentCoreDataRecord share];
    NSArray *array = [r fetchDataRecordResults];
    self.datasource = [array mutableCopy];
    NSLog(@"array == %@", array);
    [self.tableView reloadData];
}

#pragma mark - storyboard
- (IBAction)unwindsegue_viewcontroller:(UIStoryboardSegue*)segue {}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cellID"];
    }
    Student *s = self.datasource[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"ID:%d-age:%d-name:%@", s.studentId, s.studentAge, s.studentName];
    return cell;
}

//- (nullable UISwipeActionsConfiguration *)tableView:(UITableView *)tableView leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(tvos) {
//    // COREDATA UPDATE
//    void (^updateHandle)(NSIndexPath*) = ^(NSIndexPath *indexPath) {
//        Student *s = self.datasource[indexPath.row];
//        s.studentAge = arc4random() % 50;
//        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//
//        NSError *error;
//        BOOL res = [[CoredataManager share].context save:&error];
//        if (res) {
//            NSLog(@"⚽️⚽️Update successFull⚽️⚽️");
//        } else {
//            NSLog(@"⚠️⚠️Error: %@,%@⚠️⚠️",error,[error userInfo]);
//        }
//    };
//
//    if (@available(iOS 11, *)) {
//        UIContextualAction *action = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"UPDATE AGE" handler:^(UIContextualAction * _Nonnull action,
//                                                                                                                  __kindof UIView * _Nonnull sourceView,
//                                                                                                                  void (^ _Nonnull completionHandler)(BOOL)) {
//            if (completionHandler) {
//                completionHandler(YES);
//                updateHandle(indexPath);
//            }
//        }];
//        action.backgroundColor = [UIColor purpleColor];
//        return [UISwipeActionsConfiguration configurationWithActions:@[
//                                                                       action
//                                                                       ]];
//    }
//    return nil;
//}

- (nullable UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(tvos) {
    // COREDATA DELETE
    void (^deleteHandle)(NSIndexPath*) = ^(NSIndexPath *indexPath) {
//        Student *s = self.datasource[indexPath.row];
//        [[CoredataManager share].context deleteObject:s];
//
//        NSError *error;
//        BOOL res = [[CoredataManager share].context save:&error];
//        if (res) {
//            NSLog(@"⚽️⚽️delete successFull⚽️⚽️");
//
//            [self.datasource removeObject:s];
//            [tableView reloadData];
//
//        }else {
//            NSLog(@"⚠️⚠️Error: %@,%@⚠️⚠️",error,[error userInfo]);
//        }

        Student *s = self.datasource[indexPath.row];
        BOOL res = [[StudentCoreDataRecord share] deleteRecoreDatas:@[s]];
        if (res) {
            [self.datasource removeObject:s];
            [tableView reloadData];
        }
    };

    if (@available(iOS 11, *)) {
        return [UISwipeActionsConfiguration configurationWithActions:@[
                                                                       [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"delete" handler:^(UIContextualAction * _Nonnull action,
                                                                                                                                                                                  __kindof UIView * _Nonnull sourceView,
                                                                                                                                                                                  void (^ _Nonnull completionHandler)(BOOL)) {
            if (completionHandler) {
                completionHandler(YES);
                deleteHandle(indexPath);
            }
        }],
                                                                       ]];
    }
    return nil;
}

@end
