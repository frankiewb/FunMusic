//
//  MusicPlayerViewController.m
//  FunMusic
//
//  Created by frankie on 15/12/31.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import "MusicPlayerViewController.h"
#import "PlayerInfo.h"
#import "SongInfo.h"
#import "ChannelInfo.h"
#import "ChannelGroup.h"
#import "FunServer.h"
#import "NSTimer+Util.h"
#import "UIColor+Util.h"
#import <MediaPlayer/MediaPlayer.h>
#import <LDProgressView.h>
#import <MarqueeLabel.h>
#import <Masonry.h>
#import <UIImageView+WebCache.h>



static const CGFloat kLabelFont      = 15;
static const CGFloat kBigLabelFont   = 22;
static const CGFloat kScrollDuration = 80;
static const CGFloat kFadeLength     = 10;
static const CGFloat kNOPlayingAlpha = 0.2;
static const CGFloat kPlayingAlpha   = 1;
static const CGFloat kTimeInterval   = 0.02;


//该页面在不同屏幕下会有形变，建议采用比例坐标约束

static const CGFloat kPlayerImageTop              = 20;
static const CGFloat kPlayerImageSideLengthFactor = 0.56;
static const CGFloat kTimeLabelTopFactor          = 1.083;
static const CGFloat kTimeProgressBarTopFactor    = 1.060;
static const CGFloat kSongTitleTopFactor          = 1.055;
static const CGFloat kSongArtistTopFactor         = 1.055;
static const CGFloat kButtonTopFactor             = 1.17;
static const CGFloat kLabelWidthFactor            = 0.56;
static const CGFloat kLabelHeightFactor           = 0.053;
static const CGFloat kProgressBarHeight           = 10;
static const CGFloat kButtonHeightWidthFactor     = 0.083;
static const CGFloat kPauseButtonXFactor          = 0.35;
static const CGFloat kHeartButtonXFactor          = 1;
static const CGFloat kNextButtonXFactor           = 1.65;


typedef NS_ENUM(NSInteger, songButtonType)
{
    songButtonTypePause = 1,
    songButtonTypeLike,
    songButtonTypSkip
};

@interface MusicPlayerViewController ()
{
    BOOL isPlaying;
    NSTimer *timer;
    NSInteger currentTimeMinutes;
    NSInteger currentTimeSeconds;
    NSMutableString *currentTimeString;
    NSInteger totalTimeMinutes;
    NSInteger totalTimeSeconds;
    NSMutableString *totalTimeString;
    NSMutableString *timerLabelSring;
    NSMutableArray *songOperationButtonList;
    FunServer *funServer;
    PlayerInfo *currentPlayerInfo;
    MPMoviePlayerController *musicPlayer;
}


@property (nonatomic, strong) UIImageView *musicPlayerImage;
@property (nonatomic, strong) UIImageView *musicPlayerImageBlock;
@property (nonatomic, strong) LDProgressView *timeProgressBar;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) MarqueeLabel *songTitleLabel;
@property (nonatomic, strong) MarqueeLabel *songArtistLabel;

@end

@implementation MusicPlayerViewController


- (void)dawnAndNightMode
{
    self.view.backgroundColor  = [UIColor themeColor];
    _timeLabel.textColor       = [UIColor standerGreyTextColor];
    _songTitleLabel.textColor  = [UIColor standerTextColor];
    _songArtistLabel.textColor = [UIColor standerGreyTextColor];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    funServer = [[FunServer alloc] init];
    currentPlayerInfo = [funServer fmGetCurrentPlayerInfo];
    musicPlayer = [funServer fmGetCurrentMusicPlayer];
    [self setUpUI];
    [self setAutoLayout];
    [self setMusicPlayerInfo];
    //解决NSTimer保留环问题
    __weak MusicPlayerViewController *weakSelf = self;
    timer = [NSTimer fmScheduledTimerWithTimeInterval:kTimeInterval
                                                block:^{[weakSelf updateTimeProgress];}
                                             repeates:YES];
    
    [self refreshMusicPlayer];
    //************************************Block Function**********************************************************
    funServer.getSongListFail = ^()
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"获取音乐失败"
                                                                                 message:@"请检查网络是否连接"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
        [alertController addAction:okAction];
        [weakSelf presentViewController:alertController animated:YES completion:nil];
    };
    //**************************************************************************************************************
    
}


