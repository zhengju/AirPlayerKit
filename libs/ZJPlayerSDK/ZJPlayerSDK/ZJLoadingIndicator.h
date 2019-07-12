//
//  ZJLoadingIndicator.h
//  ZJPlayer
//
//  Created by zhengju on 2017/9/15.
//  Copyright © 2017年 郑俱. All rights reserved.
//加载指示器

#import <UIKit/UIKit.h>

@interface ZJLoadingIndicator : UIView

@property(assign,nonatomic) CGFloat  progress;

- (void)show;
- (void)dismiss;

@end
