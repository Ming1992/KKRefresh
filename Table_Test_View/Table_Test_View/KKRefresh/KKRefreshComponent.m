//
//  KKRefreshComponent.m
//  KKListViewDemo
//
//  Created by liaozhenming on 2017/7/3.
//  Copyright © 2017年 liaozhenming. All rights reserved.
//

#import "KKRefreshComponent.h"
#import "UIScrollView+KKRefresh.h"

@interface KKRefreshComponent()

@property (nonatomic, strong) UIPanGestureRecognizer *pan;

@end

@implementation KKRefreshComponent
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame: frame];
    if (self) {
        [self prepare];
        self.state = KKRefreshStateNormal;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self placeSubviews];
}


- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview: newSuperview];
    
    if (newSuperview && ![newSuperview isKindOfClass: [UIScrollView class]]) {
        return;
    }
    [self removeObservers];
    
    if (newSuperview) {
        self.frame = CGRectMake(CGRectGetMinX(self.frame), 0, CGRectGetWidth(newSuperview.frame), CGRectGetHeight(self.frame));
        _scrollView = (UIScrollView*)newSuperview;
        _scrollView.alwaysBounceVertical = true;
        _scrollViewOriginalInsets = _scrollView.contentInset;
        [self addObservers];
    }
}

#pragma mark - Public methods

- (BOOL)isRefreshing {
    return self.state == KKRefreshStateRefreshing || self.state == KKRefreshStateWillRefresh;
}

- (void)kk_beginRefreshing {
    if (self.window) {
        self.state = KKRefreshStateRefreshing;
    }
    else {
        self.state = KKRefreshStateWillRefresh;
        [self setNeedsDisplay];
    }
}

- (void)kk_endRefreshing {
    
    typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.state = KKRefreshStateNormal;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.scrollView kk_reloadData];
        });
    });
}

#pragma mark -
- (void)prepare {
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.backgroundColor = [UIColor clearColor];
}

- (void)placeSubviews {}

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change {}

- (void)scrollViewContentSizeDidChange:(NSDictionary *)change {}

- (void)scrollViewPanStateDidChange:(NSDictionary *)change {}

#pragma mark - Private-KVO methodsd
- (void)addObservers {
    
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [_scrollView addObserver:self forKeyPath:KKRefreshKeyPathContentOffset options:options context:nil];
    [_scrollView addObserver:self forKeyPath:KKRefreshKeyPathContentSize options:options context:nil];
    
    self.pan = _scrollView.panGestureRecognizer;
    [self.pan addObserver:self forKeyPath:KKRefreshKeyPathPanState options:options context:nil];
}

- (void)removeObservers {
    [self.superview removeObserver:self forKeyPath:KKRefreshKeyPathContentOffset];
    [self.superview removeObserver:self forKeyPath:KKRefreshKeyPathContentSize];
    
    [self.pan removeObserver:self forKeyPath:KKRefreshKeyPathPanState];
    self.pan = nil;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if (self.userInteractionEnabled == false) {
        return;
    }
    
    if ([keyPath isEqualToString: KKRefreshKeyPathContentSize]) {
        [self scrollViewContentSizeDidChange: change];
    }
    
    if (self.hidden) {
        return;
    }
    
    if ([keyPath isEqualToString: KKRefreshKeyPathContentOffset]) {
        [self scrollViewContentOffsetDidChange: change];
    }
    else if ([keyPath isEqualToString: KKRefreshKeyPathPanState]) {
        [self scrollViewPanStateDidChange: change];
    }
}

#pragma mark - 

#pragma mark - 内部方法
- (void)executeRefreshingCallback {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.refreshingBlock) {
            self.refreshingBlock();
        }
    });
}

@end
