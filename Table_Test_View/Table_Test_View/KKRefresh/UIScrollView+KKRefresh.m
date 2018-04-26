//
//  UIScrollView+KKRefresh.m
//  KKListViewDemo
//
//  Created by liaozhenming on 2017/7/4.
//  Copyright © 2017年 liaozhenming. All rights reserved.
//

#import "UIScrollView+KKRefresh.h"

#import <objc/runtime.h>

@implementation UIScrollView (KKRefresh)

static const void *KKRefreshHeaderValue = &KKRefreshHeaderValue;
- (void)setKk_header:(KKRefreshHeader *)kk_header {
    if (kk_header != self.kk_header) {
        [self.kk_header removeFromSuperview];
        [self insertSubview:kk_header atIndex:0];
        
        objc_setAssociatedObject(self, KKRefreshHeaderValue, kk_header, OBJC_ASSOCIATION_ASSIGN);
    }
}

- (KKRefreshHeader*)kk_header {
    return objc_getAssociatedObject(self, &KKRefreshHeaderValue);
}

static const void *KKRefreshFooterValue = &KKRefreshFooterValue;
- (void)setKk_footer:(KKRefreshFooter *)kk_footer {
    if (kk_footer != self.kk_footer) {
        [self.kk_footer removeFromSuperview];
        [self addSubview: kk_footer];
        
        objc_setAssociatedObject(self, KKRefreshFooterValue, kk_footer, OBJC_ASSOCIATION_ASSIGN);
    }
}

- (KKRefreshFooter*)kk_footer {
    return objc_getAssociatedObject(self, &KKRefreshFooterValue);
}

- (void)kk_reloadData {
    
}

@end


@implementation UITableView(KKRefresh)

+ (void)load {
    Method reloadData = class_getInstanceMethod([self class], NSSelectorFromString(@"reloadData"));
    Method refresh_reloadData = class_getInstanceMethod([self class], @selector(kk_reloadData));
    method_exchangeImplementations(reloadData, refresh_reloadData);
}

- (void)kk_reloadData {
    [self kk_reloadData];
    [self.kk_header kk_endRefreshing];
    [self.kk_footer kk_endRefreshing];
}

@end


@implementation UICollectionView(KKRefresh)

+ (void)load {
    Method reloadData = class_getInstanceMethod([self class], NSSelectorFromString(@"reloadData"));
    Method refresh_reloadData = class_getInstanceMethod([self class], @selector(kk_reloadData));
    method_exchangeImplementations(reloadData, refresh_reloadData);
}

- (void)kk_reloadData {
    [self kk_reloadData];
    [self.kk_header kk_endRefreshing];
    [self.kk_footer kk_endRefreshing];
}

@end
