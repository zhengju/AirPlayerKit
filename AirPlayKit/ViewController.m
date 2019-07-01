//
//  ViewController.m
//  AirPlayKit
//
//  Created by leeco on 2019/6/27.
//  Copyright © 2019 zsw. All rights reserved.
//

#import "ViewController.h"


#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import <LEDLNASDK/MRDLNA.h>

@interface ViewController ()<DLNADelegate>
{
    BOOL _isPlaying;
    BOOL _airPlay;//是否是airplay
}
@property(nonatomic,strong) AVPlayer        * avPlayer;
@property(nonatomic,strong) AVPlayerItem    * playerItem;
@property(nonatomic,strong) AVPlayerLayer   * playerLayer;
@property(nonatomic,strong) MPVolumeView     * volumeView;
@property(nonatomic,strong) UIButton     * mpButton;
@property (nonatomic,assign)float  totalTime;
@property (nonatomic,assign)float  currentTime;//播放时间
@property (weak, nonatomic) IBOutlet UILabel *currentrender;

@property (weak, nonatomic) IBOutlet UIView *playerView;
@property(nonatomic,strong) MRDLNA *dlnaManager;
@property(nonatomic, strong) NSArray * devices;
@property(nonatomic, strong) CLUPnPDevice * currentDevice;
@property (weak, nonatomic) IBOutlet UILabel *timeInfoLabel;
@property (weak, nonatomic) IBOutlet UISlider *playSlider;
@property (weak, nonatomic) IBOutlet UILabel *voiceLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.dlnaManager = [MRDLNA sharedMRDLNAManager];

    self.dlnaManager.delegate = self;
    
    [self.dlnaManager startDLNA];

    [self.dlnaManager startSearch];
    
    self.view.backgroundColor = [UIColor blueColor];
    [self addNotification];
    [self initPlayer];
    
    [self sendTestRequest];
    
}
/**
 DLNA功能只有在用户允许了网络权限后才能使用
 */
-(void)sendTestRequest{
    NSURL *url = [NSURL URLWithString:@"https://www.baidu.com"];
    NSMutableURLRequest *requst = [[NSMutableURLRequest alloc]initWithURL:url];
    requst.HTTPMethod = @"GET";
    requst.timeoutInterval = 5;
    
    [NSURLConnection sendAsynchronousRequest:requst queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (!connectionError.description) {
            NSLog(@"网络正常");
        }else{
            NSLog(@"=========>网络异常");
        }
    }];
}
- (IBAction)sliderValueAction:(UISlider *)sender {
    
    if (_airPlay) {
        
        CMTime time = CMTimeMake(sender.value*self.totalTime, 1);
        [self.avPlayer seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        }];
        
    }else{
        [self.dlnaManager seekChanged:sender.value*self.totalTime];
    }

}
#pragma mark - 全屏
- (IBAction)clickToFullScreen:(UIButton *)sender {
    
}
#pragma mark - 关闭投屏
- (IBAction)clickToClose:(UIButton *)sender {
    if (_airPlay) {
        
    }else{//dlna
        [self.dlnaManager endDLNA];
        [self.dlnaManager close];
        _airPlay = YES;
        [self.avPlayer seekToTime:CMTimeMake(self.currentTime, 1) completionHandler:^(BOOL finished) {
            [self.avPlayer play];
        }];
        self.currentrender.text = @"乐播投屏(无)";
    }
}

#pragma mark -切换
- (IBAction)clickToNext:(UIButton *)sender {
    
    NSString * url = @"https://www.apple.com/105/media/us/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-tpl-cc-us-20170912_1280x720h.mp4";
    
    
    if (_airPlay) {
        
        self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:url]];
        self.avPlayer = [AVPlayer playerWithPlayerItem:_playerItem];
        [self.avPlayer play];
        
    }else{
        self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:url]];
        self.avPlayer = [AVPlayer playerWithPlayerItem:_playerItem];
        [self.avPlayer pause];
        
        
        NSString *testVideo = url;
        [self.dlnaManager playTheURL:testVideo];
    }
}

