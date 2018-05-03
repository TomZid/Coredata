//
//  ViewController.m
//  CoreData
//
//  Created by tom on 09/01/2018.
//  Copyright © 2018 TZ. All rights reserved.
//

#import "ViewController.h"
#import "StudentCoreDataRecord.h"
#import "Student.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
{
    UIRefreshControl *_refresh;
}
@property (nonatomic, strong) NSMutableArray *datasource;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController
#pragma mark - UI
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self requestData];
}

- (void)configUI {
    _refresh = UIRefreshControl.new;
    [_refresh setTintColor:[UIColor orangeColor]];
    [_refresh setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Release🎉"]];
    [_refresh addTarget:self action:@selector(refreshAction) forControlEvents:UIControlEventValueChanged];
    self.tableView.refreshControl = _refresh;
}

// COREDATA RETRIEVE
- (void)requestData {
    StudentCoreDataRecord *s = [StudentCoreDataRecord share];
    __weak typeof(self) ws = self;
    [s fetchAsyncDataRecordResult:^(NSArray<Student *> *array) {
        __strong typeof(ws) ss = ws;
        ss.datasource = [array mutableCopy];
        [ss.tableView reloadData];
        [ss->_refresh endRefreshing];
    }];
}

- (void)refreshAction  {
    [self requestData];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

- (nullable UISwipeActionsConfiguration *)tableView:(UITableView *)tableView leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(tvos) {
    // COREDATA UPDATE
    void (^updateHandle)(NSIndexPath*) = ^(NSIndexPath *indexPath) {
        Student *s = self.datasource[indexPath.row];
        s.studentAge = arc4random() % 50;
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

        [[StudentCoreDataRecord share] updateDataRecord:@[s]];
    };

    if (@available(iOS 11, *)) {
        UIContextualAction *action = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"UPDATE AGE" handler:^(UIContextualAction * _Nonnull action,
                                                                                                                  __kindof UIView * _Nonnull sourceView,
                                                                                                                  void (^ _Nonnull completionHandler)(BOOL)) {
            if (completionHandler) {
                completionHandler(YES);
                updateHandle(indexPath);
            }
        }];
        action.backgroundColor = [UIColor purpleColor];
        return [UISwipeActionsConfiguration configurationWithActions:@[
                                                                       action
                                                                       ]];
    }
    return nil;
}

- (nullable UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(tvos) {
    // COREDATA DELETE
    void (^deleteHandle)(NSIndexPath*) = ^(NSIndexPath *indexPath) {
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
