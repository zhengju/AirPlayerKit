//
//  AVAResourceLoaderManager.h
//  ZJPlayer
//
//  Created by zhengju on 2017/9/18.
//  Copyright © 2017年 郑俱. All rights reserved.
//边下载边播放

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface ZJResourceLoaderManager : NSObject<AVAssetResourceLoaderDelegate>

@end
@interface ZJResourceLoaderManager (Convenient)
- (AVPlayerItem *)playerItemWithURL:(NSURL *)url;
@end