- (IBAction)clickToPlay:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    _isPlaying = !_isPlaying;
    
    if (_airPlay == NO) {//当前是dlan
        if (_isPlaying) {
            [self.dlnaManager dlnaPlay];
        }else{
            [self.dlnaManager dlnaPause];
        }
    }else{
        if (_isPlaying) {
            [self.avPlayer play];
        }else{
            [self.avPlayer pause];
        }
    }

}
#pragma mark - 搜索
- (IBAction)clickToSearchRender:(UIButton *)sender {
    [self.dlnaManager startSearch];
}


- (IBAction)clickToChooseRender:(UIButton *)sender {

    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"渲染器"
                                                                              message:@"请选择渲染器"
                                                                       preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * cancelAction =[UIAlertAction actionWithTitle:@"取消"
                                                           style:(UIAlertActionStyleCancel)
                                                         handler:NULL];
    [alertController addAction:cancelAction];
    
    for (int i = 0;  i < self.devices.count; i ++) {
        __weak typeof(self) wSelf = self;
        
        CLUPnPDevice * renderDevice = self.devices[i];
        
        UIAlertAction * action = [UIAlertAction actionWithTitle:renderDevice.friendlyName style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            wSelf.currentDevice = renderDevice;
            
            NSString *testUrl = @"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4";
            CLUPnPDevice * device = self.devices.firstObject;
            wSelf.dlnaManager.device = device;
            wSelf.dlnaManager.playUrl = testUrl;
            [wSelf.dlnaManager startDLNA];
            [wSelf.dlnaManager dlnaPlay];
            [wSelf.dlnaManager seekChanged:CMTimeGetSeconds(self.avPlayer.currentItem.currentTime)];
            
            
            self.currentrender.text = [NSString stringWithFormat:@"%@(DLNA)",device.friendlyName];
            
        }];
        [alertController addAction:action];
    }
    
    UIAlertAction * action = [UIAlertAction actionWithTitle:@"AirPlay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self->_airPlay = YES;
        [self.mpButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }];
    [alertController addAction:action];
    
    [self presentViewController:alertController animated:YES completion:NULL];
    

}
- (IBAction)clickToAddVoice:(UIButton *)sender {

    [self.dlnaManager volumeJumpValue:5];
}
- (IBAction)clickToReduceVoice:(UIButton *)sender {

    [self.dlnaManager volumeJumpValue:-5];
}
- (IBAction)quickBack:(UIButton *)sender {
    NSLog(@"快退...");
    [self.dlnaManager dlnaJump:-5.0];
}
- (IBAction)quickGo:(UIButton *)sender {
    NSLog(@"快进...");
    [self.dlnaManager dlnaJump:5.0];
}

-(void)addNotification
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    //检测当前是否正在投影
    [center addObserver:self selector:@selector(wirelessRouteActiveNotification:)
                   name:MPVolumeViewWirelessRouteActiveDidChangeNotification object:nil];
    //检测当前是否 有支持airPlayer的无线设备
    [center addObserver:self selector:@selector(wirelessAvailableNotification:)
                   name:MPVolumeViewWirelessRoutesAvailableDidChangeNotification object:nil];
}
-(void)initPlayer
{
    self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:@"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4"]];
    self.avPlayer = [AVPlayer playerWithPlayerItem:_playerItem];
    
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:_avPlayer];
    self.playerLayer.frame = self.playerView.bounds;
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    self.playerLayer.backgroundColor = [UIColor blackColor].CGColor;
    [self.playerView.layer addSublayer:_playerLayer];
    [self.avPlayer play];
    _isPlaying = YES;
    _airPlay = YES;
    //隐藏自带的按钮
    self.volumeView = [[MPVolumeView alloc]init];
    [self.volumeView setShowsVolumeSlider:NO];
    [self.volumeView sizeToFit];
    self.volumeView.center = CGPointMake(-1000, -1000);

    [self.view addSubview:_volumeView];

    for (UIButton *button in self.volumeView.subviews) {
        if ([button isKindOfClass:[UIButton class]]) {
            self.mpButton = button;
            NSLog(@"%@",button);
        }
    }       
    
    if (@available(iOS 10.0, *)) {
       [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:YES
                                                            block:^(NSTimer * _Nonnull timer) {
                                                               
                                                                [self timeTimer];

                                                            }];
    } else {
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timeTimer) userInfo:nil repeats:YES];
    }

}