- (void)updateTimeProgress
{
    currentTimeMinutes = (unsigned)musicPlayer.currentPlaybackTime / 60;
    currentTimeSeconds = (unsigned)musicPlayer.currentPlaybackTime % 60;
    
    //专辑图片旋转
    _musicPlayerImage.transform = CGAffineTransformRotate(_musicPlayerImage.transform, M_PI / 1440);
    if (currentTimeSeconds < 10)
    {
        currentTimeString = [NSMutableString stringWithFormat:@"%ld:0%ld",(long)currentTimeMinutes,(long)currentTimeSeconds];
    }
    else
    {
        currentTimeString = [NSMutableString stringWithFormat:@"%ld:%ld",(long)currentTimeMinutes,(long)currentTimeSeconds];
    }
    timerLabelSring = [NSMutableString stringWithFormat:@"%@/%@",currentTimeString,totalTimeString];
    _timeLabel.text = timerLabelSring;
    _timeProgressBar.progress = musicPlayer.currentPlaybackTime/[currentPlayerInfo.currentSong.songTimeLong integerValue];
}



- (void)setUpUI
{
    //初始化背景颜色
    self.view.backgroundColor = [UIColor themeColor];
    
    //初始化PlayerImage界面
    _musicPlayerImage = [[UIImageView alloc] init];
    _musicPlayerImage.layer.masksToBounds = YES;
    _musicPlayerImage.layer.cornerRadius = (kPlayerImageSideLengthFactor * [UIScreen mainScreen].bounds.size.width)/2;
    [self.view addSubview:_musicPlayerImage];
    
    //初始化PlayerImageBlock界面
    _musicPlayerImageBlock = [[UIImageView alloc] init];
    //[_musicPlayerImageBlock setImage:[UIImage imageNamed:@"albumBlock-musicPlayer"]];
    _musicPlayerImageBlock.layer.masksToBounds = YES;
    [self.view addSubview:_musicPlayerImageBlock];
    
    //初始化TimeLabel
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.textColor = [UIColor standerGreyTextColor];
    _timeLabel.font = [UIFont systemFontOfSize:kLabelFont];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_timeLabel];
    
    //初始化TimeProgressBar,具体属性再调整
    _timeProgressBar = [[LDProgressView alloc] init];
    _timeProgressBar.color            = [UIColor standerGreenTextColor];
    _timeProgressBar.flat             = @YES;
    _timeProgressBar.showText         = @NO;
    _timeProgressBar.showStroke       = @NO;
    _timeProgressBar.showBackground   = @NO;
    _timeProgressBar.progressInset    = @3;
    _timeProgressBar.outerStrokeWidth = @2;
    _timeProgressBar.animate          = @YES;
    _timeProgressBar.type = LDProgressSolid;
    [self.view addSubview:_timeProgressBar];
        
    //初始化SongTitle
    _songTitleLabel = [[MarqueeLabel alloc] init];
    _songTitleLabel.textColor = [UIColor standerTextColor];
    _songTitleLabel.scrollDuration = kScrollDuration;
    _songTitleLabel.fadeLength = kFadeLength;
    _songTitleLabel.animationCurve = UIViewAnimationCurveEaseIn;
    _songTitleLabel.marqueeType = MLContinuous;
    _songTitleLabel.font = [UIFont systemFontOfSize:kBigLabelFont];
    _songTitleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_songTitleLabel];
    
    
    //初始化SongArtist
    _songArtistLabel = [[MarqueeLabel alloc] init];
    _songArtistLabel.textColor = [UIColor standerGreyTextColor];
    _songArtistLabel.scrollDuration = kScrollDuration;
    _songArtistLabel.fadeLength = kFadeLength;
    _songArtistLabel.animationCurve = UIViewAnimationCurveEaseIn;
    _songArtistLabel.marqueeType = MLContinuous;
    _songArtistLabel.font = [UIFont systemFontOfSize:kLabelFont];
    _songArtistLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_songArtistLabel];
    
    //初始化音乐操作按键
    NSArray *buttonImageNameLists = @[@"pause-musicPlayer",
                                      @"heart1-musicPlayer",
                                      @"next-musicPlayer"];
    songOperationButtonList = [[NSMutableArray alloc] initWithCapacity:buttonImageNameLists.count];
    
    [buttonImageNameLists enumerateObjectsUsingBlock:^(NSString *buttonImageName, NSUInteger idx, BOOL *stop)
     {
         UIButton *songOperationButton = [UIButton buttonWithType:UIButtonTypeCustom];
         songOperationButton.tag = (idx+1);
         [songOperationButton setBackgroundImage:[UIImage imageNamed:buttonImageName] forState:UIControlStateNormal];
         [songOperationButton addTarget:self action:@selector(onButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
         [self.view addSubview:songOperationButton];
         [songOperationButtonList addObject:songOperationButton];
     }];
}

- (void)setAutoLayout
{
    
    //PlayerImage
    [_musicPlayerImage mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.top.equalTo(self.view.mas_top).offset(kPlayerImageTop);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.height.and.width.equalTo(self.view.mas_width).with.multipliedBy(kPlayerImageSideLengthFactor);
    }];
    
    //playerImageBlock
    [_musicPlayerImageBlock mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.top.equalTo(self.view.mas_top).offset(kPlayerImageTop);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.height.and.width.equalTo(self.view.mas_width).with.multipliedBy(kPlayerImageSideLengthFactor);
    }];
    
    //TimeLabel
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.top.equalTo(_musicPlayerImage.mas_bottom).with.multipliedBy(kTimeLabelTopFactor);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.width.equalTo(self.view.mas_width).with.multipliedBy(kLabelWidthFactor);
        make.height.equalTo(self.view.mas_height).with.multipliedBy(kLabelHeightFactor);
    }];
    
    //TimeProgressBar
    [_timeProgressBar mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.top.equalTo(_timeLabel.mas_bottom).with.multipliedBy(kTimeProgressBarTopFactor);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.width.equalTo(self.view.mas_width).with.multipliedBy(kLabelWidthFactor);
        make.height.mas_equalTo(kProgressBarHeight);
    }];
    
    //SongTitle
    [_songTitleLabel mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.top.equalTo(_timeProgressBar.mas_bottom).with.multipliedBy(kSongTitleTopFactor);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.width.equalTo(self.view.mas_width).with.multipliedBy(kLabelWidthFactor);
        make.height.equalTo(self.view.mas_height).with.multipliedBy(kLabelHeightFactor);
    }];
    
    //SongArtist
    [_songArtistLabel mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.top.equalTo(_songTitleLabel.mas_bottom).with.multipliedBy(kSongArtistTopFactor);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.width.equalTo(self.view.mas_width).with.multipliedBy(kLabelWidthFactor);
        make.height.equalTo(self.view.mas_height).with.multipliedBy(kLabelHeightFactor);
    }];
    
    //初始化songOperationButton
    
    [songOperationButtonList enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop)
     {
         [button mas_makeConstraints:^(MASConstraintMaker *make)
          {
              make.top.equalTo(_songArtistLabel.mas_bottom).multipliedBy(kButtonTopFactor);
              make.centerX.equalTo(self.view.mas_centerX).with.multipliedBy([self getButtonXFactor:(idx+1)]);
              make.width.and.height.equalTo(self.view.mas_width).with.multipliedBy(kButtonHeightWidthFactor);
          }];

     }];

}

