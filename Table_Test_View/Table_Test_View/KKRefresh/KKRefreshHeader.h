//
//  KKRefreshHeader.h
//  KKListViewDemo
//
//  Created by liaozhenming on 2017/7/4.
//  Copyright © 2017年 liaozhenming. All rights reserved.
//

#import "KKRefreshComponent.h"

@interface KKRefreshHeader : KKRefreshComponent
+ (instancetype)headerWithRefreshingBlock:(KKRefreshComponentRefreshingBlock)refreshingBlock;
@property (nonatomic, strong) NSString *lastUpdatedTimeKey;
@property (nonatomic, strong) NSDate *lastUpdatedTime;
@property (assign, nonatomic) CGFloat ignoredScrollViewContentInsetTop;
@end



@interface KKRefreshNormalHeader : KKRefreshHeader
@property (nonatomic, strong) UIActivityIndicatorView *loadingActivity;
@property (nonatomic, strong) UILabel *updateTimeLabel;
@end
