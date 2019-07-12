//
//  UIView+Player.h
//  ZJPlayer
//
//  Created by zhengju on 2017/9/13.
//  Copyright © 2017年 郑俱. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Player)
/**
 查询当前控制器
 */
- (UIViewController * )getCurrentViewController;
/**
 当前view是否显示在屏幕中
 */
- (BOOL)windowVisible;




@end