- (void)setMusicPlayerInfo
{
    [funServer fmSongOperationWithType:SongOperationTypeNext];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(startPlayer)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshMusicPlayer)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:nil];
    
    _musicPlayerImage.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pauseClicked)];
    [_musicPlayerImage addGestureRecognizer:singleTap];
    
}



- (void)startPlayer
{
    [funServer fmSongOperationWithType:SongOperationTypePlay];
}

- (void)refreshMusicPlayer
{
    isPlaying = YES;
    if (![self isFirstResponder])
    {
        //远程控制
        //************************************
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        //************************************
        [self becomeFirstResponder];
    }
    
    //重置旋转图片角度
    _musicPlayerImage.image = nil;
    NSURL *imageURL = [NSURL URLWithString:currentPlayerInfo.currentSong.songPictureUrl];
    [_musicPlayerImage sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"albumBlock-musicPlayer"]];
    
    //初始化各UI界面
    self.navigationItem.title = [NSString stringWithFormat:@"♪%@♪",currentPlayerInfo.currentChannel.channelName];
    _songArtistLabel.text = [NSString stringWithFormat:@"——  %@  ——",currentPlayerInfo.currentSong.songArtist];
    _songTitleLabel.text = [NSString stringWithFormat:@"%@",currentPlayerInfo.currentSong.songTitle];
    
    //初始化TimeLabel时间
    totalTimeSeconds = [currentPlayerInfo.currentSong.songTimeLong integerValue] %60;
    totalTimeMinutes = [currentPlayerInfo.currentSong.songTimeLong integerValue] /60;
    if (totalTimeSeconds < 10)
    {
        totalTimeString = [NSMutableString stringWithFormat:@"%ld:0%ld",(long)totalTimeMinutes,(long)totalTimeSeconds];
    }
    else
    {
        totalTimeString = [NSMutableString stringWithFormat:@"%ld:%ld",(long)totalTimeMinutes,(long)totalTimeSeconds];
    }
    
    //初始化likeButton的图像
    if (![currentPlayerInfo.currentSong.songIsLike intValue])
    {
        [songOperationButtonList[1] setBackgroundImage:[UIImage imageNamed:@"heart1-musicPlayer"] forState:UIControlStateNormal];
    }
    else
    {
        [songOperationButtonList[1] setBackgroundImage: [UIImage imageNamed:@"heart2-musicPlayer"] forState:UIControlStateNormal];
    }
    
    //初始化PauseButton的表示
    _musicPlayerImage.alpha = kPlayingAlpha;
    _musicPlayerImageBlock.image = [UIImage imageNamed:@"albumBlock-musicPlayer"];
    [songOperationButtonList[0] setBackgroundImage:[UIImage imageNamed:@"pause-musicPlayer"] forState:UIControlStateNormal];
    
    //初始化timeProgressBar
    [timer setFireDate:[NSDate date]];
    [self congfigVideoPlayerInfo];
    
    
}

