//
//  SecondTableViewController.m
//  Table_Test_View
//
//  Created by liaozhenming on 2018/4/26.
//  Copyright © 2018年 liaozhenming. All rights reserved.
//

#import "SecondTableViewController.h"
#import "UIScrollView+KKRefresh.h"

@interface SecondTableViewController ()

@property (nonatomic, assign) NSInteger dataCount;

@end

@implementation SecondTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataCount = 40;
    __weak typeof(self) weakSelf = self;
    KKRefreshNormalHeader *header = [KKRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf header_event];
    }];
    self.tableView.kk_header = header;
    
    KKRefreshNormalFooter *footer = [KKRefreshNormalFooter footerWithRefreshingBlock:^{
        [weakSelf footer_event];
    }];
    self.tableView.kk_footer = footer;
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
    return self.dataCount;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellIdentifier" forIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat: @"%@",@(indexPath.row)];
    return cell;
}


#pragma mark -
- (void)header_event{
    self.dataCount = 40;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView.kk_footer setNoMoreData: false];
        [self.tableView.kk_header kk_endRefreshing];
    });
}

- (void)footer_event{
    
    if (self.dataCount > 60) {
        [self.tableView.kk_footer setNoMoreData: true];
        return;
    }
    
    self.dataCount += 20;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView.kk_footer kk_endRefreshing];
    });
}

@end