- (void)timeTimer{
    if (self.avPlayer.rate == 1) {
        
        self.totalTime = CMTimeGetSeconds(self.avPlayer.currentItem.duration);
        
        self.playSlider.value = CMTimeGetSeconds(self.avPlayer.currentItem.currentTime)/CMTimeGetSeconds(self.avPlayer.currentItem.duration);
        
        self.timeInfoLabel.text = [NSString stringWithFormat:@"%@/%@",[self.dlnaManager timeFormatted:CMTimeGetSeconds(self.avPlayer.currentItem.currentTime)],[self.dlnaManager timeFormatted:CMTimeGetSeconds(self.avPlayer.currentItem.duration)]];
        
    }
    
    if (!self->_airPlay && [self.dlnaManager getIsPlaying]) {
        
        [self.dlnaManager getPositionInfo];
    }
}

-(void)wirelessRouteActiveNotification:(NSNotification*) notification
{
    MPVolumeView* volumeView = (MPVolumeView*)notification.object;
    
    //当前投影的设备是否 可以 投影
    if(volumeView.isWirelessRouteActive) {
        //正在投影 获取到投影设备的名字
        
        NSString * airPlayerName = [self activeAirplayOutputRouteName];
        NSLog(@"%@",airPlayerName);
        if (airPlayerName) {
            _airPlay = YES;
            self.currentrender.text = [NSString stringWithFormat:@"%@(AIRPLAY)",airPlayerName];
        }

    } else {
        //没有投影或者是 取消了投影
        self.currentrender.text = @"没有投影";
    }
    
}

-(void)wirelessAvailableNotification:(NSNotification*) notification
{
    MPVolumeView* volumeView = (MPVolumeView*)notification.object;
    
    if (volumeView.wirelessRoutesAvailable) {
        
        
        NSLog(@"有DLNA投影设备");
    }else{

        NSLog(@"没有DLNA投影设备");
        
    }
}

//获取设备名字
- (NSString*)activeAirplayOutputRouteName
{
    AVAudioSession* audioSession = [AVAudioSession sharedInstance];
    AVAudioSessionRouteDescription* currentRoute = audioSession.currentRoute;
    for (AVAudioSessionPortDescription* outputPort in currentRoute.outputs){
        if ([outputPort.portType isEqualToString:AVAudioSessionPortAirPlay])
            return outputPort.portName;
    }
    
    return nil;
}

#pragma mark - DLNADelegate
- (void)searchDLNAResult:(NSArray *)devicesArray{
    self.devices = devicesArray;
    
    if (devicesArray.count == 0 ) {
        return;
    }
    
    
    
    
}

- (void)dlnaStartPlay{
    _airPlay = NO;
    [self.avPlayer pause];
    [self.dlnaManager getVolume];//获取音量
}

- (void)dlnaGetVolumeResponse:(NSString *)volume{
    NSLog(@"volum:%@",volume);

        dispatch_async(dispatch_get_main_queue(), ^{
            self.voiceLabel.text =  [NSString stringWithFormat:@"%ld",[volume integerValue]/5];

        });

}
- (void)dlnaGetPositionInfoResponse:(CLUPnPAVPositionInfo *)info{
   
    self.totalTime = info.trackDuration;
    
        dispatch_async(dispatch_get_main_queue(), ^{
            self.playSlider.value = info.relTime/info.trackDuration;
            self.currentTime = info.relTime;
            self.timeInfoLabel.text = [NSString stringWithFormat:@"%@/%@",[self.dlnaManager timeFormatted:info.relTime],[self.dlnaManager timeFormatted:info.trackDuration]];
        });

    NSLog(@"upnpGetPositionInfoResponse %f %f %f",info.trackDuration,info.absTime,info.relTime);
}
@end
