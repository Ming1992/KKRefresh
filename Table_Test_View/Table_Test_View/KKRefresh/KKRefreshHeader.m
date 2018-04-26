//
//  KKRefreshHeader.m
//  KKListViewDemo
//
//  Created by liaozhenming on 2017/7/4.
//  Copyright © 2017年 liaozhenming. All rights reserved.
//

#import "KKRefreshHeader.h"

@interface KKRefreshHeader()

@property (assign, nonatomic) CGFloat insetTDelta;

@property (assign, nonatomic) CGFloat defaultContentOffsetY;    /**<初始scrollView的contentOffset.y值*/
@end


@implementation KKRefreshHeader

#pragma mark - 构造方法
+ (instancetype)headerWithRefreshingBlock:(KKRefreshComponentRefreshingBlock)refreshingBlock
{
    KKRefreshHeader *cmp = [[self alloc] init];
    cmp.refreshingBlock = refreshingBlock;
    return cmp;
}

#pragma mark - 覆盖父类的方法
- (void)prepare {
    [super prepare];
    // 设置key
    self.lastUpdatedTimeKey = @"KKRefreshHeaderLastUpdatedTimeKey";
//    self.backgroundColor = [UIColor purpleColor];
    // 设置高度
    self.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), CGRectGetWidth([[UIScreen mainScreen] bounds]), 60.0);
    
    // 保存刷新时间
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:self.lastUpdatedTimeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)placeSubviews{
    [super placeSubviews];
    
    // 设置y值(当自己的高度发生改变了，肯定要重新调整Y值，所以放到placeSubviews方法中设置y值)
    CGFloat selfHeight = CGRectGetHeight(self.frame);
    self.frame = CGRectMake(CGRectGetMinX(self.frame), - selfHeight - self.ignoredScrollViewContentInsetTop, CGRectGetWidth(self.frame), selfHeight);
}

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change {
    [super scrollViewContentOffsetDidChange:change];
    
    // 在刷新的refreshing状态
    if (self.state == KKRefreshStateRefreshing) {
        if (self.window == nil) return;
        
        // sectionheader停留解决
        CGFloat insetT = - self.scrollView.contentOffset.y > self.scrollViewOriginalInsets.top ? - self.scrollView.contentOffset.y : self.scrollViewOriginalInsets.top;

        insetT = insetT > CGRectGetHeight(self.bounds) + self.scrollViewOriginalInsets.top ? CGRectGetHeight(self.bounds) + self.scrollViewOriginalInsets.top : insetT;
        self.scrollView.contentInset = UIEdgeInsetsMake(insetT, 0, 0, 0);

        self.insetTDelta = self.scrollViewOriginalInsets.top - insetT;
        return;
    }
    
    CGFloat offsetY = self.scrollView.contentOffset.y - self.defaultContentOffsetY;
    // 头部控件刚好出现的offsetY
    CGFloat happenOffsetY = - self.scrollViewOriginalInsets.top;
    
    // 如果是向上滚动到看不见头部控件，直接返回
    if (offsetY >= happenOffsetY) return;
    
    // 跳转到下一个控制器时，contentInset可能会变
    self.scrollViewOriginalInsets = self.scrollView.contentInset;
    
    if (!self.scrollView.isDragging && !self.scrollView.isTracking && !self.scrollView.isDecelerating && self.defaultContentOffsetY == 0) {
        self.defaultContentOffsetY = self.scrollView.contentOffset.y;
        return;
    }
    
    CGFloat pullingOffsetY = 0 - self.scrollView.contentOffset.y - self.defaultContentOffsetY - self.scrollViewOriginalInsets.top;
    
    if (pullingOffsetY < 0) {
        return;
    }

    if (self.scrollView.isDragging) {
        //  当前scrollView处于拖拽状态
        if (self.state == KKRefreshStateNormal && pullingOffsetY < CGRectGetHeight(self.frame)) {
            //  当前state 为普通状态，并且拖拽的高度小于当前刷新header的高度
            self.state = KKRefreshStatePulling;
        }
        else if (self.state == KKRefreshStatePulling && pullingOffsetY < CGRectGetHeight(self.frame)) {
            self.state = KKRefreshStateNormal;
        }
    }
    if (!self.scrollView.isDragging && self.scrollView.isDecelerating && pullingOffsetY >= CGRectGetHeight(self.frame)) {
        //  当前scrollView处于减速状态,并且拖拽的高度小于当前刷新header的高度
        [self kk_beginRefreshing];
    }
    
    
//    if (self.scrollView.isDragging) { // 如果正在拖拽
//        if (self.state == KKRefreshStateNormal && offsetY < normal2pullingOffsetY) {
//            // 转为即将刷新状态
//            self.state = KKRefreshStatePulling;
//        } else if (self.state == KKRefreshStatePulling && offsetY >= normal2pullingOffsetY) {
//            // 转为普通状态
//            self.state = KKRefreshStateNormal;
//        }
//    } else if (self.state == KKRefreshStatePulling) {// 即将刷新 && 手松开
//        // 开始刷新
//        [self kk_beginRefreshing];
//    } else if (pullingPercent < 1) {
////        self.pullingPercent = pullingPercent;
//    }
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
        
        // 保存刷新时间
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:self.lastUpdatedTimeKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        // 恢复inset和offset
        [UIView animateWithDuration:0.4 animations:^{
            CGFloat top = self.scrollView.contentInset.top;
            self.scrollView.contentInset = UIEdgeInsetsMake(top + self.insetTDelta, 0, self.scrollViewOriginalInsets.bottom, 0);
        } completion:^(BOOL finished) {
        }];
    } else if (state == KKRefreshStateRefreshing) {
        [UIView animateWithDuration:0.25 animations:^{
            // 增加滚动区域
            CGFloat top = self.scrollViewOriginalInsets.top + CGRectGetHeight(self.bounds);
            self.scrollView.contentInset = UIEdgeInsetsMake(top, 0, 0, 0);
            
            // 设置滚动位置
            self.scrollView.contentOffset = CGPointMake(0, - top);
        } completion:^(BOOL finished) {
            [self executeRefreshingCallback];
        }];
    }
    else if (state == KKRefreshStateWillRefresh) {
        
    }
}

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    if (self.state == KKRefreshStateWillRefresh) {
        self.state = KKRefreshStateRefreshing;
    }
}

