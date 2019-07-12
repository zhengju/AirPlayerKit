//
//  ZJProgress.m
//  ZJPlayer
//
//  Created by zhengju on 2017/9/15.
//  Copyright © 2017年 郑俱. All rights reserved.
//

#import "ZJProgress.h"
#import "ZJPlayerSDK.h"



@interface ZJProgress()
@property(strong,nonatomic) UIView * bgView;
@property(strong,nonatomic) UIImageView * speedImg;
@property(strong,nonatomic) UILabel * currentTimeL;
@property(strong,nonatomic) UILabel * AllTimeL;
@property(strong,nonatomic) UILabel * partingL;
@property(strong,nonatomic) UIView * superView;
@property (nonatomic,strong) UIProgressView *progressView;
@end

@implementation ZJProgress

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

    self.backgroundColor = [UIColor clearColor];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 5;
    
    self.bgView = [[UIView alloc]init];
    self.bgView.backgroundColor = [UIColor blackColor];
    self.bgView.alpha = 0.5;
    [self addSubview:self.bgView];

    self.speedImg = [[UIImageView alloc]init];
    self.speedImg.image = [UIImage imageNamed:@"快进"];
    [self addSubview:self.speedImg];
    
    self.currentTimeL = [[UILabel alloc]init];
    self.currentTimeL.textColor = [UIColor redColor];
    self.currentTimeL.textAlignment = NSTextAlignmentRight;
    self.currentTimeL.text = @"00:29";
    [self addSubview:self.currentTimeL];
    
    self.AllTimeL = [[UILabel alloc]init];
    self.AllTimeL.textColor = [UIColor whiteColor];
    self.AllTimeL.text = @"02:08";
    [self addSubview:self.AllTimeL];
    
    self.partingL = [[UILabel alloc]init];
    self.partingL.textColor = [UIColor whiteColor];
    self.partingL.text = @"/";
    
    [self addSubview:self.partingL];
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.progressView.progressTintColor = [UIColor redColor];
    self.progressView.trackTintColor = [UIColor lightGrayColor];
    [self addSubview:self.progressView];
    [self.progressView setProgress:0.0 animated:NO];

    self.frame = CGRectMake((self.superView.bounds.size.width-200)/2.0, (self.superView.bounds.size.height-160)/2.0, 200, 160);

    self.bgView.frame = self.bounds;

    self.speedImg.frame = CGRectMake((self.frameW-48)/2.0, 20, 48, 48);

    self.partingL.frame = CGRectMake((self.frameW-5)/2.0, CGRectGetMaxY(self.speedImg.frame), 5, 25);

    self.currentTimeL.frame = CGRectMake(0, 0, self.frameW-CGRectGetMinX(self.partingL.frame)-6, 25);
    self.currentTimeL.centerY = self.partingL.centerY;

    self.AllTimeL.frame = CGRectMake(CGRectGetMaxX(self.partingL.frame)+5, 0, self.frameW - CGRectGetMaxX(self.partingL.frame)-5, 25);
    self.AllTimeL.centerY = self.partingL.centerY;

    self.progressView.frame = CGRectMake((self.frameW-100)/2.0, CGRectGetMaxY(self.partingL.frame)+10, 100, 3);

}

- (void)show{
    self.alpha = 1;
}
- (void)dismiss{
  
    
    self.alpha = 0;
   
}
- (void)resetFrameisFullScreen:(BOOL)isFullScreen;{
    
    CGFloat height = self.superView.bounds.size.height;
    CGFloat width = self.superView.bounds.size.width;
    if (isFullScreen) {
        
        height = kScreenHeight;
        width = kScreenWidth;
        self.frame = CGRectMake((width-200)/2.0, (height-160)/2.0, 200, 160);
    }else{
        self.frame = CGRectMake((self.superView.frameW-200)/2.0, (self.frameH-160)/2.0, 200, 160);
    }
}
- (void)setCurrentTime:(NSString *)currentTime{
    _currentTime = currentTime;
    self.currentTimeL.text = _currentTime;
}
- (void)setAllTime:(NSString *)allTime{
    _allTime = allTime;
    self.AllTimeL.text  = _allTime;
    
}
- (void)setIsForward:(BOOL)isForward{
    _isForward = isForward;
    if (_isForward) {
        
        self.speedImg.image = [UIImage imageNamed:@"快进"];
    }else{
     
        self.speedImg.image = [UIImage imageNamed:@"快退"];
    }
}
- (void)setProgress:(float)progress{
    _progress = progress;
    [self.progressView setProgress:_progress animated:NO];
}

@end
