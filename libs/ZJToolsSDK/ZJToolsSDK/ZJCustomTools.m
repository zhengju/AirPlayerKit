//
//  ZJCustomTools.m
//  ZJPlayer
//
//  Created by zhengju on 2017/9/26.
//  Copyright © 2017年 郑俱. All rights reserved.
//

#import "ZJCustomTools.h"
#import <AVFoundation/AVFoundation.h>
#import "ZJCacheTask.h"
#import <AVKit/AVKit.h>
#import <MobileCoreServices/UTCoreTypes.h>

typedef NS_ENUM(NSInteger, GIFSize) {
    GIFSizeVeryLow = 1,
    GIFSizeLow = 2,
    GIFSizeMedium = 3,
    GIFSizeHigh = 5,
    GIFSizeOriginal = 10
    
};

@interface ZJCustomTools()

@property(copy,atomic)InterceptBlock interceptBlock;
@property(copy,atomic)CompleteBlock completeBlock;
@property (nonatomic,strong)NSError *error;
@end

@implementation ZJCustomTools

+(id)shareCustomTools{
    static ZJCustomTools *customTool;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        customTool = [[self alloc] init];
    });
    return customTool;

}

#pragma 获取视频第一帧 返回图片
+ (UIImage*) getVideoPreViewImage:(NSURL *)path
{

    //判断是否有缓存
    UIImage * Img = [[ZJCacheTask shareTask] imageFromCacheForKey:path.absoluteString];
    if (Img) {
        return Img;
    }
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:path options:nil];
    AVAssetImageGenerator *assetGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    assetGen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(13.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [assetGen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *videoImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    //缓存
    [[ZJCacheTask shareTask]storeImage:videoImage forKey:path.absoluteString];
    return videoImage;
}
#pragma mark -- 截屏
+ (UIImage *)captureCurrentView:(UIView *)view {
    CGRect frame = view.frame;
    UIGraphicsBeginImageContext(frame.size);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:contextRef];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
+ (UIImage *)fetchScreenshot:(CALayer *)layer {
    UIImage *image = nil;
    if (layer) {
        CGSize imageSize = layer.bounds.size;
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [layer renderInContext:context];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return image;
}
/**
 *  截取指定时间的视频缩略图
 *
 *  @param timeBySecond 时间点
 */
+ (void)thumbnailImageRequest:(CGFloat )timeBySecond url:(NSString *)urlStr success:(void (^)(UIImage *))successBlock{
    
    UIImage * image = [[ZJCacheTask shareTask]imageFromCacheForKey:urlStr];
    if (image&&successBlock) {
        successBlock(image);
        return;
    }
    
    dispatch_async(dispatch_queue_create("com.customTools.thumbnail", DISPATCH_QUEUE_SERIAL), ^{
        [self _thumbnailImageRequest:timeBySecond url:urlStr success:^(UIImage *image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //缓存
                [[ZJCacheTask shareTask]storeImage:image forKey:urlStr];
                if (successBlock) {
                    successBlock(image);
                    return;
                }
            });
        }];
    });
}
+ (void)_thumbnailImageRequest:(CGFloat )timeBySecond url:(NSString *)urlStr success:(void (^)(UIImage *))successBlock{
    
    //创建URL
    NSURL *url = [ZJCustomTools getNetworkUrl:urlStr];
    //根据url创建AVURLAsset
    AVURLAsset *urlAsset = [AVURLAsset assetWithURL:url];
    //根据AVURLAsset创建AVAssetImageGenerator
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    /*截图
     * requestTime:缩略图创建时间
     * actualTime:缩略图实际生成的时间
     */
    NSError *error = nil;
    CMTime time = CMTimeMakeWithSeconds(timeBySecond, 600);//CMTime是表示电影时间信息的结构体，第一个参数表示是视频第几秒，第二个参数表示每秒帧数.(如果要活的某一秒的第几帧可以使用CMTimeMake方法)
    CMTime actualTime;
    CMTimeShow(time);
    /** 使用copyCGImageAtTime:actualTime:error:生成一张指定时间点的图片。AVFoundation不一定能精确的生成一张你所指定时间的图片，所以你可以在第二个参数传一个CMTime的指针，用来获取所生成图片的精确时间。**/
    CGImageRef cgImage = [imageGenerator copyCGImageAtTime:time actualTime:&actualTime error:&error];
    if(error){
        NSLog(@"截取视频缩略图时发生错误，错误信息：%@",error.localizedDescription);
        return;
    }
    CMTimeShow(actualTime);
   
    UIImage * image = [UIImage imageWithCGImage:cgImage];//转化为UIImage

    CGImageRelease(cgImage);
    
    if (successBlock) {
        successBlock(image);
    }
}
/**
 *  取得网络文件路径
 *
 *  @return 文件路径
 */
+ (NSURL *)getNetworkUrl:(NSString *)urlStr{
    urlStr=[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:urlStr];
    return url;
}

