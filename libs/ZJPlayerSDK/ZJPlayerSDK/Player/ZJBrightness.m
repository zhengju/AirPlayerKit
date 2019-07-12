//
//  ZJBrightness.m
//  ZJPlayer
//
//  Created by zhengju on 2017/9/18.
//  Copyright © 2017年 郑俱. All rights reserved.
//

#import "ZJBrightness.h"

#import "ZJPlayerSDK.h"

@interface ZJBrightness()
@property(strong,nonatomic) UIImageView * brightnessImg;
@property(strong,nonatomic) UILabel * brightL;
@property(strong,nonatomic) UIView * superView;
@end

@implementation ZJBrightness
- (instancetype)initWithSuperView:(UIView *)superView{
    if (self = [super init]) {
        self.alpha = 0;
        
        self.superView = superView;
        [self.superView addSubview:self];
        [self configureUI];
    }
    return self;
}
- (void)configureUI{
    
    self.backgroundColor = [UIColor whiteColor];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 8;
    
    [self addKVOObserver];
    
    
    self.brightL = [[UILabel alloc]init];
    self.brightL.text = @"亮度";
    self.brightL.textColor = RGBACOLOR(90, 90, 90, 1.0);
    [self addSubview:self.brightL];
    
    
    self.brightnessImg = [[UIImageView alloc]init];
    self.brightnessImg.image = [UIImage imageNamed:@"亮度"];
    [self addSubview:self.brightnessImg];
    self.frame = CGRectMake(0, 0, 150, 150);

    
    self.frame = CGRectMake((self.superView.bounds.size.width-150)/2.0, (self.superView.bounds.size.height-150)/2.0, 150, 150);
    
    self.brightL.frame = CGRectMake(0, 0, self.frameW, 25);
    self.brightL.centerX = self.centerX;

    self.brightnessImg.frame = CGRectMake((self.frameW-75)/2.0, (self.frameH-75)/2.0, 75, 75);
    
    for (int i = 0; i < 16; i++) {
        CGFloat width = 9;
        
        CGFloat height = 6;

        UIView * lattice = [[UIView alloc]initWithFrame:CGRectMake(10 + i*(width-1), self.frame.size.height - height -10, width, height)];
        lattice.tag = 1001 + i;
        lattice.backgroundColor = [UIColor whiteColor];
        lattice.layer.borderColor = RGBACOLOR(90, 90, 90, 1.0).CGColor;
        lattice.layer.borderWidth = 1;
        
        [self addSubview:lattice];
    }
}
- (void)addKVOObserver {
    [[UIScreen mainScreen] addObserver:self
                            forKeyPath:@"brightness"
                               options:NSKeyValueObservingOptionNew context:NULL];
}
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    CGFloat levelValue = [change[@"new"] floatValue];
    
//    [self removeTimer];
    [self show];
    self.progress = levelValue;
}

- (void)show{
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
//        [self addtimer];
    }];
}
- (void)dismiss{

    if (self.alpha == 1.0) {
        [UIView animateWithDuration:0.5 animations:^{
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
//            [self removeTimer];
        }];
    }
    
}
- (void)resetFrameisFullScreen:(BOOL)isFullScreen;{
    
    CGFloat height = self.superView.bounds.size.height;
    CGFloat width = self.superView.bounds.size.width;
    if (isFullScreen) {
        
        height = kScreenHeight;
        
        width = kScreenWidth;
        
        self.frame = CGRectMake((width-150)/2.0, (height-150)/2.0, 150, 150);
    }else{
        self.frame = CGRectMake((self.superView.frameW-150)/2.0, (self.superView.frameH-150)/2.0, 150, 150);
    }

}
- (void)setProgress:(float)progress{
    _progress = progress;
    
    
    for (int i = 0; i < 16; i++) {
        
        
        UIView * lattice = [self viewWithTag:1001 + i];
        if (i <= _progress*16) {
             lattice.backgroundColor = [UIColor whiteColor];
       
        }else{
         
            lattice.backgroundColor =RGBACOLOR(90, 90, 90, 1.0);
        }

    }
}
@end
