//
//  MRDLNA.h
//  MRDLNA
//
//  Created by MccRee on 2018/5/4.
//

#import <Foundation/Foundation.h>
#import "CLUPnP.h"
#import "CLUPnPDevice.h"

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
 获取音量，通过代理回调获取
 */
- (void)getVolume;

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

@end
