//
//  ZJPlayerControl.m
//  ZJPlayerSDK
//
//  Created by zhengju on 2019/4/6.
//  Copyright © 2019年 zsw. All rights reserved.
//

#import "ZJPlayerControl.h"

//#import "ZJDownloadManager.h"
//#import "ZJDownloaderItem.h"
#import "ZJVideoPlayerView.h"
#import "ZJToolsSDK.h"

//#import "HTTPServer.h"
//#import "DDLog.h"
//#import "DDTTYLogger.h"

//#import "ZJNetWorkUtils.h"

#import "VIMediaCache.h"
#import "VIMediaCacheWorker.h"

//#import "InterceptView.h"

@interface ZJPlayerControl()
//<ZJDownloadManagerDelegate>
//{
//    HTTPServer *httpServer;
//}
@property(strong,nonatomic) UIView * playerFatherView;
@property(nonatomic) CGRect  fatherFrame;
@property(strong,nonatomic) NSString * urlStr;

@end

@implementation ZJPlayerControl

- (instancetype)initWithView:(UIView *)view andFrame:(CGRect)frame url:(NSString *)urlStr{
    if (self = [super init]) {
        _playerFatherView = view;
        _fatherFrame = frame;
        _urlStr = urlStr;
//        [self initHttpServer];
        [self cleanCache];
        
        [self configurePlayer];
//        [self monitorNet];
    }
    return self;
}

//- (void)monitorNet{
//    [ZJNetWorkUtils netWorkState:^(NSInteger netState) {
//        NSLog(@"------》》》%ld",(long)netState);
//    }];
//}
//- (void)httpServer{
//    ZJDownloaderItem * item = [[ZJDownloaderItem alloc]init];
//    item.downloadUrl = _urlStr;
//    ZJDownloadManager * downManager = [[ZJDownloadManager alloc]init];
//    downManager.delegate = self;
//    downManager.downloadType = ZJDownloadOutputStream;
//    [downManager downloadWithItem:item];
//    NSString *   playUrlString =   [NSString stringWithFormat:@"http://localhost:12345/%@.mp4",[_urlStr md5String]];
//    ZJVideoPlayerView * player = [[ZJVideoPlayerView alloc]initWithUrl:[NSURL URLWithString:playUrlString] withSuperView:_playerFatherView frame:_fatherFrame controller:nil];
//    player.isRotatingSmallScreen = YES;
//    [_playerFatherView addSubview:player];
//}

- (void)cleanCache {
    unsigned long long fileSize = [VICacheManager calculateCachedSizeWithError:nil];
    NSLog(@"file cache size: %@", @(fileSize));
    NSError *error;
    [VICacheManager cleanAllCacheWithError:&error];
    if (error) {
        NSLog(@"clean cache failure: %@", error);
    }
    
    [VICacheManager cleanAllCacheWithError:&error];
}

- (void)configurePlayer{

    
    //http://img.house.china.com.cn/voice/hdzxjh.mp4
    //https://mvvideo5.meitudata.com/56ea0e90d6cb2653.mp4
    
//    NSURL *url = [NSURL URLWithString:@"http://img.house.china.com.cn/voice/hdzxjh.mp4"];
//
//
//    VIMediaCacheWorker * worker =  [[VIMediaCacheWorker alloc] initWithURL:url];
//
//    VIMediaDownloader *downloader = [[VIMediaDownloader alloc] initWithURL:url cacheWorker:worker];
//
//    [downloader downloadFromStartToEnd];
//
//    return;
    
//    InterceptView<ZJPlayerProtocolDelegate> * interceptView = [[InterceptView alloc]init];
    
    ZJVideoPlayerView * player = [[ZJVideoPlayerView alloc]initWithFrame:_fatherFrame withSuperView:_playerFatherView controller:nil];
    
//    player.interceptView =  interceptView;
    
    VIResourceLoaderManager *resourceLoaderManager = [VIResourceLoaderManager new];

//    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:_urlStr]];
    
    //[AVPlayerItem playerItemWithURL:[NSURL URLWithString:_urlStr]];
    //[resourceLoaderManager playerItemWithURL:[NSURL URLWithString:_urlStr]];

//    VICacheConfiguration *configuration = [VICacheManager cacheConfigurationForURL:[NSURL URLWithString:_urlStr]];
//
//    if (configuration.progress >= 1.0) {
//        NSLog(@"cache completed");
//    }
    
//    player.playerItem = playerItem;
    
    [player configurePLayerWithUrl:[NSURL URLWithString:_urlStr]];
    player.isRotatingSmallScreen = YES;
    
    [_playerFatherView addSubview:player];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaCacheDidChanged:) name:VICacheManagerDidUpdateCacheNotification object:nil];
    
}
//- (BOOL)startServer
//{
//    // Start the server (and check for problems)
//
//    NSError *error;
//    if([httpServer start:&error])
//    {
//        NSLog(@"Started HTTP Server on port %hu", [httpServer listeningPort]);
//        return YES;
//    }
//    else
//    {
//        //        DDLogError(@"Error starting HTTP Server: %@", error);
//        return NO;
//    }
//}

