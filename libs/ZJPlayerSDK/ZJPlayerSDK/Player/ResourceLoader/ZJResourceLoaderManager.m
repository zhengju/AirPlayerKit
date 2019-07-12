//
//  AVAResourceLoaderManager.m
//  ZJPlayer
//
//  Created by zhengju on 2017/9/18.
//  Copyright © 2017年 郑俱. All rights reserved.
//

#import "ZJResourceLoaderManager.h"

static NSString *kCacheScheme = @"__VIMediaCache___:";

@interface ZJResourceLoaderManager()

@property(assign,nonatomic) BOOL isCancelled;

@end



@implementation ZJResourceLoaderManager
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(nonnull AVAssetResourceLoadingRequest *)loadingRequest{
//1.获取系统中不能处理的URL
    NSURL * resourceURL = [loadingRequest.request URL];
    //2.判断这个URL是否遵守URL规范和其是否是所设定的URL
    if (1) {
        //3.判断当前的URL网络请求是否已经被加载过了。
        
        NSURL *originURL = nil;
        NSString *originStr = [resourceURL absoluteString];
        originStr = [originStr stringByReplacingOccurrencesOfString:kCacheScheme withString:@""];
        originURL = [NSURL URLWithString:originStr];
        
        
        
    }
    return YES;
}
- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest{
    //如果用户在下载的过程中调用者取消了获取视频,则从缓存中取消这个请求
    NSURL *resourceURL = [loadingRequest.request URL];
    
//    NSString *actualURLString = [self actualURLStringWithURL:resourceURL];
//    AVResourceLoaderForASI *loader = [_resourceLoaders objectForKey:actualURLString];
//    [loader removeRequest:loadingRequest];
}

#pragma mark -- 判断缓存中是否已经下载完视频
- (void)addRequst:(AVAssetResourceLoadingRequest *)loadingRequest{
//1.判断自身是否已经取消加载
    if (self.isCancelled == NO) {
        //2.判断本地中是否已经有文件的缓存
    }
}
@end
@implementation ZJResourceLoaderManager (Convenient)

+ (NSURL *)assetURLWithURL:(NSURL *)url {
    if (!url) {
        return nil;
    }
    
    NSURL *assetURL = [NSURL URLWithString:[kCacheScheme stringByAppendingString:[url absoluteString]]];
    return assetURL;
}

- (AVPlayerItem *)playerItemWithURL:(NSURL *)url {
    NSURL *assetURL = [ZJResourceLoaderManager assetURLWithURL:url];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
    [urlAsset.resourceLoader setDelegate:self queue:dispatch_get_main_queue()];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:urlAsset];
    if ([playerItem respondsToSelector:@selector(setCanUseNetworkResourcesForLiveStreamingWhilePaused:)]) {
        if (@available(iOS 9.0, *)) {
            playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = YES;
        } else {
            // Fallback on earlier versions
        }
    }
    return playerItem;
}


@end
