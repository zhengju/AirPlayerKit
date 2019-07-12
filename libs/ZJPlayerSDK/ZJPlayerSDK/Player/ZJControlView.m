//
//  ZJControlView.m
//  ZJPlayer
//
//  Created by zhengju on 2017/9/10.
//  Copyright © 2017年 郑俱. All rights reserved.
//

#import "ZJControlView.h"
#import "ZJPlayerSDK.h"
@implementation ZJUISlider

//-(CGRect)trackRectForBounds:(CGRect)bounds
//{
//    bounds.size.height=6;
//    return bounds;
//}

@end

@interface ZJControlView()

@end

@implementation ZJControlView
- (void)setCurrentTime:(NSString *)currentTime{
    _currentTime = currentTime;
    self.nowLabel.text = _currentTime;
    
}
- (void)setRemainingTime:(NSString *)remainingTime{
    _remainingTime = remainingTime;
    self.remainLabel.text = _remainingTime;
}
- (float)sliderValue{
    return self.slider.value;
    
}
- (void)setSliderValue:(float)sliderValue{
    
    self.slider.value = sliderValue;
}
- (void)setSliderMaximumValue:(float)sliderMaximumValue{
    _sliderMaximumValue = sliderMaximumValue;
    if (_sliderMaximumValue > 0) {
        self.slider.maximumValue = _sliderMaximumValue;
    }

}
- (void)setProgress:(float)progress{
    _progress = progress;
     [self.progressView setProgress:_progress animated:NO];
}
- (void)setIsPlay:(BOOL)isPlay{
    _isPlay = isPlay;
    if (_isPlay) {
        [self.playBtn setImage:[UIImage imageNamed:@"ZJPlayerSource.bundle/btn_player_play"] forState:UIControlStateNormal];

    }else{
     
        [self.playBtn setImage:[UIImage imageNamed:@"ZJPlayerSource.bundle/btn_player_pause"] forState:UIControlStateNormal];
    }
}
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self configureUI];
    }
    return self;
}
- (void)configureUI{
    
    //播放按钮
    self.playBtn = [[UIButton alloc]init];
    
    self.isPlay = NO;
    
    self.playBtn.showsTouchWhenHighlighted = YES;
    
    [self.playBtn addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.playBtn];

    self.playBtn.frame = CGRectMake(0, (self.frameH-35)/2.0, 35, 35);

    //放缩按钮
    self.scalingBtn = [[UIButton alloc]init];
    [self.scalingBtn setImage:[UIImage imageNamed:@"放大"] forState:UIControlStateNormal];
    self.scalingBtn.showsTouchWhenHighlighted = YES;
    
    
    [self.scalingBtn bk_addEventHandler:^(id sender) {

        if ([self.delegate respondsToSelector:@selector(clickFullScreen)]) {
            [self.delegate clickFullScreen];
        }

    } forControlEvents:UIControlEventTouchUpInside];
    
    
    [self addSubview:self.scalingBtn];
    
    self.scalingBtn.frame = CGRectMake(self.frameW-40, (self.frameH-35)/2.0, 35, 35);

    
    // 底部左侧时间轴
    self.nowLabel = [[UILabel alloc] init];
    self.nowLabel.textColor = [UIColor whiteColor];
    self.nowLabel.font = [UIFont systemFontOfSize:13];
    self.nowLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:self.nowLabel];
    self.nowLabel.frame = CGRectMake(CGRectGetMaxX(self.playBtn.frame), (self.frameH-35)/2.0, 50, 35);
    
    // 底部进度条
    self.slider = [[ZJUISlider alloc]init];
    self.slider.continuous = YES;
    self.slider.minimumValue = 0.0;
    self.slider.minimumTrackTintColor = [UIColor greenColor];
    self.slider.maximumTrackTintColor = [UIColor clearColor];
    self.slider.value = 0.0;
    
    [self.slider addTarget:self action:@selector(sliderDragValueChange:) forControlEvents:UIControlEventValueChanged];
    
    [self.slider addTarget:self action:@selector(sliderTapValueChange:) forControlEvents:UIControlEventTouchUpInside];
    [self.slider addTarget:self action:@selector(sliderTapValueChange:) forControlEvents:UIControlEventTouchUpOutside];
    [self.slider addTarget:self action:@selector(sliderTapValueChange:) forControlEvents:UIControlEventTouchCancel];
    
    [self.slider setThumbImage:[UIImage imageNamed:@"yuandianxiao"] forState:UIControlStateNormal];
    
    
    UITapGestureRecognizer *tapSlider = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchSlider:)];
    [self.slider addGestureRecognizer:tapSlider];
    [self addSubview:self.slider];
    
    self.slider.frame = CGRectMake(CGRectGetMaxX(self.nowLabel.frame), (self.frameH-20)/2.0, self.frameW - CGRectGetMaxX(self.nowLabel.frame) - self.scalingBtn.frameW-50, 20);

 // 底部缓存进度条
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.progressView.progressTintColor = [UIColor blueColor];
    self.progressView.trackTintColor = [UIColor lightGrayColor];
    [self addSubview:self.progressView];
    [self.progressView setProgress:0.0 animated:NO];
    
    self.progressView.frame = CGRectMake(CGRectGetMinX(self.slider.frame), (self.frameH-2)/2.0, self.slider.frameW, 2);
    
