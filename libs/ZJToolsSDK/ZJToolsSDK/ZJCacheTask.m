//
//  ZJCacheTask.m
//  ZJPlayer
//
//  Created by zhengju on 2017/9/14.
//  Copyright © 2017年 郑俱. All rights reserved.
//

#import "ZJCacheTask.h"
#import "NSString+ZJHash.h"

@interface ZJCacheTask()

@property(strong,nonatomic) NSMutableDictionary * memoryCache;
@property (strong, nonatomic, nonnull) NSString *diskCachePath;
@property (strong, nonatomic, nullable) dispatch_queue_t ioQueue;
@property (strong, nonatomic, nonnull) NSFileManager *fileManager;
@end

@implementation ZJCacheTask
- (NSMutableDictionary *)memoryCache{
    if (_memoryCache == nil) {
        _memoryCache = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _memoryCache;
}
+ (instancetype)shareTask
{
    static ZJCacheTask *cachetask = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        cachetask = [[ZJCacheTask alloc]init];
        
//     [cachetask clearCache];//默认删除观看上次记录
    });
    return cachetask;
}
- (instancetype)init{
    if (self = [super init]) {
        _ioQueue = dispatch_queue_create("com.cacheImage.ZJImageCache", DISPATCH_QUEUE_SERIAL);
         _diskCachePath = [self cacheImagePath];
        dispatch_sync(_ioQueue, ^{
            self.fileManager = [NSFileManager new];
        });
    }
    return self;
}
- (NSString *)cacheImagePath{
    // 1.获得沙盒根路径
    NSString *home = NSHomeDirectory();
    // 2.document路径
    NSString *docPath = [home stringByAppendingPathComponent:@"Documents"];
    // 3.文件路径
    NSString *filepath = [docPath stringByAppendingPathComponent:@"cacheImage.plist"];
    return filepath;
}

#pragma mark -缓存图片
- (void)storeImage:(nullable UIImage *)image forKey:(nullable NSString *)key{
    
    if (!image) {
        return;
    }
    
    NSString * md5Str = [key md5String];
    
    [self storeMemoryCacheImage:image forKey:md5Str];
    
    [self storeDiskCacheImage:image forKey:md5Str];

}

//memory
- (void)storeMemoryCacheImage:(nullable UIImage *)image forKey:(nullable NSString *)key{
    @synchronized (self) {
        [self.memoryCache setObject:image forKey:key];
    }
}
//disk
- (void)storeDiskCacheImage:(nullable UIImage *)image forKey:(nullable NSString *)key{
   
    if (!image || !key) {
        return;
    }
    
    dispatch_async(_ioQueue, ^{
        [self _storeDiskCacheImage:image forKey:key];
    });
    
}
- (void)_storeDiskCacheImage:(nullable UIImage *)image forKey:(nullable NSString *)key{

    
    NSMutableDictionary *diskCache = [[NSMutableDictionary alloc] initWithContentsOfFile:_diskCachePath];
    
    if (diskCache == nil) {
        diskCache = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    
    NSData *imageData = UIImagePNGRepresentation(image);//image转data可以深挖，编码策略
    
    [diskCache setObject:imageData forKey:key];
    
    if ([diskCache writeToURL:[NSURL fileURLWithPath:_diskCachePath] atomically:YES]) {
        NSLog(@"diskCache ok");
    }else{
        NSLog(@"diskCache fail");
    }

}

- (nullable UIImage *)imageFromMemoryCacheForKey:(nullable NSString *)key{
    
    NSString * md5Str = [key md5String];
    UIImage * image = nil;
    
    @synchronized (self) {
       image = [self.memoryCache valueForKey:md5Str];
    }
    
    return image;
}

- (nullable UIImage *)imageFromDiskCacheForKey:(nullable NSString *)key{
    
    NSString * md5Str = [key md5String];
    NSMutableDictionary *diskCache = [[NSMutableDictionary alloc] initWithContentsOfFile:_diskCachePath];
    
    UIImage * diskImage = [UIImage imageWithData:[diskCache valueForKey:md5Str]];
    if (diskImage) {
        [self.memoryCache setObject:diskImage forKey:md5Str];
    }
    return diskImage;
}

- (nullable UIImage *)imageFromCacheForKey:(nullable NSString *)key {
    // First check the in-memory cache...
    UIImage *image = [self imageFromMemoryCacheForKey:key];
    if (image) {
        return image;
    }
    
    // Second check the disk cache...
    image = [self imageFromDiskCacheForKey:key];
    return image;
}
@end

@implementation ZJCacheTask (Video)

- (NSString *)path{

    NSString *home = NSHomeDirectory();
    NSString *docPath = [home stringByAppendingPathComponent:@"Documents"];
    NSString *filepath = [docPath stringByAppendingPathComponent:@"videoTask.plist"];
    
    return filepath;
}
- (void)writeToFileUrl:(NSString *)url time: (NSTimeInterval) currentTime{
    
    
    NSString * filepath = [self path];
    
    NSMutableArray *tasks = [[NSMutableArray alloc] initWithContentsOfFile:filepath];
    
    
    if (tasks == nil) {
        tasks = [NSMutableArray arrayWithCapacity:0];
    }
    
    BOOL isHave = NO;
    
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:currentTime];
    
    for (NSMutableDictionary * dic in tasks) {//优化-用hash表，命中率会会高些
        
        if ([dic[@"url"] isEqualToString:url]) {
            
            [dic setObject:date forKey:@"time"];
            
            isHave = YES;
        }
    }
    
    if (isHave == NO) {
        
        NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithCapacity:0];

        [dic setObject:date forKey:@"time"];
        
        if (url) {
            [dic setObject:url forKey:@"url"];
        }

        [tasks addObject:dic];
    }
    
    [tasks writeToFile:filepath atomically:YES];
    
}
- (NSTimeInterval)queryToFileUrl:(NSString *)url{
    
    
    NSTimeInterval time = 0;
    
    NSString * filepath = [self path];
    
    NSMutableArray *tasks = [[NSMutableArray alloc] initWithContentsOfFile:filepath];
    
    for (NSMutableDictionary * dic in tasks) {
        
        if ([dic[@"url"] isEqualToString:url]) {
            
            NSDate * date = [dic objectForKey:@"time"];
            
            time = [date timeIntervalSince1970];
            
        }
    }
    return time;
}
- (void)clearCacheToFileUrl:(NSString *)url{
    [self writeToFileUrl:url time:0];
}
- (void)clearCache{

    NSString * filepath = [self path];
    BOOL blHave=[self.fileManager fileExistsAtPath:filepath];
    if (!blHave) {
        NSLog(@"no  have");
        return ;
    }else {
        NSLog(@" have");
        BOOL blDele= [self.fileManager removeItemAtPath:filepath error:nil];
        if (blDele) {
            NSLog(@"dele success");
        }else {
            NSLog(@"dele fail");
        }
    }
}
@end
