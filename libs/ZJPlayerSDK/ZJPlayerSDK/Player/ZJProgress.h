//
//  ZJProgress.h
//  ZJPlayer
//
//  Created by zhengju on 2017/9/15.
//  Copyright © 2017年 郑俱. All rights reserved.
//滑动时快进/快退展示的view


#import <UIKit/UIKit.h>

@interface ZJProgress : UIView
/**
 调整的时间点
 */
@property(copy,nonatomic) NSString * currentTime;
/**
 总的时间点
 */
@property(copy,nonatomic) NSString * allTime;
/**
 是否是快进 YES:快进  NO:快退
 */
@property(assign,nonatomic) BOOL isForward;
/**
 快进程度
 */
@property(nonatomic,assign) float progress;

- (instancetype)initWithSuperView:(UIView *)superView;
/**
 显示
 */
- (void)show;
/**
 隐藏
 */
- (void)dismiss;
/**
 旋转之后重新调整约束
 */
- (void)resetFrameisFullScreen:(BOOL)isFullScreen;

@end
