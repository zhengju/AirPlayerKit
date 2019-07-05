//
//  CLUPnPRenderer.h
//  Tiaooo
//
//  Created by ClaudeLi on 16/9/29.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "CLUPnPResponseDelegate.h"
#import "Common.h"
@class CLUPnPDevice;
@interface CLUPnPRenderer : NSObject

@property (nonatomic, strong) CLUPnPDevice *model;

/**订阅后存储的sid，一个设备可以有多个服务，所以理论上存在可以订阅多个*/
@property (nonatomic,strong,readonly)NSMutableDictionary *subscribeSidDict;

@property (nonatomic, strong) id<CLUPnPResponseDelegate>delegate;

/**
 初始化
 @param model 搜索得到的UPnPModel
 @return self
 */
- (instancetype)initWithModel:(CLUPnPDevice *)model;

/**
 设置投屏地址
 @param urlStr 视频url
 */
- (void)setAVTransportURL:(NSString *)urlStr;

/**
 设置下一个播放地址
 @param urlStr 下一个视频url
 */
- (void)setNextAVTransportURI:(NSString *)urlStr;

/**
 播放
 */
- (void)play;

/**
 暂停
 */
- (void)pause;

/**
 结束
 */
- (void)stop;

/**
 下一个
 */
- (void)next;

/**
 前一个
 */
- (void)previous;

/**
 跳转进度
 @param relTime 进度时间(单位秒)
 */
- (void)seek:(float)relTime;

/**
 跳转至特定进度或视频
 @param target 目标值，可以是 00:02:21 格式的进度或者整数的 TRACK_NR。
 @param unit   REL_TIME（跳转到某个进度）或 TRACK_NR（跳转到某个视频）。
 */
- (void)seekToTarget:(NSString *)target Unit:(NSString *)unit;

/**
 获取播放进度,可通过协议回调使用
 */
- (void)getPositionInfo;

/**
 获取播放状态,可通过协议回调使用
 */
- (void)getTransportInfo;

/**
 获取音频,可通过协议回调使用
 */
- (void)getVolume;

/**
 设置音频值
 @param value 值—>整数
 */
- (void)setVolumeWith:(NSString *)value;

/**
 针对某项服务发送订阅消息
 
 @param time 订阅多久时间
 @param serverType 服务类型
 @param callBack 数据回调的链接地址，这里采用了GCDWebServer获取回调，但是demo中的不知道对不对哈
 */
- (void)sendSubscribeRequestWithTime:(int)time serverType:(LEUpnpServerType)serverType callBack:(NSString*)callBack result:(void(^)(BOOL success))result;

/**
 续订某项服务
 注意:要在之前订阅的时间之前发起，否则无效
 @param time 续订的时间
 @param serverType 服务类型
 */
- (void)contractSubscirbeWithTime:(int)time serverType:(LEUpnpServerType)serverType result:(void(^)(BOOL success))result;

/**
 移除针对某项服务的订阅
 
 @param serverType 服务类型
 */
- (void)removeSubscribeWithServerType:(LEUpnpServerType)serverType result:(void(^)(BOOL success))result;

@end
