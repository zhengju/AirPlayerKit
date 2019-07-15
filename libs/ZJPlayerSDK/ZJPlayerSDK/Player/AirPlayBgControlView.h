//
//  AirPlayBgControlView.h
//  ZJPlayerSDK
//
//  Created by leeco on 2019/7/15.
//  Copyright © 2019 zsw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol AirPlayBgControlViewDelegate <NSObject>

/**
 退出事件
 */
- (void)backOut;

- (void)changeDevice;

@end
@interface AirPlayBgControlView : UIView
@property(weak,nonatomic) id<AirPlayBgControlViewDelegate> delegate;

- (void)resetFrame:(BOOL)fullScreen superViewFrame:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END