//    CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 3.0f);
//    self.progressView.transform = transform;//设定宽高
    
    [self sendSubviewToBack:self.progressView];
    
    // 底部右侧时间轴
    self.remainLabel = [[UILabel alloc] init];
    self.remainLabel.textColor = [UIColor whiteColor];
    self.remainLabel.font = [UIFont systemFontOfSize:13];
    self.remainLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:self.remainLabel];
    
    self.remainLabel.frame = CGRectMake(CGRectGetMaxX(self.slider.frame), (self.frameH-35)/2.0, 50, 35);

}
- (void)play:(UIButton *)button{
    
    self.isPlay = !self.isPlay;
    
    if (self.isPlay) {
        if ([self.delegate respondsToSelector:@selector(play)]) {
            [self.delegate play];
        }
    }else{
        if ([self.delegate respondsToSelector:@selector(pause)]) {
            [self.delegate pause];
        }
    }
}
// 拖拽的时候调用  这个时候不更新视频进度
- (void)sliderDragValueChange:(UISlider *)slider
{
    if ([self.delegate respondsToSelector:@selector(sliderDragValueChange:)]) {
        [self.delegate sliderDragValueChange:slider];
        
    }
}
// 点击调用  或者 拖拽完毕的时候调用
- (void)sliderTapValueChange:(UISlider *)slider
{
    if ([self.delegate respondsToSelector:@selector(sliderTapValueChange:)]) {
        [self.delegate sliderTapValueChange:slider];
    }
}
// 点击事件的Slider
- (void)touchSlider:(UITapGestureRecognizer *)tap{
    if ([self.delegate respondsToSelector:@selector(touchSlider:)]) {
        [self.delegate touchSlider:tap];
        
    }
}
- (void)resetFrame{
     self.playBtn.frame = CGRectMake(0, (self.frameH-35)/2.0, 35, 35);
   
    self.scalingBtn.frame = CGRectMake(self.frameW-40, (self.frameH-35)/2.0, 35, 35);
   
    self.nowLabel.frame = CGRectMake(CGRectGetMaxX(self.playBtn.frame), (self.frameH-35)/2.0, 50, 35);
    
    self.slider.frame = CGRectMake(CGRectGetMaxX(self.nowLabel.frame), (self.frameH-20)/2.0, self.frameW - CGRectGetMaxX(self.nowLabel.frame) - self.scalingBtn.frameW-50, 20);

    self.progressView.frame = CGRectMake(CGRectGetMinX(self.slider.frame), (self.frameH-2)/2.0, self.slider.frameW, 2);
    
//    CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 3.0f);
//    self.progressView.transform = transform;//设定宽高

    self.remainLabel.frame = CGRectMake(CGRectGetMaxX(self.slider.frame), (self.frameH-35)/2.0, 50, 35);
}
@end
