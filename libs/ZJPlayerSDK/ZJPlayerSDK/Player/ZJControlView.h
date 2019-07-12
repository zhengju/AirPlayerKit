//
//  ZJControlView.h
//  ZJPlayer
//
//  Created by zhengju on 2017/9/10.
//  Copyright © 2017年 郑俱. All rights reserved.
//底部控制栏

#import <UIKit/UIKit.h>

@interface ZJUISlider : UISlider

@end



@protocol ZJControlViewDelegate <NSObject>

/**
 点击全屏的事件
 */
- (void)clickFullScreen;
/**
 播放
 */
- (void)play;
/**
 暂停
 */
- (void)pause;
- (void)sliderDragValueChange:(UISlider *)slider;
- (void)sliderTapValueChange:(UISlider *)slider;
// 点击事件的Slider
- (void)touchSlider:(UITapGestureRecognizer *)tap;

@end


@interface ZJControlView : UIView

@property(strong,nonatomic) ZJUISlider * slider;

@property (nonatomic,strong) UIProgressView *progressView;
/**
 播放暂停按钮
 */
@property(strong,nonatomic) UIButton * playBtn;
/**
 右下角放缩按钮
 */
@property(strong,nonatomic) UIButton * scalingBtn;

@property(strong,nonatomic) UILabel * nowLabel;

@property(strong,nonatomic) UILabel * remainLabel;
/**
 是否播放状态 YES:播放状态 NO:暂停状态
 */
@property(assign,nonatomic) BOOL isPlay;
/**
 当前时间
 */
@property(copy,nonatomic) NSString * currentTime;
/**
 剩余时间
 */
@property(copy,nonatomic) NSString * remainingTime;
/**
 slider的值
 */
@property(nonatomic,assign) float sliderValue;
/**
 slider的值
 */
@property(nonatomic,assign) float sliderMaximumValue;
/**
 视频缓冲进度
 */
@property(nonatomic,assign) float progress;

@property(weak,nonatomic) id<ZJControlViewDelegate> delegate;


- (void)resetFrame;

@end
