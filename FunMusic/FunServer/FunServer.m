//
//  FunServer.m
//  FunMusic
//
//  Created by frankie on 15/12/25.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import "FunServer.h"
#import "AppDelegate.h"
#import "ChannelInfo.h"
#import "SongInfo.h"
#import "PlayerInfo.h"
#import "AFHTTPSessionManager+Util.h"
#import "Utils.h"
#import <AFNetworking.h>



#define PLAYERURLFORMATSTRING     @"http://douban.fm/j/mine/playlist?type=%@&sid=%@&pt=%f&channel=%@&from=mainsite"
#define USERIMAGEURL              @"http://img3.douban.com/icon/ul%@-1.jpg"
#define LOGINURLSTRING            @"http://douban.fm/j/login"
#define LOGOUTURLSTRING           @"http://douban.fm/partner/logout"
#define CAPTCHAIDURLSTRING        @"http://douban.fm/j/new_captcha"
#define CAPTCHAIMGURLFORMATSTRING @"http://douban.fm/misc/captcha?size=m&id=%@"
#define TOTALCHINNELSTRING        @"http://www.douban.com/j/app/radio/channels"



typedef NS_ENUM(NSUInteger, managerType)
{
    managerTypeJOSN = 1,
    managerTypeHTTP,
};


@interface FunServer ()
{
    AppDelegate *appDelegate;
    AFHTTPSessionManager *fmManager;
    managerType fmManagerType;
}


@end

@implementation FunServer


- (id)init
{
    self = [super init];
    if (self)
    {
        appDelegate = [[UIApplication sharedApplication] delegate];
    }
    
    return self;
}



#pragma ChannelOperation Function
//由于豆瓣ChannelID都是固定的，这里暂时采用读取本地JSON文档的方式获取Channel所有数据
//为该APP将来的扩展留下接口

- (void)fmGetChannelWithTypeInLocal:(ChannelType)channelType
{
    NSDictionary *channelGroupDic;
    switch (channelType)
    {
        case ChannelTypeFeeling:
            channelGroupDic = [Utils gennerateDicitonaryWithPlistFile:@"channelFeeling"];
            break;
        case ChannelTypeLanguage:
            channelGroupDic = [Utils gennerateDicitonaryWithPlistFile:@"channelLanguage"];
            break;
        case ChannelTypeRecomand:
            channelGroupDic = [Utils gennerateDicitonaryWithPlistFile:@"channelRecomand"];
            break;
        case ChannelTypeSongStyle:
            channelGroupDic = [Utils gennerateDicitonaryWithPlistFile:@"channelSongStyle"];
            break;
    }
    appDelegate.currentChannelGroup = [[ChannelGroup alloc] initWithChannelType:channelType channelGroupDictionary:channelGroupDic];
}



- (void)fmGetChannelWithType:(ChannelType)channelType
{
    NSString *channelURL = [self generateChannelURLWithType:channelType];
    fmManager = [self gennerateFMManagerWithType:managerTypeJOSN];
    [fmManager GET:channelURL
        parameters:nil
          progress:nil
           success:^(NSURLSessionDataTask *task, NSDictionary *channelsDictionary)
     {
         //Do Anything For future
     }
           failure:^(NSURLSessionDataTask *task, NSError *error)
     {
         //Do Anything For future
     }];
    
    
}


//架构搭好，暂时没有得到各分组channel连接，只能全部都用一个连接获取全部channel，然后人工分组了.
//正常来说，应该每个分组一个URL，所以先这样架构
- (NSString *)generateChannelURLWithType:(ChannelType)channelType
{
    NSString *channelURL;
    switch (channelType)
    {
        case ChannelTypeFeeling:
            return channelURL = TOTALCHINNELSTRING;
            break;
        case ChannelTypeLanguage:
            return channelURL = TOTALCHINNELSTRING;
            break;
        case ChannelTypeRecomand:
            return channelURL = TOTALCHINNELSTRING;
            break;
        case ChannelTypeSongStyle:
            return channelURL = TOTALCHINNELSTRING;
            break;
    }
    
    return channelURL;
}




#pragma SongOperation Function


- (void)fmSongOperationWithType:(SongOperationType)operationType
{
    NSString *operationString = [self generateOperationString:operationType];
    NSString *playListURL = [self genneratePlayeListURLWithType:operationString];
    
    
    fmManager = [self gennerateFMManagerWithType:managerTypeJOSN];
    [fmManager GET:playListURL
       parameters:nil
         progress:nil
          success:^(NSURLSessionDataTask *task, NSDictionary *songDictionary)
     {
         for (NSDictionary *songDic in songDictionary[@"song"])
         {
             //subtype = T 为广告标示位，如果为T，则不加入播放列表（去广告）
             if ([songDic[@"subtype"]isEqualToString:@"T"])
             {
                 continue;
             }
             if ([operationString isEqualToString: @"r"])
             {
                 NSLog(@"喜欢！");
             }
             
             NSLog(@"当前歌曲 : %@", appDelegate.currentPlayerInfo.currentSong.songTitle);
             SongInfo * currentSongInfo = [appDelegate.currentPlayerInfo.currentSong initWithDictionary:songDic];
             [appDelegate.MusicPlayer setContentURL:[NSURL URLWithString:appDelegate.currentPlayerInfo.currentSong.songUrl]];
             [appDelegate.MusicPlayer play];
             NSLog(@"即将播放歌曲: %@", currentSongInfo.songTitle);
         }
     }
          failure:^(NSURLSessionDataTask *task, NSError *error)
     {
         _getSongListFail(error);
     }];
}


- (NSString *)genneratePlayeListURLWithType:(NSString *)operationString
{
    NSString *currentSongID = appDelegate.currentPlayerInfo.currentSong.songId;
    NSString *currentChannelID = appDelegate.currentPlayerInfo.currentChannel.channelID;
    NSTimeInterval currentPlaybackTime = appDelegate.MusicPlayer.currentPlaybackTime;
    
    NSString *playListURL = [NSString stringWithFormat:PLAYERURLFORMATSTRING, operationString, currentSongID, currentPlaybackTime,currentChannelID];
    
    return playListURL;
}

- (NSString *)generateOperationString:(SongOperationType)operationType
{
    NSString *operationString;
    switch (operationType)
    {
        case SongOperationTypeNext:
            operationString = @"n";
            break;
        case SongOperationTypeEnd:
            operationString = @"e";
            break;
        case SongOperationTypeUnlike:
            operationString = @"u";
            break;
        case SongOperationTypeLike:
            operationString = @"r";
            break;
        case SongOperationTypeDelete:
            operationString = @"b";
            break;
        case SongOperationTypeSkip:
            operationString = @"s";
            break;
        case SongOperationTypePlay:
            operationString = @"p";
    }
    
    return operationString;
}



#pragma Common Fuction

- (AFHTTPSessionManager *)gennerateFMManagerWithType:(managerType)type
{
    AFHTTPSessionManager *manager;
    switch (type)
    {
        case managerTypeJOSN:
            if (!fmManager || fmManagerType != managerTypeJOSN)
            {
                manager = [AFHTTPSessionManager fmJSONManager];
                fmManagerType = managerTypeJOSN;
                return manager;
            }
            break;
        case managerTypeHTTP:
            if (!fmManager || fmManagerType != managerTypeHTTP)
            {
                manager = [AFHTTPSessionManager fmHTTPManager];
                fmManagerType = managerTypeHTTP;
                return manager;
            }
            break;
    }
    return fmManager;
}







@end
