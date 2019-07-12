//
//  ZJLoadingIndicator.m
//  ZJPlayer
//
//  Created by zhengju on 2017/9/15.
//  Copyright © 2017年 郑俱. All rights reserved.
//

#import "ZJLoadingIndicator.h"

#define kLineWidth 5


@interface ZJLoadingIndicator()
@property(strong,nonatomic) CAShapeLayer * progressLayer;
@end


@implementation ZJLoadingIndicator

- (instancetype)init{
    if (self = [super init]) {
        self.hidden = YES;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
- (void)layoutSubviews{
    [super layoutSubviews];
}
- (void)drawRect:(CGRect)rect {
    
    _progress = 1;
    
    CGFloat circleRadius = self.frame.size.width / 2.0;
    
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = circleRadius;

    CGContextRef ctx = UIGraphicsGetCurrentContext();//获取上下文
    CGPoint center = CGPointMake(circleRadius, circleRadius); //设置圆心位置
    CGFloat radius = circleRadius; //设置半径
    CGFloat startA = - M_PI_2; //圆起点位置
    CGFloat endA = -M_PI_2 + M_PI * 2 * _progress; //圆终点位置
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startA endAngle:endA clockwise:YES]; CGContextSetLineWidth(ctx, kLineWidth); //设置线条宽度
    [[UIColor lightGrayColor] setStroke]; //设置描边颜色
    CGContextAddPath(ctx, path.CGPath); //把路径添加到上下文
    CGContextStrokePath(ctx); //渲染

    _progressLayer = [CAShapeLayer layer];//创建一个track shape layer
    _progressLayer.frame = self.bounds;
    _progressLayer.fillColor = [[UIColor clearColor] CGColor]; //填充色为无色
    _progressLayer.strokeColor = [[UIColor whiteColor] CGColor]; //指定path的渲染颜色,这里可以设置任意不透明颜色
    _progressLayer.opacity = 1; //背景颜色的透明度
    _progressLayer.lineCap = kCALineCapRound;//指定线的边缘是圆的
    _progressLayer.lineWidth = kLineWidth;//线的宽度
    UIBezierPath *path1 = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startA endAngle:endA clockwise:YES];//上面说明过了用来构建圆形
    _progressLayer.path =[path1 CGPath]; //把path传递給layer，然后layer会处理相应的渲染，整个逻辑和CoreGraph是一致的。
    [self.layer addSublayer:_progressLayer];
    

    [_progressLayer removeAnimationForKey:@"strokeEndAnimation"];
    
    
    //增加动画
    CABasicAnimation *pathAnimation=[CABasicAnimation animationWithKeyPath:@"strokeEnd"];
  
    pathAnimation.duration = 1;
    pathAnimation.speed = 1;
    pathAnimation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    pathAnimation.fromValue=[NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue=[NSNumber numberWithFloat:1.0f]; pathAnimation.autoreverses=NO;
    pathAnimation.repeatCount = INFINITY;
    _progressLayer.path=path1.CGPath;
    [_progressLayer addAnimation:pathAnimation forKey:@"strokeEndAnimation"];
}

- (void)show{
    self.hidden = NO;
    [self setNeedsDisplay];
}

- (void)dismiss{
    self.hidden = YES;
}
- (void)setProgress:(CGFloat)progress{
    _progress = progress;

    [self setNeedsDisplay];
    
}
@end
