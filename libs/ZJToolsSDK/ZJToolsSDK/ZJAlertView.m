//
//  ZJAlertView.m
//  Trip
//
//  Created by zhengju on 16/9/5.
//  Copyright © 2016年 郑俱. All rights reserved.
//

#import "ZJAlertView.h"

//整个view的展示宽度
#define    ZJfadeWidth          [UIScreen mainScreen].bounds.size.width - 120

@implementation ZJAlertView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //初始化
        self.textFont           =   [UIFont systemFontOfSize:15.0f];
        self.fadeWidth          =   ZJfadeWidth;
        self.fadeBGColor        =   [UIColor colorWithRed:94.0/255.0f green:105.0/255.0f blue:107.0/255.0f alpha:1.0f];
        self.titleColor         =   [UIColor whiteColor];
        self.textOffWidth       =   18;
        self.textOffHeight      =   8;
        self.textBottomHeight   =   120;
        self.fadeTime           =   1.5;
        self.FadeBGAlpha        =   0.8;
    }
    return self;
}


- (void)showAlertWith:(NSString *)str
{
    self.alpha = 0;
    
    NSDictionary *attribute = @{NSFontAttributeName: self.textFont};
    CGRect rect = [str boundingRectWithSize:CGSizeMake(ZJfadeWidth, FLT_MAX) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil];
    
    CGFloat width  = rect.size.width  + self.textOffWidth;
    CGFloat height = rect.size.height + self.textOffHeight;
    
    
    self.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width- width)/2, [UIScreen mainScreen].bounds.size.height /2.0, width, height);
    self.backgroundColor = self.fadeBGColor;
    
    //圆角
    self.layer.masksToBounds = YES;
    
    //一行大圆角，超过一行小圆角
    if (rect.size.height > 21) {
        
        self.layer.cornerRadius = 10/2;
    }else
        {
        self.layer.cornerRadius = height/2;
        }
    
    
    UILabel *tmpLabel = [[UILabel alloc] init];
    tmpLabel.text = str;
    tmpLabel.numberOfLines = 0;
    tmpLabel.backgroundColor = [UIColor clearColor];
    tmpLabel.textColor = self.titleColor;
    tmpLabel.textAlignment = NSTextAlignmentCenter;
    tmpLabel.font = self.textFont;
    tmpLabel.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [self addSubview:tmpLabel];
    
    
    
    
    [([[UIApplication sharedApplication] delegate]).window addSubview:self];
    
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.3f];
    self.alpha = self.FadeBGAlpha;
    [UIView commitAnimations];
    
    //存在时间
    [self performSelector:@selector(fadeAway) withObject:nil afterDelay:self.fadeTime];
}
// 渐变消失
- (void)fadeAway
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5f];
    self.alpha = .0;
    [UIView commitAnimations];
    [self performSelector:@selector(remove) withObject:nil afterDelay:0.5f];
}
// 从上层视图移除并释放
- (void)remove
{
    [self removeFromSuperview];
}

+ (UIWindow *)mainWindow
{
    UIApplication *app = [UIApplication sharedApplication];
    if ([app.delegate respondsToSelector:@selector(window)])
    {
        return [app.delegate window];
    }
    
    {
        return [app keyWindow];
    }
}


@end
