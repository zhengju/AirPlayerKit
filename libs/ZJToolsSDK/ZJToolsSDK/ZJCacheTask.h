//
//  ZJCacheTask.h
//  ZJPlayer
//
//  Created by zhengju on 2017/9/14.
//  Copyright © 2017年 郑俱. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZJCacheTask : NSObject

+ (instancetype)shareTask;

/**
 缓存图片
 */
- (void)storeImage:(nullable UIImage *)image forKey:(nullable NSString *)key;

- (nullable UIImage *)imageFromMemoryCacheForKey:(nullable NSString *)key;

- (nullable UIImage *)imageFromDiskCacheForKey:(nullable NSString *)key;

- (nullable UIImage *)imageFromCacheForKey:(nullable NSString *)key;

@end

@interface ZJCacheTask (Video)
/**
 缓存
 url:当前视频url
 currentTime:已经播放的时间时间点
 */
- (void)writeToFileUrl:(NSString *)url time: (NSTimeInterval) currentTime;
/**
 查询缓存
 url:当前视频url
 */
- (NSTimeInterval)queryToFileUrl:(NSString *)url;
/**
 针对已经播放完毕的视频从头开始播放，给清零
 */
- (void)clearCacheToFileUrl:(NSString *)url;

@end
