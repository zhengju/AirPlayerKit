//
//  CLUPnPDevice.h
//  DLNA_UPnP
//
//  Created by ClaudeLi on 2017/7/31.
//  Copyright © 2017年 ClaudeLi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Common.h"

@class CLServiceModel;
/**
 设备模型
 */
@interface CLUPnPDevice : NSObject

@property (nonatomic, copy) NSString    *uuid;
@property (nonatomic, strong) NSURL     *loaction;
@property (nonatomic, copy) NSString    *URLHeader;

@property (nonatomic, copy) NSString *friendlyName;
@property (nonatomic, copy) NSString *modelName;

@property (nonatomic, strong) CLServiceModel *AVTransport;
@property (nonatomic, strong) CLServiceModel *RenderingControl;

/**控制访问路径*/
-(NSString*)controlURLWithServerType:(LEUpnpServerType)serverType;

/**订阅访问路径*/
- (NSString*)eventSubURLWithServerType:(LEUpnpServerType)serverType;

- (void)setArray:(NSArray *)array;

@end


/**
 设备里面的服务模型
 */
@interface CLServiceModel : NSObject

///服务类型
@property (nonatomic, copy) NSString *serviceType;
///服务id
@property (nonatomic, copy) NSString *serviceId;
///控制事件的地址
@property (nonatomic, copy) NSString *controlURL;
///订阅事件的地址
@property (nonatomic, copy) NSString *eventSubURL;
///获取设备描述文档URL
@property (nonatomic, copy) NSString *SCPDURL;

/**遍历设备下面的xml数据*/
- (void)setArray:(NSArray *)array;

@end