#define ZJCachesDirectory [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"ZJCache"]

//- (void)initHttpServer{
//    // Configure our logging framework.
//    // To keep things simple and fast, we're just going to log to the Xcode console.
//    [DDLog addLogger:[DDTTYLogger sharedInstance]];
//
//    // Create server using our custom MyHTTPServer class
//    httpServer = [[HTTPServer alloc] init];
//
//    // Tell the server to broadcast its presence via Bonjour.
//    // This allows browsers such as Safari to automatically discover our service.
//    [httpServer setType:@"_http._tcp."];
//
//    // Normally there's no need to run our server on any specific port.
//    // Technologies like Bonjour allow clients to dynamically discover the server's port at runtime.
//    // However, for easy testing you may want force a certain port so you can just hit the refresh button.
//    [httpServer setPort:12345];
//
//    // Serve files from our embedded Web folder
//    NSString *webPath2 = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Web"];
////    ZJCachesDirectory;
//
//    NSLog(@"Setting document root: %@", webPath2);
//
//    [httpServer setDocumentRoot:webPath2];
//
//    if ([self startServer]) {
//        NSLog(@"开启成功啦");
//    }
//}

#pragma mark - ZJDownloadManagerDelegate
//- (void)zjDownloadOperationStartDownloading:(ZJDownloaderItem *)dItem{
//    NSLog(@"%@",NSStringFromSelector(_cmd));
//}
//- (void)zjDownloadOperationFinishDownload:(ZJDownloaderItem *)dItem{
//    NSLog(@"%@",NSStringFromSelector(_cmd));
//}
//- (void)zjDownloadOperationDownloading:(ZJDownloaderItem *)dItem downloadPercentage:(float)percentage velocity:(float)velocity{
//    
//    CGFloat progress = 1.0 * dItem.downloadedFileSize / dItem.totalFileSize;
//    NSLog(@"ZJPlayerControl :%f",progress);
//
//}

#pragma mark - notification

- (void)mediaCacheDidChanged:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    VICacheConfiguration *configuration = userInfo[VICacheConfigurationKey];
    NSArray<NSValue *> *cachedFragments = configuration.cacheFragments;
    long long contentLength = configuration.contentInfo.contentLength;
    
    NSInteger number = 100;
    NSMutableString *progressStr = [NSMutableString string];
    
    [cachedFragments enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange range = obj.rangeValue;
        
        NSInteger location = roundf((range.location / (double)contentLength) * number);
        
        NSInteger progressCount = progressStr.length;
        [self string:progressStr appendString:@"0" muti:location - progressCount];
        
        NSInteger length = roundf((range.length / (double)contentLength) * number);
        [self string:progressStr appendString:@"1" muti:length];
        
        
        if (idx == cachedFragments.count - 1 && (location + length) <= number + 1) {
            [self string:progressStr appendString:@"0" muti:number - (length + location)];
        }
    }];
    
    NSLog(@"%@", progressStr);
}

- (void)string:(NSMutableString *)string appendString:(NSString *)appendString muti:(NSInteger)muti {
    for (NSInteger i = 0; i < muti; i++) {
        [string appendString:appendString];
    }
}



@end
