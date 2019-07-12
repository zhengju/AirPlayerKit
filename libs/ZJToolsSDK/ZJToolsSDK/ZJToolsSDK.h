//
//  ZJToolsSDK.h
//  ZJToolsSDK
//
//  Created by leeco on 2019/3/15.
//  Copyright © 2019年 zsw. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UIControl+ZJBlocksKit.h"
#import "UIView+Frame.h"
#import "UIButton+ZJPlayer.h"
#import "ZJCustomTools.h"
#import "NSString+ZJHash.h"
#import "ZJCacheTask.h"
#import "ZJAlertView.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define HUDNormal(msg) { ZJAlertView *alert = [[ZJAlertView alloc]init];\
[alert showAlertWith:msg];\
}
