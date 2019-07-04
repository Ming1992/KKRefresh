//
//  RootTableViewController.m
//  Table_Test_View
//
//  Created by liaozhenming on 2018/4/23.
//  Copyright © 2018年 liaozhenming. All rights reserved.
//

#import "RootTableViewController.h"

@interface RootTableViewController ()


@end

@implementation RootTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellIdentifier" forIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat: @"%@",@(indexPath.row)];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UIViewController *targetVC = [storyboard instantiateViewControllerWithIdentifier: indexPath.row == 0 ? @"FirstViewController" : @"SecondTableViewController"];
    [self.navigationController pushViewController: targetVC animated: true];
}

//#pragma mark -
//- (void)header_event{
//    self.dataCount = 40;
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.tableView.kk_header kk_endRefreshing];
//    });
//}
//
//- (void)footer_event{
//
//    self.dataCount += 20;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.tableView.kk_footer kk_endRefreshing];
//    });
//}

@end
