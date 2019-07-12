//
//  ZJDownloadOperation.h
//  ZJPlayer
//
//  Created by leeco on 2019/3/13.
//  Copyright © 2019年 郑俱. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZJDownloaderItem.h"
NS_ASSUME_NONNULL_BEGIN


// 缓存主目录
#define ZJCachesDirectory [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"ZJCache"]

// 保存文件名
#define ZJFileName(url)  [self md5String:url]

// 文件的存放路径（caches）
#define ZJFileFullpath(url) [ZJCachesDirectory stringByAppendingPathComponent:ZJFileName(url)]

// 文件的已下载长度
#define ZJDownloaderItemLength(url) [[[NSFileManager defaultManager] attributesOfItemAtPath:ZJFileFullpath(url) error:nil][NSFileSize] integerValue]



@protocol ZJDownloadOperationDelegate <NSObject>

@optional
- (void)zjDownloadOperationStartDownloading:(ZJDownloaderItem *)dItem;
- (void)zjDownloadOperationFinishDownload:(ZJDownloaderItem *)dItem;
- (void)zjDownloadOperationDownloading:(ZJDownloaderItem *)dItem downloadPercentage:(float)percentage velocity:(float)velocity;

@end


@interface ZJDownloadOperation : NSOperation

@property(nonatomic, assign) ZJDownloadType downloadType;
/** 流 */
@property (nonatomic, strong,nullable) NSOutputStream *stream;
@property (nonatomic, weak) id<ZJDownloadOperationDelegate> delegate;
- (id)initWithItem:(ZJDownloaderItem *)item;
- (ZJDownloaderItem *)downloadItem;
- (void)cancelDownload;


@end

NS_ASSUME_NONNULL_END
/**
 <NSHTTPURLResponse: 0x2807ee880> { URL: http://house.china.com.cn/img/voice/hdzxjh.mp4 } { Status Code: 206, Headers {
 CACHE =     (
 "TCP_HIT"
 );
 "CC_CACHE" =     (
 "TCP_MISS"
 );
 "Cache-Control" =     (
 "max-age=86400"
 );
 Connection =     (
 "keep-alive"
 );
 "Content-Length" =     (
 22072560
 );
 "Content-Range" =     (
 "bytes 0-22072559/22072560"
 );
 "Content-Type" =     (
 "video/mp4"
 );
 Date =     (
 "Tue, 12 Mar 2019 08:30:54 GMT"
 );
 Etag =     (
 "\"bf1a74fe8ec9d31:0\""
 );
 Expires =     (
 "Wed, 13 Mar 2019 07:59:51 GMT"
 );
 "Last-Modified" =     (
 "Sun, 01 Apr 2018 07:56:51 GMT"
 );
 "Powered-By-ChinaCache" =     (
 "HIT from CNC-DZ-3-3W7"
 );
 Server =     (
 nginx
 );
 "X-Powered-By" =     (
 "ASP.NET"
 );
 } }
 */
