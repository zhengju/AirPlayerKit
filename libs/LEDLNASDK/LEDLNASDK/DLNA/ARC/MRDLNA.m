//
//  MRDLNA.m
//  MRDLNA
//
//  Created by MccRee on 2018/5/4.
//

#import "MRDLNA.h"
#import "StopAction.h"



@interface MRDLNA()<CLUPnPServerDelegate, CLUPnPResponseDelegate>

@property(nonatomic,strong) CLUPnPServer *upd;              //MDS服务器
@property(nonatomic,strong) NSMutableArray *dataArray;

@property(nonatomic,strong) CLUPnPRenderer *render;         //MDR渲染器
@property(nonatomic,copy) NSString *volume;
@property(nonatomic,assign) NSInteger seekTime;
@property(nonatomic,assign) BOOL isPlaying;

@property(nonatomic,assign) BOOL isJump;
@property (nonatomic,assign)float  jumpTime;

@end

@implementation MRDLNA

static int numCount = 0;//计算超时次数

static MRDLNA *instance = nil;
static dispatch_once_t once;

+ (MRDLNA *)sharedMRDLNAManager{

    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.upd = [CLUPnPServer shareServer];
        self.upd.searchTime = 5;
        self.upd.delegate = self;
        self.dataArray = [NSMutableArray array];
        
    }
    return self;
}

/**
 ** DLNA投屏
 */
- (void)startDLNA{
    [self initCLUPnPRendererAndDlnaPlay];
}
/**
 ** DLNA投屏
 ** 【流程: 停止 ->设置代理 ->设置Url -> 播放】
 */
- (void)startDLNAAfterStop{
    StopAction *action = [[StopAction alloc]initWithDevice:self.device Success:^{
        [self initCLUPnPRendererAndDlnaPlay];
        
    } failure:^{
        [self initCLUPnPRendererAndDlnaPlay];
    }];
    [action executeAction];
}
/**
 初始化CLUPnPRenderer
 */
-(void)initCLUPnPRendererAndDlnaPlay{
    
    numCount = 0;
    
    self.render = [[CLUPnPRenderer alloc] initWithModel:self.device];
    self.render.delegate = self;
    [self.render setAVTransportURL:self.playUrl];
}
/**
 退出DLNA
 */
- (void)endDLNA{
    [self.render stop];
}

/**
 播放
 */
- (void)dlnaPlay{
    [self.render play];
}


/**
 暂停
 */
- (void)dlnaPause{
    [self.render pause];
}

/**
 搜设备
 */
- (void)startSearch{
    [self.upd start];
}

/**
 close
 */
- (void)close{
    [self.upd stop];
}

/**
 设置音量
 */
- (void)volumeChanged:(NSString *)volume{
    self.volume = volume;
    [self.render setVolumeWith:volume];
}
/**
 设置音量 加减固定的值
 */
-(void)volumeJumpValue:(NSInteger)jumpVolume{
    NSInteger currentVolume = [self.volume intValue];
    currentVolume+=jumpVolume;
    if(currentVolume<=0) currentVolume = 0;
    if(currentVolume>=100) currentVolume = 100;
    self.volume = [NSString stringWithFormat:@"%ld",(long)currentVolume];
    NSLog(@"设置音量，%@",self.volume);
    [self.render setVolumeWith:self.volume];
}

/**
 获取音量
 */
- (void)getVolume{
    [self.render getVolume];
}
- (int)getLocalVolume{
    return [self.volume intValue]/5;
}
/**
 播放进度条
 */
- (void)seekChanged:(NSInteger)seek{
    self.seekTime = seek;
    NSString *seekStr = [self timeFormatted:seek];
    [self.render seekToTarget:seekStr Unit:unitREL_TIME];
}

/**
 设置快进/退 几秒
 */
-(void)dlnaJump:(float)jumpTime{
    _jumpTime = jumpTime;
    _isJump =  YES;
    [self.render getPositionInfo];
}
- (void)getPositionInfo{
    _isJump =  NO;
    [self.render getPositionInfo];
}
- (BOOL)getIsPlaying{
    return self.isPlaying;
}
/**
 播放进度单位转换成string
 */
