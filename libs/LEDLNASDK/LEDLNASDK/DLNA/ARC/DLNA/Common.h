//
//  Common.h
//  LEDLNASDK
//
//  Created by leeco on 2019/7/5.
//  Copyright © 2019 zsw. All rights reserved.
//

#ifndef Common_h
#define Common_h

////服务类型，这里根据大众化只定义了两个，其实可以更多，具体根据设备来定义
typedef NS_ENUM(NSInteger, LEUpnpServerType) {
    /**投屏*/
    ServerTypeAVTransport = 0,
    /**控制*/
    ServerTypeRenderingControl,
};

#endif /* Common_h */
