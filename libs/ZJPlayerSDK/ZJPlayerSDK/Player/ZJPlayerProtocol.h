//
//  ZJPlayerProtocol.h
//  ZJPlayerSDK
//
//  Created by leeco on 2019/3/18.
//  Copyright © 2019年 zsw. All rights reserved.
//

#ifndef ZJPlayerProtocol_h
#define ZJPlayerProtocol_h

@protocol ZJPlayerProtocolDelegate <NSObject>

- (void)setFrame:(CGRect)frame url:(NSURL *)videoUrl playerItem:(AVPlayerItem *)playerItem currentTime:(CMTime )currentTime;

@end



#endif /* ZJPlayerProtocol_h */
