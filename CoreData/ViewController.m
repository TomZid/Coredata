//
//  ViewController.m
//  CoreData
//
//  Created by tom on 09/01/2018.
//  Copyright © 2018 TZ. All rights reserved.
//

#import "ViewController.h"
#import "CoredataManager.h"
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)requestData {
    NSFetchRequest *request = NSFetchRequest.new;
    NSEntityDescription *e = [NSEntityDescription entityForName:@"Student" inManagedObjectContext:[CoredataManager share].context];
    [request setEntity:e];

    NSError *error;
    self.datasource = [[[[CoredataManager share] context] executeFetchRequest:request error:&error] mutableCopy];
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

@end
