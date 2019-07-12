//
//  ZJDownloaderItemManager.m
//  ZJPlayer
//
//  Created by zhengju on 2017/9/22.
//  Copyright © 2017年 郑俱. All rights reserved.
//实现方法是借鉴他人

#import "ZJDownloadManager.h"

#import "NSString+ZJHash.h"

#import "ZJDownloadOperation.h"

#define kMaxDownloadOperation    3

//// 缓存主目录
//#define ZJCachesDirectory [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"ZJCache"]
//
//// 保存文件名
//#define ZJFileName(url)  [self md5String:url]

//// 文件的存放路径（caches）
//#define ZJFileFullpath(url) [ZJCachesDirectory stringByAppendingPathComponent:ZJFileName(url)]
//
//// 文件的已下载长度
//#define ZJDownloaderItemLength(url) [[[NSFileManager defaultManager] attributesOfItemAtPath:ZJFileFullpath(url) error:nil][NSFileSize] integerValue]

// 存储文件总长度的文件路径（caches）
#define ZJTotalLengthFullpath [ZJCachesDirectory stringByAppendingPathComponent:@"totalLength.plist"]

@interface ZJDownloadManager()<NSURLSessionDelegate,ZJDownloadOperationDelegate>
{
    NSConditionLock * _sliderLock;
}

/** 保存所有下载相关信息 */
@property (nonatomic, strong) NSMutableDictionary *sessionModels;
@property(nonatomic, strong) NSCache * operationCaches;
@property (nonatomic, strong) ZJDownloaderItem * downloadItem;
@property (nonatomic, strong) NSOperationQueue * downloadOperationQueue;

@property (nonatomic, copy) void(^progressBlock)( CGFloat progress);
@property (nonatomic, copy) void(^totalLengthBlock)( CGFloat totalLength);
@property (nonatomic, copy) void(^stateBlock)(ZJDownloadState state);

@end

@implementation ZJDownloadManager
- (NSCache *)operationCaches{
    if (_operationCaches == nil) {
        _operationCaches = [[NSCache alloc]init];
        _operationCaches.countLimit = kMaxDownloadOperation;
        _operationCaches.totalCostLimit = 2014 * 5;
    }
    return _operationCaches;
}
- (NSMutableDictionary *)sessionModels
{
    if (!_sessionModels) {
        _sessionModels = [NSMutableDictionary dictionary];
    }
    return _sessionModels;
}

- (NSString *)md5String:(NSString *)url
{
   
    NSArray * arr = [url componentsSeparatedByString:@"."];

    return   [NSString stringWithFormat:@"%@.%@",url.md5String,arr.lastObject];
}

static ZJDownloadManager *manager = nil;
+ (ZJDownloadManager *)sharedInstance{
    
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        manager = [[ZJDownloadManager alloc]init];
        
    });
    return manager;
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        manager = [super allocWithZone:zone];
        
    });
    return manager;
}
- (nonnull id)copyWithZone:(nullable NSZone *)zone
{
    return manager;
}
- (instancetype)init{
    if (self = [super init]) {
        _downloadOperationQueue = [[NSOperationQueue alloc] init];
        _downloadOperationQueue.maxConcurrentOperationCount = kMaxDownloadOperation;
    }
    return self;
}


/**
 *  创建缓存目录文件
 */
- (void)createCacheDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:ZJCachesDirectory]) {
        [fileManager createDirectoryAtPath:ZJCachesDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
    }
}

- (void)downloadWithItem:(ZJDownloaderItem *)item{

        _downloadItem = item;

    
    if ([self isCompletion:item.downloadUrl]) {
        
        if ([self.delegate respondsToSelector:@selector(zjDownloadOperationFinishDownload:)]) {
            [self.delegate zjDownloadOperationFinishDownload:item];
        }
        
        NSLog(@"----该资源已下载完成");
        return;
    }
    
    for (ZJDownloadOperation * operation in _downloadOperationQueue.operations ) {
        if ([operation downloadItem] == item) {
            NSLog(@"----该资源已在下载");
            return;
        }
    }

        [self createCacheDirectory];
        _downloadItem.downloadPath = ZJFileFullpath(_downloadItem.downloadUrl);
        [self startOperationWithRequestItem:_downloadItem];

}
#pragma mark - 队列管理
- (void)startOperationWithRequestItem:(ZJDownloaderItem *)dItem
{
    ZJDownloadOperation *  operation = [[ZJDownloadOperation alloc] initWithItem:dItem];
    operation.downloadType = self.downloadType;
    operation.delegate = self;
    [_downloadOperationQueue addOperation:operation];
    [self.operationCaches setObject:operation forKey:ZJFileName(dItem.downloadUrl)];//添加到缓存中
}
#pragma mark - 取消下载
- (void)cancelDownloadWithItem:(ZJDownloaderItem *)item{
    ZJDownloadOperation *  operation = [self.operationCaches objectForKey:ZJFileName(item.downloadUrl)];
    if (operation) {
        [operation cancelDownload];
    }
}

/**
 *  开启任务下载资源
 */
