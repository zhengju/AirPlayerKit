//
//  ZJPlayer.h
//  ZJPlayer
//
//  Created by zhengju on 2017/9/10.
//  Copyright © 2017年 郑俱. All rights reserved.
//

/**
 任务：
 1.视屏截屏---已完成
 2.GIF动画截屏
 3.视频流的录屏(转成GIF)https://juejin.im/post/5a445286518825094862cfc1 https://github.com/NSRare/NSGIF
 2.视频缓冲
 3.视频下载，初步在ZJplayer中添加下载功能
 4.上下滑动调节屏幕亮度，写调节亮度的视图---已完成
 5.上下滑动调节声音大小，写调节声音的视图---已完成
 6.上下，左半部分是调整亮度，右半部分是调整声音的---已完成
 7.监听插入耳机/耳机线控 --- 已完成
 8.弹幕
 9.播放本地视频---已完成
 10.加载缓存环形加载指示器待优化...
 11.视频第一帧缓存到本地
 12.更新屏幕选中方式--已经更新，但是zjplayer添加到cell上有问题->已调试
 13.缓存视频第一张截图的图片--已完成
 */
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ZJPlayerProtocol.h"
#import "ZJJPlayer.h"
@class ZJControlView;
@class ZJTopView;
@class ZJVideoPlayerView;

@protocol ZJPlayerDelegate <NSObject>

- (void)playFinishedPlayer:(ZJVideoPlayerView *)player;


@end

extern NSString *const ZJViewControllerWillAppear;// 一个控制器即将出现
extern NSString *const ZJViewControllerWillDisappear; // 一个控制器即将消失
extern NSString *const ZJContinuousVideoPlayback; // 连续播放视频通知
extern NSString *const ZJEventSubtypeRemoteControlTogglePlayPause; // 暂停键

@interface ZJVideoPlayerView : UIView <UIApplicationDelegate>

@property(weak,nonatomic) id<ZJPlayerDelegate> delegate;

@property(strong,nonatomic) AVPlayer * player;

@property(strong,nonatomic) AVPlayerLayer * playerLayer;

@property(strong,nonatomic) AVPlayerItem * playerItem;

@property(strong,nonatomic) ZJTopView * topView;

@property(strong,nonatomic) ZJControlView * bottomView;

@property(nonatomic, strong) UIView<ZJPlayerProtocolDelegate> * interceptView;

/**
 默认背景图片
 */
@property(nonatomic, strong) UIImage * placeholderImage;

@property(assign,nonatomic) BOOL  isDragSlider;
/**
 tableView中player显示的位置
 */
@property(strong,nonatomic) NSIndexPath *indexPath;
/**
 当前播放视频的标题
 */
@property(copy,nonatomic) NSString * title;
/**
 当前播放url
 */
@property (nonatomic,strong) NSURL *url;

@property (nonatomic,strong) AVURLAsset *asset;

/**
 定时器 自动消失View
 */
@property(strong,nonatomic) NSTimer * autoDismissTimer;
/**
 是否自动播放,默认是NO
 */
@property(assign,nonatomic) BOOL  isAutoPlay;

/**
 是否连续播放,YES:连续播放，NO,不连续播放，默认是NO
 */
@property(assign,nonatomic) BOOL  isPlayContinuously;

/**
 是否隐藏bottomView
 */
@property(assign,nonatomic) BOOL  isBottomViewHidden;

/**
 是否全屏 YES:全屏 ；NO:非全屏
 */
@property (nonatomic,assign) BOOL isFullScreen;
/**
 当大屏时，播放完视频是否自动旋转至小屏幕 YES:自动 ；NO:不自动
 */
@property (nonatomic,assign) BOOL isRotatingSmallScreen;
/**
 跳转之后是否播放 YES:播放 ；NO:不播放，默认是NO
 */
@property (nonatomic,assign) BOOL isPushOrPopPlpay;

/**
 父视图
 */
@property(strong,nonatomic) UIView * fatherView;

/**
 全屏时的父视图
 */
@property (nonatomic, strong) UIView *fullScreenContainerView;

@property (nonatomic, copy, nullable) void(^orientationWillChange)(ZJVideoPlayerView *player, BOOL isFullScreen);

/**
 单例生成player
 */
+ (id _Nullable )sharePlayer;

- (void)setPlayerFrame:(CGRect)frame;

- (void)configurePLayer;
- (void)configurePLayerWithUrl:(NSURL *_Nullable)url;
-(instancetype _Nullable )initWithFrame:(CGRect)frame withSuperView:(UIView *_Nonnull)superView  controller:(UIViewController *_Nonnull)controller;

/**
 与url初始化
 */
-(instancetype _Nonnull )initWithUrl:(NSURL *_Nullable)url withSuperView:(UIView *_Nonnull)superView frame:(CGRect)frame controller:(UIViewController *_Nullable)controller;
/**
 视频播放
 */
- (void)play;
/**
 视频暂停
 */
- (void)pause;

- (void)deallocSelf;

@end
