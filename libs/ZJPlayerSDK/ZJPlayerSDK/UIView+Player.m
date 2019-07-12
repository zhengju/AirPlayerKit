//
//  UIView+Player.m
//  ZJPlayer
//
//  Created by zhengju on 2017/9/13.
//  Copyright © 2017年 郑俱. All rights reserved.
//

#import "UIView+Player.h"
#import <AVFoundation/AVFoundation.h>
@implementation UIView (Player)

#pragma 查询当前控制器
- (UIViewController * )getCurrentViewController{
    
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    return [self getCurrentVCFrom:rootViewController];
}

#pragma 获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC
{
    
    UIViewController *currentVC;
    
    if ([rootVC presentedViewController]) {
        // 视图是被presented出来的
        rootVC = [rootVC presentedViewController];
    }
    
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
        
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
        
    } else {
        // 根视图为非导航类
        currentVC = rootVC;
    }
    
    return currentVC;
}

#pragma 当前view是否显示在屏幕中
- (BOOL)windowVisible{

    return self.window == nil ? NO : YES;
    
}


@end
