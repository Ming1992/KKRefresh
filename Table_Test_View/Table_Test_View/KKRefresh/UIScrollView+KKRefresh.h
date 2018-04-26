//
//  UIScrollView+KKRefresh.h
//  KKListViewDemo
//
//  Created by liaozhenming on 2017/7/4.
//  Copyright © 2017年 liaozhenming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKRefreshFooter.h"
#import "KKRefreshHeader.h"

@interface UIScrollView (KKRefresh)

@property (nonatomic, strong) KKRefreshHeader *kk_header;
@property (nonatomic, strong) KKRefreshFooter *kk_footer;

- (void)kk_reloadData;

@end
