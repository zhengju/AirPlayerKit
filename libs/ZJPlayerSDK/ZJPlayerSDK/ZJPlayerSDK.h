//
//  ZJPlayerSDK.h
//  ZJPlayerSDK
//
//  Created by leeco on 2019/3/15.
//  Copyright © 2019年 zsw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZJVideoPlayerView.h"
#import "ZJPlayerControl.h"
#import <ZJToolsSDK/ZJToolsSDK.h>

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

#define WeakObj(o) __weak typeof(o) o##Weak = o;
