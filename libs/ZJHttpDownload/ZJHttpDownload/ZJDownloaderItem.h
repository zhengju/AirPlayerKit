//
//  ZJDownloaderItem.h
//  ZJPlayer
//
//  Created by leeco on 2019/3/13.
//  Copyright © 2019年 郑俱. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

typedef enum {
    ZJDownloadStateRunning = 0,     /** 下载中 */
    ZJDownloadStateSuspended,     /** 下载暂停 */
    ZJDownloadStateCompleted,     /** 下载完成 */
    ZJDownloadStateCanceled,     /** 取消下载 */
    ZJDownloadStateFailed         /** 下载失败 */
}ZJDownloadState;


typedef enum {
    ZJDownloadwriteToFile = 1,     /** 写文件 */
    ZJDownloadOutputStream,     /** 文件流 */ //暂时有e问题
}ZJDownloadType;

NS_ASSUME_NONNULL_BEGIN

@interface ZJDownloaderItem : NSObject
/** 流 */
@property (nonatomic, strong) NSOutputStream *stream;
/** 下载地址 */
@property (nonatomic, copy) NSString *downloadUrl;
/** 存储路径 */
@property (nonatomic, strong) NSString * downloadPath;
@property (nonatomic, assign) BOOL isSuccess;
/**
 *  文件的总长度
 */
@property (nonatomic, assign) long long totalLength;

@property (nonatomic, assign) long long downloadedFileSize; //bytes
@property (nonatomic, assign) long long totalFileSize;
@end

NS_ASSUME_NONNULL_END
