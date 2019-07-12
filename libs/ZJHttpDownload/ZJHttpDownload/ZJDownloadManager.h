//
//  ZJDownloadManager.h
//  ZJPlayer
//
//  Created by zhengju on 2017/9/22.
//  Copyright © 2017年 郑俱. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "ZJDownloaderItem.h"


@protocol ZJDownloadManagerDelegate <NSObject>

@optional
- (void)zjDownloadOperationStartDownloading:(ZJDownloaderItem *)dItem;
- (void)zjDownloadOperationFinishDownload:(ZJDownloaderItem *)dItem;
- (void)zjDownloadOperationDownloading:(ZJDownloaderItem *)dItem downloadPercentage:(float)percentage velocity:(float)velocity;

@end

@interface ZJDownloadManager : NSObject

@property(nonatomic, assign) ZJDownloadType downloadType;

@property(nonatomic, weak) id<ZJDownloadManagerDelegate> delegate;


/**
 *  初始化
 *
 */

+ (ZJDownloadManager *)sharedInstance;

- (void)downloadWithItem:(ZJDownloaderItem *)item;//下载

- (void)cancelDownloadWithItem:(ZJDownloaderItem *)item;//取消

/**
 *  查询该资源的下载进度值
 *
 *  @param url 下载地址
 *
 *  @return 返回下载进度值
 */
- (CGFloat)progress:(NSString *)url;
/**
 *  获取该资源总大小
 *
 *  @param url 下载地址
 *
 *  @return 资源总大小
 */
- (NSInteger)fileTotalLength:(NSString *)url;

/**
 *  判断该资源是否下载完成
 *
 *  @param url 下载地址
 *
 *  @return YES: 完成
 */
- (BOOL)isCompletion:(NSString *)url;

/**
 *  删除该资源
 *
 *  @param url 下载地址
 */
- (void)deleteFile:(NSString *)url;

/**
 *  清空所有下载资源
 */
- (void)deleteAllFile;
/**
 *  本地路径
 */
- (NSString *)path:(NSString *)url;
/**
 *总大小，单位是M
 */
- (float)totalLength:(NSString *)url;
/**
 *已经下载的大小，单位是M
 */
- (float)downloadLength:(NSString *)url;
@end
