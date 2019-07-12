//
//  ZJDownloadOperation.m
//  ZJPlayer
//
//  Created by leeco on 2019/3/13.
//  Copyright © 2019年 郑俱. All rights reserved.
//

#import "ZJDownloadOperation.h"
#import "ZJToolsSDK.h"
@interface ZJDownloadOperation()<NSURLSessionDelegate,NSURLSessionDownloadDelegate,NSURLSessionDataDelegate,NSURLSessionTaskDelegate>
{
    __block BOOL _isFinished;
    int64_t _currentWriteByte;//当前下载文件大小byte
    __block int64_t _lastWriteByte;//上次下载文件大小byte
    float _percentage;//下载百分比
}
@property (nonatomic, strong) ZJDownloaderItem * downloadItem;
@property (nonatomic, strong) NSURLSessionTask *task;
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, strong) NSURLSession *session;
@end


@implementation ZJDownloadOperation


- (void)main
{
    @autoreleasepool {
        NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
        NSURL *url = [NSURL URLWithString:_downloadItem.downloadUrl];
        NSURLRequest * request = [NSURLRequest requestWithURL:url];
        NSData * data = [[NSData alloc] initWithContentsOfFile:_downloadItem.downloadPath];
        if (data && data.length != 0)
        {
            NSMutableDictionary *resumeDataDict = [NSMutableDictionary dictionaryWithDictionary:[NSPropertyListSerialization propertyListWithData:data
                                                                                                                                          options:NSPropertyListImmutable
                                                                                                                                           format:nil
                                                                                                                                            error:nil]];
            
            if (resumeDataDict) {
                //当下载地址不同时，通过修改resumeData也使断点续传继续有效 add by Houd
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
                NSNumber *downloadedBytes = [resumeDataDict objectForKey:@"NSURLSessionResumeBytesReceived"];
                NSString *downloadedBytesString = [NSString stringWithFormat:@"bytes=(%ld)", downloadedBytes ? downloadedBytes.longValue : 0];
                [request addValue:downloadedBytesString forHTTPHeaderField:@"Range"];
                NSData *newRequestData = [NSKeyedArchiver archivedDataWithRootObject:request];
                
                [resumeDataDict setObject:newRequestData forKey:@"NSURLSessionResumeCurrentRequest"];
                [resumeDataDict setObject:_downloadItem.downloadUrl forKey:@"NSURLSessionDownloadURL"];
                
                NSData *newResumeData = [NSPropertyListSerialization dataWithPropertyList:resumeDataDict
                                                                                   format:NSPropertyListXMLFormat_v1_0
                                                                                  options:0
                                                                                    error:nil];
                
                
                
                if (_downloadType == ZJDownloadOutputStream) {
                    [self initOuInputStream];
                    _task = [_session dataTaskWithRequest:request];
                }else{
                    _task = [_session downloadTaskWithResumeData:newResumeData];
                }
                
            }
            else {
                //TODO:暂时判断data是否为有效resumeData，如果不是则该文件为已下载好的视频，后续修改为resumeData和最终文件分开存放 add by Hou
                self.downloadItem.isSuccess = YES;
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if (self.delegate && [self.delegate respondsToSelector:@selector(zjDownloadOperationFinishDownload:)])
                    {
                        [self.delegate zjDownloadOperationFinishDownload:self.downloadItem];
                    }
                });
                return;
            }
        }
        else
        {
            
            if (_downloadType == ZJDownloadOutputStream) {
                [self initOuInputStream];
                _task = [_session dataTaskWithRequest:request];
            }else{
                _task = [_session downloadTaskWithRequest:request];
            }
        }
        [_task resume];
        [self startCountdownTimer];
        while(!_isFinished) {
            [NSThread sleepForTimeInterval:0.02];
        }
        [self stopCountdownTimer];
    }
}

- (void)initOuInputStream{
    // 创建流
    self.stream = [NSOutputStream outputStreamToFileAtPath:_downloadItem.downloadPath append:YES];
    
}

- (void)dealloc
{
    
}

- (void)cancelRequest
{
    [_session invalidateAndCancel];
    [_task suspend];
    [_task cancel];
}

#pragma mark - 存储操作
- (NSURL *)createDirectoryForDownloadItem
{
    NSURL * url = [NSURL fileURLWithPath:_downloadItem.downloadPath];
    return url;
}

- (BOOL) copyTempFileAtURL:(NSURL *)location toDestination:(NSURL *)destination
{
    
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtURL:destination error:NULL];
    [fileManager copyItemAtURL:location toURL:destination error:&error];
    if (error == nil) {
        [fileManager removeItemAtURL:location error:NULL];
        return YES;
    }else{
        
        return NO;
    }
}

