//
//  AirPlayBgControlView.m
//  ZJPlayerSDK
//
//  Created by leeco on 2019/7/15.
//  Copyright © 2019 zsw. All rights reserved.
//

#import "AirPlayBgControlView.h"
#import "ZJPlayerSDK.h"
@interface AirPlayBgControlView()
@property(nonatomic, strong) UILabel * deviceL;
@property(nonatomic, strong) UILabel * statusL;
@property(nonatomic, strong) UIImageView * upbgView;

@property(nonatomic, strong) UIButton * quitOutBtn;
@property(nonatomic, strong) UIButton * changeDeviceBtn;
@end


@implementation AirPlayBgControlView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self configureUI];
    }
    return self;
}
- (void)configureUI{
    
    self.backgroundColor = [UIColor blackColor];
    
    self.upbgView = [[UIImageView  alloc]initWithFrame:CGRectMake(100, 0, self.frameW-100*2, 100)];
    self.upbgView.backgroundColor = [UIColor grayColor];
    [self addSubview:self.upbgView];
    
    
    self.deviceL = [[UILabel alloc]initWithFrame:CGRectMake(0, 30, self.upbgView.frameW, 30)];
    self.deviceL.textColor = [UIColor whiteColor];
    self.deviceL.textAlignment = NSTextAlignmentCenter;
    self.deviceL.text = @"乐播投屏";
    [self.upbgView addSubview:self.deviceL];
    
    self.statusL = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.deviceL.frame)+5, self.upbgView.frameW, 30)];
    self.statusL.textColor = [UIColor whiteColor];
    self.statusL.textAlignment = NSTextAlignmentCenter;
    self.statusL.text = @"正在投屏";
    [self.upbgView addSubview:self.statusL];
    
    self.quitOutBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.frameW/2.0-101, CGRectGetMaxY(self.upbgView.frame)+5, 100, 35)];
    [self.quitOutBtn setTintColor:[UIColor whiteColor]];
    self.quitOutBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [self.quitOutBtn setTitle:@"退出投屏" forState:UIControlStateNormal];
    self.quitOutBtn.backgroundColor = [UIColor grayColor];
    [self.quitOutBtn bk_addEventHandler:^(id sender) {
        if ([self.delegate respondsToSelector:@selector(backOut)]) {
            [self.delegate backOut];
        }
    } forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.quitOutBtn];
    
    self.changeDeviceBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.frameW/2.0+1, CGRectGetMaxY(self.upbgView.frame)+5, 100, 35)];
    [self.changeDeviceBtn setTintColor:[UIColor whiteColor]];
    self.changeDeviceBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [self.changeDeviceBtn setTitle:@"换设备" forState:UIControlStateNormal];
    self.changeDeviceBtn.backgroundColor = [UIColor grayColor];
    [self.changeDeviceBtn bk_addEventHandler:^(id sender) {
        if ([self.delegate respondsToSelector:@selector(changeDevice)]) {
            [self.delegate changeDevice];
        }
    } forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.changeDeviceBtn];
    
}
- (void)resetFrame:(BOOL)fullScreen superViewFrame:(CGRect)frame{

    if (fullScreen) {//全屏
        self.frame = CGRectMake(0, 0, frame.size.height, frame.size.width);
        
        
        self.upbgView.frame = CGRectMake(100, 0, self.frameW-100*2, 170);
        self.deviceL.frame = CGRectMake(0, 30+50, self.upbgView.frameW, 30);
        self.statusL.frame = CGRectMake(0, CGRectGetMaxY(self.deviceL.frame)+5, self.upbgView.frameW, 30);
        self.quitOutBtn.frame = CGRectMake(self.frameW/2.0-100, CGRectGetMaxY(self.upbgView.frame)+5, 100, 35);
        self.changeDeviceBtn.frame = CGRectMake(self.frameW/2.0, CGRectGetMaxY(self.upbgView.frame)+5, 100, 35);
    }else{
        self.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        
        
        self.upbgView.frame = CGRectMake(100, 0, self.frameW-100*2, 100);
        self.deviceL.frame = CGRectMake(0, 30, self.upbgView.frameW, 30);
        self.statusL.frame = CGRectMake(0, CGRectGetMaxY(self.deviceL.frame)+5, self.upbgView.frameW, 30);
        self.quitOutBtn.frame = CGRectMake(self.frameW/2.0-100, CGRectGetMaxY(self.upbgView.frame)+5, 100, 35);
        self.changeDeviceBtn.frame = CGRectMake(self.frameW/2.0, CGRectGetMaxY(self.upbgView.frame)+5, 100, 35);
    }
    
}
@end
