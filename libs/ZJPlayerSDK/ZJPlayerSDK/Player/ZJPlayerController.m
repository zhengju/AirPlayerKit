//
//  ZJPlayerController.m
//  ZJPlayer
//
//  Created by zhengju on 2017/9/29.
//  Copyright © 2017年 郑俱. All rights reserved.
//

#import "ZJPlayerController.h"

@interface ZJPlayerController ()

@end

@implementation ZJPlayerController
+ (id)sharePlayerController
{
    static ZJPlayerController *player = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        player = [[ZJPlayerController alloc]init];
        
    });
    return player;
}
- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor clearColor];

}
- (BOOL)shouldAutorotate//是否支持旋转屏幕
{
    return YES;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations//支持哪些方向
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
//由模态推出的视图控制器 优先支持的屏幕方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation//默认显示的方向
{
    
    return UIInterfaceOrientationPortrait;
    
}

@end