#pragma mark - 定时器相关处理
- (void)startCountdownTimer
{
    [self stopCountdownTimer];
    __weak typeof(self) wSelf = self;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),0.5*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        float velocity = (_currentWriteByte - _lastWriteByte);
        if (wSelf.delegate && [wSelf.delegate respondsToSelector:@selector(zjDownloadOperationDownloading:downloadPercentage:velocity:)])
        {
            [wSelf.delegate zjDownloadOperationDownloading:wSelf.downloadItem
                                            downloadPercentage:_percentage
                                                      velocity:velocity];
        }
        _lastWriteByte = _currentWriteByte;
    });
    dispatch_resume(_timer);
}
- (NSString *)md5String:(NSString *)url
{
    
    NSArray * arr = [url componentsSeparatedByString:@"."];
    
    return   [NSString stringWithFormat:@"%@.%@",url.md5String,arr.lastObject];
}
- (void)stopCountdownTimer
{
    if (_timer)
    {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}

#pragma mark - NSURLSessionDownloadDelegate
/**
 * 接收到响应
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    
    if (_downloadType == ZJDownloadOutputStream) {
        // 打开流
        [self.stream open];
        
        
        NSInteger totalLength = [response.allHeaderFields[@"Content-Length"] integerValue] + ZJDownloaderItemLength(_downloadItem.downloadUrl);
        
        _downloadItem.totalFileSize = totalLength;
        
            [[NSUserDefaults standardUserDefaults ] setValue:[NSNumber numberWithLongLong:response.expectedContentLength] forKey:@"fileSize"];
        
    }
    // 接收这个请求，允许接收服务器的数据
    completionHandler(NSURLSessionResponseAllow);
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask{
    
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didBecomeStreamTask:(NSURLSessionStreamTask *)streamTask{
    
}
/**
 * 接收到服务器返回的数据
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    
    if (_downloadType == ZJDownloadOutputStream) {
        // 写入数据
        [self.stream write:data.bytes maxLength:data.length];
        
        _downloadItem.downloadedFileSize = ZJDownloaderItemLength(_downloadItem.downloadUrl);
        _downloadItem.downloadedFileSize = dataTask.countOfBytesReceived;
        
        NSLog(@"--%lld ",dataTask.countOfBytesReceived);
        
        
        
    }
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    [self stopCountdownTimer];

    if (_downloadType == ZJDownloadwriteToFile) {
        NSURL *destination = [self createDirectoryForDownloadItem];
        BOOL success = NO;
        NSData * data = [NSData dataWithContentsOfURL:location];
        if (data && data.length != 0)
        {
            success = [self copyTempFileAtURL:location toDestination:destination];
        }
        _downloadItem.isSuccess = success;
    }

    __weak typeof(self) wSelf = self;

    dispatch_async(dispatch_get_main_queue(), ^{
        if (wSelf.delegate && [wSelf.delegate respondsToSelector:@selector(zjDownloadOperationFinishDownload:)])
        {
            [wSelf.delegate zjDownloadOperationFinishDownload:wSelf.downloadItem];
        }
    });
    [self cancelRequest];
    _isFinished = YES;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error
{
    [self stopCountdownTimer];
    if (task.state == NSURLSessionTaskStateCompleted)
    {
        _downloadItem.isSuccess = NO;
    }
    else
    {
        _downloadItem.isSuccess = YES;
    }

    if (_downloadType == ZJDownloadOutputStream) {
        // 关闭流
        [self.stream close];
        self.stream = nil;
    }else{

        NSData* resumeData = error.userInfo[NSURLSessionDownloadTaskResumeData];
        if (resumeData && resumeData.length!=0)
        {
            [resumeData writeToFile:_downloadItem.downloadPath atomically:NO];
        }
    }

    __weak typeof(self) wSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (wSelf.delegate && [wSelf.delegate respondsToSelector:@selector(zjDownloadOperationFinishDownload:)])
        {
            [wSelf.delegate zjDownloadOperationFinishDownload:wSelf.downloadItem];
        }
    });

    [self cancelRequest];
    _isFinished = YES;
}


- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    _currentWriteByte = totalBytesWritten;
    _percentage = (totalBytesWritten*1.0)/totalBytesExpectedToWrite;
    _downloadItem.downloadedFileSize = _currentWriteByte;
    _downloadItem.totalFileSize = totalBytesExpectedToWrite;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    //恢复下载
    _currentWriteByte = fileOffset;
    _percentage = (fileOffset*1.0)/expectedTotalBytes;
    _downloadItem.downloadedFileSize = _currentWriteByte;
    _downloadItem.totalFileSize = expectedTotalBytes;

    CGFloat progress = 1.0 * _downloadItem.downloadedFileSize / _downloadItem.totalFileSize;

    NSLog(@"%f",progress);
}

#pragma mark - 外部调用
- (id)initWithItem:(ZJDownloaderItem *)item
{
    if (self = [super init])
    {
        _isFinished = NO;
        _downloadItem = item;
    }
    return self;
}

- (ZJDownloaderItem *)downloadItem
{
    return _downloadItem;
}

- (void)cancelDownload
{
    __weak typeof(self) wSelf = self;
    [(NSURLSessionDownloadTask*)_task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        if (resumeData && resumeData.length != 0) {
            [resumeData writeToFile:wSelf.downloadItem.downloadPath atomically:NO];
        }
        [wSelf.session invalidateAndCancel];
        _isFinished = YES;
    }];
    [self stopCountdownTimer];
    
}

@end