- (NSString *)timeFormatted:(NSInteger)totalSeconds
{
    NSInteger seconds = totalSeconds % 60;
    NSInteger minutes = (totalSeconds / 60) % 60;
    NSInteger hours = totalSeconds / 3600;
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)hours, (long)minutes, (long)seconds];
}

/**
 播放切集
 */
- (void)playTheURL:(NSString *)url{
    numCount = 0;
    
    self.playUrl = url;
    [self.render setAVTransportURL:url];
}

#pragma mark -- 搜索协议CLUPnPDeviceDelegate回调
- (void)upnpSearchChangeWithResults:(NSArray<CLUPnPDevice *> *)devices{
    NSMutableArray *deviceMarr = [NSMutableArray array];
    NSLog(@"%@",devices);
    for (CLUPnPDevice *device in devices) {
        // 只返回匹配到视频播放的设备
        if ([device.uuid containsString:serviceType_AVTransport]) {
            [deviceMarr addObject:device];
        }
    }
    if ([self.delegate respondsToSelector:@selector(searchDLNAResult:)]) {
        [self.delegate searchDLNAResult:[deviceMarr copy]];
    }
    self.dataArray = deviceMarr;
}

- (void)upnpSearchErrorWithError:(NSError *)error{
//    NSLog(@"DLNA_Error======>%@", error);
}

#pragma mark - CLUPnPResponseDelegate
- (void)upnpSetAVTransportURIResponse{
    [self.render play];
}

- (void)upnpGetTransportInfoResponse:(CLUPnPTransportInfo *)info{
      NSLog(@"%@ === %@", info.currentTransportState, info.currentTransportStatus);
    if (!([info.currentTransportState isEqualToString:@"PLAYING"] || [info.currentTransportState isEqualToString:@"TRANSITIONING"])) {
        [self.render play];
    }
}

- (void)upnpPlayResponse{
    self.isPlaying = YES;
    if ([self.delegate respondsToSelector:@selector(dlnaStartPlay)]) {
        [self.delegate dlnaStartPlay];
    }
}
- (void)upnpPauseResponse{
    self.isPlaying = NO;
    if ([self.delegate respondsToSelector:@selector(dlnaPause)]) {
        [self.delegate dlnaPause];
    }
}
#pragma mark - 获取视频现在的播放进度的回调(里面有播放的总时间）



- (void)upnpGetPositionInfoResponse:(CLUPnPAVPositionInfo *)info{
    
    if ([self.delegate respondsToSelector:@selector(dlnaGetPositionInfoResponse:)]) {
        [self.delegate dlnaGetPositionInfoResponse:info];
    }

    if (info.trackDuration == 0.0 && info.absTime == 0 && info.relTime == 0) {//总时间为0即停止播放，需断开连接
        
        numCount++;
        
        [self.render getTransportInfo];
        
        if (numCount > 5) {
            
            self.isPlaying = NO;
            
            numCount = 0;
            [self endDLNA];
            [self close];
            if ([self.delegate respondsToSelector:@selector(dlnaStop)]) {
                [self.delegate dlnaStop];
            }
        }
        
    }

    if(_isJump){
        [self.render seek:info.relTime+(_jumpTime)];
        _isJump = NO;
        _jumpTime = 0;
    }
}
- (void)upnpNextResponse{
    
}
- (void)upnpSetVolumeResponse{
    NSLog(@"upnpSetVolumeResponse success");
}
- (void)upnpSetNextAVTransportURIResponse{
    
}
- (void)upnpGetVolumeResponse:(NSString *)volume{
    NSLog(@"upnpGetVolumeResponse success %@",volume);
    self.volume = volume;
    if ([self.delegate respondsToSelector:@selector(dlnaGetVolumeResponse:)]) {
        [self.delegate dlnaGetVolumeResponse:self.volume];
    }
}
#pragma mark Set&Get
- (void)setSearchTime:(NSInteger)searchTime{
    _searchTime = searchTime;
    self.upd.searchTime = searchTime;
}

+(void)destory{
    once = 0;
    instance = nil;
}
@end
