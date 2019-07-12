//
//  ZJCustomTools.h
//  ZJPlayer
//
//  Created by zhengju on 2017/9/26.
//  Copyright © 2017年 郑俱. All rights reserved.
//集成各种方法的工具

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^InterceptBlock)(NSError* error,NSURL* url);
typedef void (^CompleteBlock)(NSError* error,NSURL* url);
@interface ZJCustomTools : NSObject
+(id)shareCustomTools;
/**
 获取视频第一帧 返回图片
 */
+ (UIImage*) getVideoPreViewImage:(NSURL *)path;
/**
 只能截屏，但如果是截取视频的话，没有播放的图片，播放器里面都是黑色的。 暂时没有用
 */
+ (UIImage *)captureCurrentView:(UIView *)view;
+ (UIImage *)fetchScreenshot:(CALayer *)layer;
/**
 *  截取指定时间的视频缩略图
 *
 *  @param timeBySecond 时间点
 */
+ (void)thumbnailImageRequest:(CGFloat )timeBySecond url:(NSString *)urlStr success:(void(^)(UIImage * image))successBlock;

- (void)interceptVideoAndVideoUrl:(NSURL *)videoUrl withOutPath:(NSString *)outPath outputFileType:(NSString *)outputFileType range:(NSRange)videoRange compositionProgressBlock:(void(^)(CGFloat progress))compositionProgressBlock intercept:(InterceptBlock)interceptBlock;
@end
