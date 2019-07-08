//
//  MRDLNA.h
//  MRDLNA
//
//  Created by MccRee on 2018/5/4.
//

#import <Foundation/Foundation.h>
#import "CLUPnP.h"
#import "CLUPnPDevice.h"
#import "Common.h"

@protocol DLNADelegate <NSObject>

@optional
/**
 DLNA局域网搜索设备结果
 @param devicesArray <CLUPnPDevice *> 搜索到的设备
 */
- (void)searchDLNAResult:(NSArray *)devicesArray;


/**
 投屏成功开始播放
 */
- (void)dlnaStartPlay;

/**
 投屏暂停
 */
- (void)dlnaPause;

/**
 获取音量回调
 */
- (void)dlnaGetVolumeResponse:(NSString *)volume;

/**
 时间进度

 @param info info
 */
- (void)dlnaGetPositionInfoResponse:(CLUPnPAVPositionInfo *)info;

/**
 停止或投屏被挤掉
 */
- (void)dlnaStop;


@end

@interface MRDLNA : NSObject

@property(nonatomic,weak)id<DLNADelegate> delegate;

@property(nonatomic, strong) CLUPnPDevice *device;

@property(nonatomic,copy) NSString *playUrl;

@property(nonatomic,assign) NSInteger searchTime;

/**
 单例
 */
+(instancetype)sharedMRDLNAManager;

/**
 搜设备
 */
- (void)startSearch;

/**
 退出投屏
 */
- (void)close;

/**
 DLNA投屏
 */
- (void)startDLNA;
/**
 DLNA投屏(首先停止)---投屏不了可以使用这个方法
 ** 【流程: 停止 ->设置代理 ->设置Url -> 播放】
 */
- (void)startDLNAAfterStop;

/**
 退出DLNA
 */
- (void)endDLNA;

/**
 播放
 */
- (void)dlnaPlay;

/**
 暂停
 */
- (void)dlnaPause;

/**
 播放进度单位转换成string
 */
- (NSString *)timeFormatted:(NSInteger)totalSeconds;


/**
 设置音量 volume建议传0-100之间字符串
 */
- (void)volumeChanged:(NSString *)volume;

/**
 设置音量 加减固定的值
 */
-(void)volumeJumpValue:(NSInteger)jumpVolume;

/**
 设置播放进度 seek单位是秒
 */
- (void)seekChanged:(NSInteger)seek;
/**
 设置快进/退 几秒
 */
-(void)dlnaJump:(float)jumpTime;

/**
 播放切集
 */
- (void)playTheURL:(NSString *)url;

/**
 设置 下一个 投屏地址，播放的为uristr的下一个
 */
- (void)setNextAVTransportURIStr:(NSString *)uriStr;

/**
 获取音量，通过代理回调获取
 */
- (void)getVolume;

/**
 获取全局变量值
 */
- (int)getLocalVolume;

/**
 获取播放进度
 */
- (void)getPositionInfo;

/**
 播放状态 YES:正在播放；NO:暂停播放

 @return BOOL
 */
- (BOOL)getIsPlaying;

/**
 销毁单例
 */
+(void)destory;

/**
 发送订阅消息
 
 @param time 订阅事件
 @param callBack 回调地址
 @param serverType 服务类型
 接收回调会在内部建立一个http server,需要保存sid
 
 */
- (void)sendSubcirbeWithTime:(int)time callBack:(NSString*)callBack serverType:(LEUpnpServerType)serverType result:(void(^)(BOOL success))result;

/**
 续订某项服务
 注意:要在之前订阅的时间之前发起，否则无效
 @param time 续订的时间
 @param serverType 服务类型
 */
- (void)contractSubscirbeWithTime:(int)time serverType:(LEUpnpServerType)serverType result:(void(^)(BOOL success))result;

/**
 移除订阅
 
 @param serverType 服务类型
 */
- (void)removeSubscirbeWithServerType:(LEUpnpServerType)serverType result:(void(^)(BOOL success))result;

/**
 开启服务器，监听订阅服务的回调
 */
- (void)startWebServer;

@end
