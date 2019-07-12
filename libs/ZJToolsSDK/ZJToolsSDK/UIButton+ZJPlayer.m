//
//  UIButton+ZJPlayer.m
//  ZJPlayer
//
//  Created by leeco on 2018/10/13.
//  Copyright © 2018年 郑俱. All rights reserved.
//

#import "UIButton+ZJPlayer.h"


@implementation UIButton (ZJPlayer)

+ (UIButton *)buttonWithTitle:(NSString *)title normalTitleColor:(UIColor *)normalTitleColor selectedTitleColor:(UIColor *)selectedTitleColor {
    
    UIButton * button  = [[UIButton alloc]init];
    
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:normalTitleColor forState:UIControlStateSelected];
    [button setTitleColor:selectedTitleColor forState:UIControlStateNormal];

    return button;
}


@end