- (void)congfigVideoPlayerInfo
{
    if (NSClassFromString(@"MPNowPlayingInfoCenter"))
    {
        if (currentPlayerInfo.currentSong.songTitle != nil)
        {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:currentPlayerInfo.currentSong.songTitle forKey:MPMediaItemPropertyTitle];
            [dict setObject:currentPlayerInfo.currentSong.songArtist forKey:MPMediaItemPropertyArtist];
            UIImage *playerViewImage = _musicPlayerImage.image;
            if (playerViewImage !=nil)
            {
                [dict setObject:[[MPMediaItemArtwork alloc] initWithImage:playerViewImage] forKey:MPMediaItemPropertyArtwork];
            }
            [dict setObject:[NSNumber numberWithFloat:[currentPlayerInfo.currentSong.songTimeLong floatValue]] forKey:MPMediaItemPropertyPlaybackDuration];
            [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
        }
    }
}



- (void)onButtonClicked:(UIButton *)sender
{
    switch (sender.tag)
    {
        case songButtonTypePause:
            [self pauseClicked];
            break;
        case songButtonTypeLike:
            [self likeClicked];
            break;
        case songButtonTypSkip:
            [self skipClicked];
            break;
    }
}


- (void)pauseClicked
{
    if (isPlaying)
    {
        isPlaying = NO;
        _musicPlayerImage.alpha = kNOPlayingAlpha;
        _musicPlayerImageBlock.image = [UIImage imageNamed:@"albumBlock2-musicPlayer"];
        [songOperationButtonList[0] setBackgroundImage:[UIImage imageNamed:@"play-musicPlayer"] forState:UIControlStateNormal];
        [musicPlayer pause];
        //关闭计时器
        [timer setFireDate:[NSDate distantFuture]];
    }
    else
    {
        isPlaying = YES;
        _musicPlayerImage.alpha = kPlayingAlpha;
        _musicPlayerImageBlock.image = [UIImage imageNamed:@"albumBlock-musicPlayer"];
        [songOperationButtonList[0] setBackgroundImage:[UIImage imageNamed:@"pause-musicPlayer"] forState:UIControlStateNormal];
        [musicPlayer play];
        //开启计时器
        [timer setFireDate:[NSDate date]];
    }
}

- (void)likeClicked
{
    if (![currentPlayerInfo.currentSong.songIsLike intValue])
    {
        currentPlayerInfo.currentSong.songIsLike = @"1";
        [songOperationButtonList[1] setBackgroundImage:[UIImage imageNamed:@"heart2-musicPlayer"] forState:UIControlStateNormal];
        [funServer fmSongOperationWithType:SongOperationTypeLike];
    }
    else
    {
        currentPlayerInfo.currentSong.songIsLike = @"0";
        [songOperationButtonList[1] setBackgroundImage:[UIImage imageNamed:@"heart1-musicPlayer"] forState:UIControlStateNormal];
    }
}



- (void)skipClicked
{
    [timer setFireDate:[NSDate distantFuture]];
    [musicPlayer pause];
    if (!isPlaying)
    {
        _musicPlayerImage.alpha = kPlayingAlpha;
        _musicPlayerImageBlock.image = [UIImage imageNamed:@"albumBlock-musicPlayer"];
    }
    [funServer fmSongOperationWithType:SongOperationTypeSkip];
}


- (CGFloat)getButtonXFactor:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 1:
            return kPauseButtonXFactor;
            break;
        case 2:
            return kHeartButtonXFactor;
            break;
        case 3:
            return kNextButtonXFactor;
            break;
        default:
            return 1;
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