#pragma mark -截取视频
- (void)interceptVideoAndVideoUrl:(NSURL *)videoUrl withOutPath:(NSString *)outPath outputFileType:(NSString *)outputFileType range:(NSRange)videoRange compositionProgressBlock:(void(^)(CGFloat progress))compositionProgressBlock intercept:(InterceptBlock)interceptBlock {
    
    _interceptBlock =interceptBlock;
    
    //不添加背景音乐
    NSURL *audioUrl =nil;
    //AVURLAsset此类主要用于获取媒体信息，包括视频、声音等
    AVURLAsset* audioAsset = [[AVURLAsset alloc] initWithURL:audioUrl options:nil];
    AVURLAsset* videoAsset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
    
    //创建AVMutableComposition对象来添加视频音频资源的AVMutableCompositionTrack
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    //CMTimeRangeMake(start, duration),start起始时间，duration时长，都是CMTime类型
    //CMTimeMake(int64_t value, int32_t timescale)，返回CMTime，value视频的一个总帧数，timescale是指每秒视频播放的帧数，视频播放速率，（value / timescale）才是视频实际的秒数时长，timescale一般情况下不改变，截取视频长度通过改变value的值
    //CMTimeMakeWithSeconds(Float64 seconds, int32_t preferredTimeScale)，返回CMTime，seconds截取时长（单位秒），preferredTimeScale每秒帧数
    
    //开始位置startTime
    CMTime startTime = CMTimeMakeWithSeconds(videoRange.location, videoAsset.duration.timescale);
    //截取长度videoDuration
    CMTime videoDuration = CMTimeMakeWithSeconds(videoRange.length, videoAsset.duration.timescale);
    
    CMTimeRange videoTimeRange = CMTimeRangeMake(startTime, videoDuration);
    
    //视频采集compositionVideoTrack
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    // 避免数组越界 tracksWithMediaType 找不到对应的文件时候返回空数组
    //TimeRange截取的范围长度
    //ofTrack来源
    //atTime插放在视频的时间位置
    [compositionVideoTrack insertTimeRange:videoTimeRange ofTrack:([videoAsset tracksWithMediaType:AVMediaTypeVideo].count>0) ? [videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject : nil atTime:kCMTimeZero error:nil];
    
    
    //视频声音采集(也可不执行这段代码不采集视频音轨，合并后的视频文件将没有视频原来的声音)
    
    AVMutableCompositionTrack *compositionVoiceTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    [compositionVoiceTrack insertTimeRange:videoTimeRange ofTrack:([videoAsset tracksWithMediaType:AVMediaTypeAudio].count>0)?[videoAsset tracksWithMediaType:AVMediaTypeAudio].firstObject:nil atTime:kCMTimeZero error:nil];
    
    //声音长度截取范围==视频长度
    CMTimeRange audioTimeRange = CMTimeRangeMake(kCMTimeZero, videoDuration);
    
    //音频采集compositionCommentaryTrack
    AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    [compositionAudioTrack insertTimeRange:audioTimeRange ofTrack:([audioAsset tracksWithMediaType:AVMediaTypeAudio].count > 0) ? [audioAsset tracksWithMediaType:AVMediaTypeAudio].firstObject : nil atTime:kCMTimeZero error:nil];
    
    //AVAssetExportSession用于合并文件，导出合并后文件，presetName文件的输出类型
    AVAssetExportSession *assetExportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetPassthrough];
    
    
    //混合后的视频输出路径
    NSURL *outPutURL = [NSURL fileURLWithPath:outPath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:outPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:outPath error:nil];
    }
    __block NSTimer *timer = nil;
    //输出视频格式
    assetExportSession.outputFileType = outputFileType;
    assetExportSession.outputURL = outPutURL;
    //输出文件是否网络优化
    assetExportSession.shouldOptimizeForNetworkUse = YES;
    [assetExportSession exportAsynchronouslyWithCompletionHandler:^{
        if (timer) {
            [timer invalidate];
            timer = nil;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            switch (assetExportSession.status) {
                case AVAssetExportSessionStatusFailed:
                    
                    if (_interceptBlock) {
                        
                        _interceptBlock(assetExportSession.error,outPutURL);
                    }
                    
                    
                    break;
                    
                case AVAssetExportSessionStatusCancelled:{
                    
                    NSLog(@"Export Status: Cancell");
                    
                    break;
                }
                case AVAssetExportSessionStatusCompleted: {
                    
                    if (_interceptBlock) {
                        
                        _interceptBlock(nil,outPutURL);
                    }
                    
                    break;
                }
                case AVAssetExportSessionStatusUnknown: {
                    
                    NSLog(@"Export Status: Unknown");
                }
                case AVAssetExportSessionStatusExporting : {
                    
                    NSLog(@"Export Status: Exporting");
                }
                case AVAssetExportSessionStatusWaiting: {
                    
                    NSLog(@"Export Status: Wating");
                }
                    
            }
            
        });
        
    }];
    
    if (@available(iOS 10.0, *)) {
        timer = [NSTimer scheduledTimerWithTimeInterval:0.05 repeats:YES block:^(NSTimer * _Nonnull timer) {
            
            if (compositionProgressBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    compositionProgressBlock(assetExportSession.progress);
                    
                });
            }
        }];
    } else {
        // Fallback on earlier versions
    }
    
}
@end
