//
//  KKRefreshFooter.m
//  KKListViewDemo
//
//  Created by liaozhenming on 2017/7/4.
//  Copyright © 2017年 liaozhenming. All rights reserved.
//

#import "KKRefreshFooter.h"

@implementation KKRefreshFooter

+ (instancetype)footerWithRefreshingBlock:(KKRefreshComponentRefreshingBlock)refreshingBlock {
    KKRefreshFooter *cmp = [[self alloc] init];
    cmp.refreshingBlock = refreshingBlock;
    cmp.autoHidden = true;
    return cmp;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview: newSuperview];
    if (newSuperview) {
        if (self.hidden == NO) {
            CGFloat bottom = self.scrollView.contentInset.bottom;
            self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, bottom + CGRectGetHeight(self.bounds), 0);
        }
    }
}

- (void)scrollViewContentSizeDidChange:(NSDictionary *)change {
    [super scrollViewContentSizeDidChange:change];
    [self placeSubviews];
}

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change {
    [super scrollViewContentOffsetDidChange:change];
    
    if (self.state != KKRefreshStateNormal || CGRectGetMinY(self.frame) == 0) return;
    
    if (self.scrollView.contentInset.top + self.scrollView.contentSize.height > CGRectGetHeight(self.scrollView.bounds)) { // 内容超过一个屏幕
        // 这里的_scrollView.mj_contentH替换掉self.mj_y更为合理
        if (self.scrollView.contentOffset.y >= self.scrollView.contentSize.height - CGRectGetHeight(self.scrollView.bounds) + CGRectGetHeight(self.bounds) + self.scrollView.contentInset.bottom - + CGRectGetHeight(self.bounds)) {
            // 防止手松开时连续调用
            CGPoint old = [change[@"old"] CGPointValue];
            CGPoint new = [change[@"new"] CGPointValue];
            if (new.y <= old.y) return;
            
            // 当底部刷新控件完全出现时，才刷新
            [self kk_beginRefreshing];
        }
    }
}

#pragma mark - 重写父类的方法
- (void)prepare {
    [super prepare];
    self.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), CGRectGetWidth([[UIScreen mainScreen] bounds]), 50);
}

- (void)placeSubviews {
    [super placeSubviews];
    
    if (self.scrollView.contentSize.height >= CGRectGetHeight(self.scrollView.bounds) && self.autoHidden) {
        self.hidden = false;
        // 设置y值(当自己的高度发生改变了，肯定要重新调整Y值，所以放到placeSubviews方法中设置y值)
        CGFloat selfHeight = CGRectGetHeight(self.frame);
        self.frame = CGRectMake(CGRectGetMinX(self.frame), self.scrollView.contentSize.height, CGRectGetWidth(self.frame), selfHeight);
    }
    else {
        self.hidden = YES;
    }
}

- (void)setState:(KKRefreshState)state{
    KKRefreshState oldState = self.state;
    if (oldState == state) {
        return;
    }
    [super setState: state];
    
    // 根据状态做事情
    if (state == KKRefreshStateNormal) {
        if (oldState != KKRefreshStateRefreshing) return;
        
        // 恢复inset和offset
        [UIView animateWithDuration:0.25 animations:^{
            self.scrollView.contentInset = UIEdgeInsetsMake(self.scrollView.contentInset.top, 0, self.scrollViewOriginalInsets.bottom, 0);
        } completion:^(BOOL finished) {
        }];
    } else if (state == KKRefreshStateRefreshing) {
        [UIView animateWithDuration:0.25 animations:^{
            // 增加滚动区域
            CGFloat bottom = self.scrollViewOriginalInsets.bottom + CGRectGetHeight(self.bounds);
            self.scrollView.contentInset = UIEdgeInsetsMake(self.scrollView.contentInset.top, 0, bottom, 0);
        } completion:^(BOOL finished) {
            [self executeRefreshingCallback];
        }];
    }
}
@end

#pragma mark - KKRefreshNormalFooter methods

@interface KKRefreshNormalFooter()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation KKRefreshNormalFooter
- (void)prepare {
    [super prepare];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, CGRectGetWidth(self.bounds), 20)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor darkGrayColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize: 13];
    titleLabel.text = @"推荐更多中...";
    titleLabel.center = CGPointMake(CGRectGetWidth(self.bounds)/2 + 20, CGRectGetHeight(self.bounds)/2);
    [self addSubview: titleLabel];
    self.titleLabel = titleLabel;
    
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
    activity.center = CGPointMake(CGRectGetWidth(self.bounds)/2 - 35, CGRectGetHeight(self.bounds)/2);
    activity.hidesWhenStopped = NO;
    [self addSubview: activity];
    self.loadingActivity = activity;
    
    UILabel *updateTipsLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
    updateTipsLabel.backgroundColor = [UIColor clearColor];
    updateTipsLabel.textColor = [UIColor darkGrayColor];
    updateTipsLabel.textAlignment = NSTextAlignmentCenter;
    updateTipsLabel.font = [UIFont systemFontOfSize: 13];
    updateTipsLabel.text = @"已全部加载完毕";
    updateTipsLabel.hidden = YES;
    [self addSubview: updateTipsLabel];
    self.updateTipsLabel = updateTipsLabel;
}

- (void)setState:(KKRefreshState)state {
    [super setState: state];
    
    self.updateTipsLabel.hidden = state == KKRefreshStateNoMoreData ? NO : YES;
    self.titleLabel.hidden = state == KKRefreshStateNoMoreData ? YES : NO;
    self.loadingActivity.hidden = state == KKRefreshStateNoMoreData ? YES : NO;
    if (state == KKRefreshStateRefreshing) {
        [self.loadingActivity startAnimating];
    }
    else {
        [self.loadingActivity stopAnimating];
    }
}

@end
