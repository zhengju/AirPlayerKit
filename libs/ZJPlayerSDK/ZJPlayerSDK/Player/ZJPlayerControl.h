//
//  ZJPlayerControl.h
//  ZJPlayerSDK
//
//  Created by zhengju on 2019/4/6.
//  Copyright © 2019年 zsw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface ZJPlayerControl : NSObject

- (instancetype)initWithView:(UIView *)view andFrame:(CGRect)frame url:(NSString *)urlStr;

@end

NS_ASSUME_NONNULL_END