- (void)downloadDataWithURL:(NSString *)url resume:(BOOL)resume totalLength:(void (^)(CGFloat))totalLengthBlock progress:(void (^)(CGFloat))progressBlock state:(void (^)(ZJDownloadState))stateBlack{

    if (!url) {
        return;
    }

    if ([self isCompletion:url]) {
        stateBlack(ZJDownloadStateCompleted);
        NSLog(@"----该资源已下载完成");
        return;
    }

    self.progressBlock = progressBlock;
    self.totalLengthBlock = totalLengthBlock;
    self.stateBlock = stateBlack;

    ZJDownloaderItem * dItem = [[ZJDownloaderItem alloc] init];
    dItem.downloadUrl = url;
    [self createCacheDirectory];
    dItem.downloadPath = ZJFileFullpath(url);
    [self startOperationWithRequestItem:dItem];

}



/**
 *  根据url获取对应的下载信息模型
 */
- (ZJDownloaderItem *)getSessionModel:(NSUInteger)taskIdentifier
{
    return (ZJDownloaderItem *)[self.sessionModels valueForKey:@(taskIdentifier).stringValue];
}

/**
 *  判断该文件是否下载完成
 */
- (BOOL)isCompletion:(NSString *)url
{
    if ([self fileTotalLength:url] && ZJDownloaderItemLength(url) == [self fileTotalLength:url]) {
        return YES;
    }
    return NO;
}

/**
 *  查询该资源的下载进度值
 */
- (CGFloat)progress:(NSString *)url
{

    return [self fileTotalLength:url] == 0 ? 0.0 : 1.0 * ZJDownloaderItemLength(url) /  [self fileTotalLength:url];
}

/**
 *  获取该资源总大小
 */
- (NSInteger)fileTotalLength:(NSString *)url
{
    return [[NSDictionary dictionaryWithContentsOfFile:ZJTotalLengthFullpath][ZJFileName(url)] integerValue];
}

#pragma mark - 删除
/**
 *  删除该资源
 */
- (void)deleteFile:(NSString *)url
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:ZJFileFullpath(url)]) {
        
        // 删除沙盒中的资源
        [fileManager removeItemAtPath:ZJFileFullpath(url) error:nil];

        // 删除资源总长度
        if ([fileManager fileExistsAtPath:ZJTotalLengthFullpath]) {
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:ZJTotalLengthFullpath];
            [dict removeObjectForKey:ZJFileName(url)];
            [dict writeToFile:ZJTotalLengthFullpath atomically:YES];
            
        }
    }
}

/**
 *  清空所有下载资源
 */
- (void)deleteAllFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:ZJCachesDirectory]) {
        // 删除沙盒中所有资源
        [fileManager removeItemAtPath:ZJCachesDirectory error:nil];
//        // 删除任务

        for (ZJDownloaderItem *sessionModel in [self.sessionModels allValues]) {
            [sessionModel.stream close];
        }
        [self.sessionModels removeAllObjects];
        
        // 删除资源总长度
        if ([fileManager fileExistsAtPath:ZJTotalLengthFullpath]) {
            [fileManager removeItemAtPath:ZJTotalLengthFullpath error:nil];
        }
    }
}


- (NSString *)path:(NSString *)url{
    
    return ZJFileFullpath(url);
}
/**
 *大小，单位是M
 */
- (float)totalLength:(NSString *)url{
    float all =   [self fileTotalLength:url];
    return all/1024.0/1024.0;
}
/**
 *已经下载的大小，单位是M
 */
- (float)downloadLength:(NSString *)url{
    float downloadLength = ZJDownloaderItemLength(url);
    return downloadLength/1024.0/1024.0;
}

#pragma mark - ZJDownloadOperationDelegate
- (void)zjDownloadOperationStartDownloading:(ZJDownloaderItem *)dItem{
    self.totalLengthBlock(dItem.totalFileSize/1024.0/1024.0);
    
    if ([self.delegate respondsToSelector:@selector(zjDownloadOperationStartDownloading:)]) {
        [self.delegate zjDownloadOperationStartDownloading:dItem];
    }
}
- (void)zjDownloadOperationFinishDownload:(ZJDownloaderItem *)dItem{
    
    // 存储总长度
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:ZJTotalLengthFullpath];
    if (dict == nil) dict = [NSMutableDictionary dictionary];
    dict[ZJFileName(dItem.downloadUrl)] = @(dItem.totalFileSize);
    [dict writeToFile:ZJTotalLengthFullpath atomically:YES];
    
    [self.operationCaches removeObjectForKey:ZJFileName(dItem.downloadUrl)];//删除记录
    
    if ([self.delegate respondsToSelector:@selector(zjDownloadOperationFinishDownload:)]) {
        [self.delegate zjDownloadOperationFinishDownload:dItem];
    }

}
- (void)zjDownloadOperationDownloading:(ZJDownloaderItem *)dItem downloadPercentage:(float)percentage velocity:(float)velocity{

    if ([self.delegate respondsToSelector:@selector(zjDownloadOperationDownloading:downloadPercentage:velocity:)]) {
        [self.delegate zjDownloadOperationDownloading:dItem downloadPercentage:percentage  velocity:velocity];
    }
    
   // NSLog(@"self.downloadOperationQueue.operations.count %lu",(unsigned long)self.downloadOperationQueue.operations.count);
    
}

@end
