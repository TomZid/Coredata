//
//  InfoViewController.m
//  CoreData
//
//  Created by tom on 09/01/2018.
//  Copyright © 2018 TZ. All rights reserved.
//

#import "InfoViewController.h"
//#import "CoredataManager.h"
#import "Student.h"

#import "StudentCoreDataRecord.h"

typedef void (^ALERTHANDLE)(BOOL);

@interface InfoViewController ()
@property (nonatomic, strong) NSArray *datasource_name;
@property (nonatomic, strong) NSArray *datasource_age;
@property (weak, nonatomic) IBOutlet UIPickerView *picker;

@property (nonatomic, copy) ALERTHANDLE alertHandle;
@end

@implementation InfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.datasource_age = [@[@(arc4random() % 60), @(arc4random() % 60), @(arc4random() % 60), @(arc4random() % 60), @(arc4random() % 60)] copy];
    self.datasource_name = @[@"Bjarne Lundgren", @"Sam Davies", @"Casa Taloyum", @"Yaoyuan", @"Mattt"];

    __weak typeof(self) ws = self;
    self.alertHandle = ^(BOOL res) {
        UIAlertController *alert = [[UIAlertController alloc] init];
        if (res) {
            [alert addAction:[UIAlertAction actionWithTitle:@"🎉SUCCESS" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
            }]];
            [ws presentViewController:alert animated:YES completion:nil];
        }else {
            [alert addAction:[UIAlertAction actionWithTitle:@"⚠️ERROR" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
            }]];
            [ws presentViewController:alert animated:YES completion:nil];
        }
    };
}
/*
// COREDATA CREATE
- (IBAction)saveClicked:(id)sender {
    NSInteger index = [self.picker selectedRowInComponent:0];
    NSString *name = self.datasource_name[index];
    NSNumber *age = self.datasource_age[index];
    NSInteger identity = arc4random() % 10;

    Student *s = [NSEntityDescription insertNewObjectForEntityForName:K_ENTITY_STUDENT inManagedObjectContext:[[CoredataManager share] context]];
    s.studentName = name;
    s.studentAge = [age integerValue];
    s.studentId = identity;

    NSError *error = NSError.new;
    BOOL res = [[[CoredataManager share] context] save:&error];
    if (res) {
        NSLog(@"Save successFull");
        self.alertHandle(YES);
    } else {
        NSLog(@"Error: %@,%@",error,[error userInfo]);
        self.alertHandle(NO);
    }
}
*/

- (IBAction)saveClicked:(id)sender {
    NSInteger index = [self.picker selectedRowInComponent:0];
    NSString *name = self.datasource_name[index];
    NSNumber *age = self.datasource_age[index];
    NSInteger identity = arc4random() % 10;

    [[StudentCoreDataRecord share] addStudentName:name age:[age integerValue] identifier:identity];
}

#pragma mark - UIPickerViewDataSource
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.datasource_age.count;
}
#pragma mark - UIPickerViewDelegate
- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component __TVOS_PROHIBITED {
    return [self.datasource_name[row] stringByAppendingString:[self.datasource_age[row] stringValue]];
}

@end
