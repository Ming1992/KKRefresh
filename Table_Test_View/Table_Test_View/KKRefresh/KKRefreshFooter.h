//
//  KKRefreshFooter.h
//  KKListViewDemo
//
//  Created by liaozhenming on 2017/7/4.
//  Copyright © 2017年 liaozhenming. All rights reserved.
//

#import "KKRefreshComponent.h"

@interface KKRefreshFooter : KKRefreshComponent

@property (nonatomic, assign) BOOL autoHidden;

+ (instancetype)footerWithRefreshingBlock:(KKRefreshComponentRefreshingBlock)refreshingBlock;
@end


@interface KKRefreshNormalFooter : KKRefreshFooter

@property (nonatomic, strong) UIActivityIndicatorView *loadingActivity;
@property (nonatomic, strong) UILabel *updateTipsLabel;
@end