#pragma mark - 公共方法
- (void)kk_endRefreshing
{
    if ([self.scrollView isKindOfClass:[UICollectionView class]]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [super kk_endRefreshing];
        });
    } else {
        [super kk_endRefreshing];
    }
}

static NSDateFormatter *dateFormatter = nil;
- (NSString *)lastUpdatedTime {
    
    NSDate *timeDate = [[NSUserDefaults standardUserDefaults] objectForKey:self.lastUpdatedTimeKey];
    if (dateFormatter == nil) {
        dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm"];
    }
    return [dateFormatter stringFromDate: timeDate];
}
@end


#pragma mark -
#pragma mark - KKRefreshNormalHeader methods
@implementation KKRefreshNormalHeader

- (void)prepare {
    [super prepare];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, CGRectGetWidth(self.bounds), 20)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor darkGrayColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize: 13];
    titleLabel.text = @"正在加载中...";
    titleLabel.center = CGPointMake(CGRectGetWidth(self.bounds)/2 + 20, CGRectGetHeight(self.bounds)/2 - 5);
    [self addSubview: titleLabel];
    
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
    activity.center = CGPointMake(CGRectGetWidth(self.bounds)/2 - 35, CGRectGetHeight(self.bounds)/2 - 5);
    activity.hidesWhenStopped = NO;
    [self addSubview: activity];
    self.loadingActivity = activity;
    
    UILabel *updateLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, CGRectGetWidth(self.bounds), 20)];
    updateLabel.backgroundColor = [UIColor clearColor];
    updateLabel.textColor = [UIColor lightGrayColor];
    updateLabel.font = [UIFont systemFontOfSize: 13];
    updateLabel.textAlignment = NSTextAlignmentCenter;
    updateLabel.center = CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2 + 15);
    [self addSubview: updateLabel];
    self.updateTimeLabel = updateLabel;
}

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    if (self.state == KKRefreshStateWillRefresh) {
        self.state = KKRefreshStateRefreshing;
    }
}

- (void)setState:(KKRefreshState)state {
    [super setState: state];
    
    if (state == KKRefreshStateNormal) {
        self.updateTimeLabel.text = [NSString stringWithFormat: @"最后更新于:%@", [super lastUpdatedTime]];
    } else if (state == KKRefreshStatePulling || state == KKRefreshStateRefreshing) {
        [self.loadingActivity startAnimating];
    }
}

@end
