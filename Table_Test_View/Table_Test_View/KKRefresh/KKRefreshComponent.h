//
//  KKRefreshComponent.h
//  KKListViewDemo
//
//  Created by liaozhenming on 2017/7/3.
//  Copyright © 2017年 liaozhenming. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *const KKRefreshKeyPathContentOffset = @"contentOffset";
static NSString *const KKRefreshKeyPathContentInset = @"contentInset";
static NSString *const KKRefreshKeyPathContentSize = @"contentSize";
static NSString *const KKRefreshKeyPathPanState = @"state";


typedef NS_ENUM(NSInteger, KKRefreshState) {
    /** 普通闲置状态 */
    KKRefreshStateNormal = 1,
    /** 松开就可以进行刷新的状态 */
    KKRefreshStatePulling,
    /** 正在刷新中的状态 */
    KKRefreshStateRefreshing,
    /** 即将刷新的状态 */
    KKRefreshStateWillRefresh,
    /** 所有数据加载完毕，没有更多的数据了 */
    KKRefreshStateNoMoreData
};

typedef void(^KKRefreshComponentRefreshingBlock)(void);

@interface KKRefreshComponent : UIView

@property (nonatomic, assign) UIEdgeInsets scrollViewOriginalInsets;
@property (nonatomic, weak) UIScrollView * scrollView;

@property (nonatomic, getter=isRefreshing) BOOL refreshing; /**<是否正在刷新*/
@property (nonatomic, assign) KKRefreshState state;         /**<刷新状态 */

@property (copy, nonatomic) KKRefreshComponentRefreshingBlock refreshingBlock;

- (void)executeRefreshingCallback;

#pragma mark - Public methods

- (void)kk_beginRefreshing;

- (void)kk_endRefreshing;


#pragma mark - 
/** 初始化 */
- (void)prepare NS_REQUIRES_SUPER;
/** 摆放子控件frame */
- (void)placeSubviews NS_REQUIRES_SUPER;
/** 当scrollView的contentOffset发生改变的时候调用 */
- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change NS_REQUIRES_SUPER;
/** 当scrollView的contentSize发生改变的时候调用 */
- (void)scrollViewContentSizeDidChange:(NSDictionary *)change NS_REQUIRES_SUPER;
/** 当scrollView的拖拽状态发生改变的时候调用 */
- (void)scrollViewPanStateDidChange:(NSDictionary *)change NS_REQUIRES_SUPER;

@end

