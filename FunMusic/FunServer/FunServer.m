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
#import "ChannelGroup.h"
#import "SongInfo.h"
#import "PlayerInfo.h"
#import "TweetInfo.h"
#import "UserInfo.h"
#import "LogInfo.h"
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
    UserInfo *currentUserInfo;
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
    if (!appDelegate.allChannelGroup)
    {
        appDelegate.allChannelGroup = [self fmGetAllChannelInfos];
    }
    ChannelGroup *channelGroup;
    switch (channelType)
    {
        case ChannelTypeFeeling:
            channelGroup = appDelegate.allChannelGroup[0];
            break;
        case ChannelTypeLanguage:
            channelGroup = appDelegate.allChannelGroup[1];
            break;
        case ChannelTypeRecomand:
            channelGroup = appDelegate.allChannelGroup[2];
            break;
        case ChannelTypeSongStyle:
            channelGroup = appDelegate.allChannelGroup[3];
            break;
    }
    appDelegate.currentChannelGroup = channelGroup;
}



- (NSMutableArray *)fmGetAllChannelInfos
{
    NSArray *channelsName = @[@"channelFeeling",
                              @"channelLanguage",
                              @"channelRecomand",
                              @"channelSongStyle"];
    
    NSMutableArray *allChannelArray = [[NSMutableArray alloc] init];
    for (NSString *singleChannelName in channelsName)
    {
        NSDictionary *channelGroupDic = [Utils gennerateDicitonaryWithPlistFile:singleChannelName];
        ChannelType type = [Utils gennerateChannelGroupTypeWithChannelName:singleChannelName];
        ChannelGroup *channelGroup = [[ChannelGroup alloc] initWithChannelType:type channelName:singleChannelName channelGroupDictionary:channelGroupDic];
        [allChannelArray addObject:channelGroup];
    }
    
    return allChannelArray;
}



- (ChannelInfo *)searchChannelInfoWithName:(NSString *)channelName
{
    if (!appDelegate.allChannelGroup)
    {
        appDelegate.allChannelGroup = [self fmGetAllChannelInfos];
    }
    NSMutableArray *allChannelInfo = appDelegate.allChannelGroup;
    
    
    for (ChannelGroup *singleChannelGroup in allChannelInfo)
    {
        for (ChannelInfo *singleChannelInfo in singleChannelGroup.channelArray)
        {
            if ([channelName isEqualToString: singleChannelInfo.channelName])
            {
                return singleChannelInfo;
            }
        }
    }
    NSAssert(FALSE, @"ChannelData fault ! There is unknown ChannelInfoName in YINYUEQUAN");
    return Nil;
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
                 return ;
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
         _getSongListFail();
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


#pragma TweetFunction


- (void)fmGetTweetInfoInLocal
{
    
    NSString *tweetGroupName = @"localTweetData";
    NSDictionary *tweetGroupDic = [Utils gennerateDicitonaryWithPlistFile:tweetGroupName];
    [self gennrateTweetGroupWithDictionary:tweetGroupDic TweetInfoGroup:appDelegate.tweetInfoGroup];
    
}

- (NSMutableArray *)fmGetTweetInfoWithUserID:(NSString *)userID
{
    NSMutableArray *userTweetGroup = [[NSMutableArray alloc] init];
    NSDictionary *tweetGroupDic = [Utils gennerateDicitonaryWithPlistFile:userID];
    [self gennrateTweetGroupWithDictionary:tweetGroupDic TweetInfoGroup:userTweetGroup];
    return userTweetGroup;
}


- (void)gennrateTweetGroupWithDictionary:(NSDictionary *)dic TweetInfoGroup:(NSMutableArray *)tweetInfoGroup
{
    NSAssert(dic, @"Dictionary has not been inited !");
    NSString *singleTweeterKey;
    NSDictionary *singleTweeterValue;
    for (singleTweeterKey in dic)
    {
        singleTweeterValue = dic[singleTweeterKey];
        TweetInfo *tweetInfo = [[TweetInfo alloc] initWithTweetDic:singleTweeterValue];
        [tweetInfoGroup addObject:tweetInfo];
    }
}


- (void)fmSharedTweeterWithTweetInfo:(TweetInfo *)tweetInfo
{
    NSMutableArray *tweetInfoGroup = appDelegate.tweetInfoGroup;
    NSMutableArray *userTweetInfoGroup = appDelegate.currentUserInfo.userTweeterList;
    NSAssert(tweetInfoGroup, @"tweetInfoGroup invalid !!");
    [tweetInfoGroup insertObject:tweetInfo atIndex:0];
    [userTweetInfoGroup insertObject:tweetInfo atIndex:0];
    //向服务器更新Tweet信息
    //TO DO...
}


- (void)fmUpdateTweetLikeCountWithTweetID:(NSString *)tweetID like:(BOOL)isLike
{
    NSInteger index = [self searchTweetInfoWithID:tweetID isMyTweetGroup:NO];
    TweetInfo *updatedTweetInfo = appDelegate.tweetInfoGroup[index];
    isLike ? (updatedTweetInfo.likeCount++) : (updatedTweetInfo.likeCount--);
    isLike ? (updatedTweetInfo.isLike = @"2") : (updatedTweetInfo.isLike = @"1");
    //针对服务器应该有一个post操作，因为没有现成服务器，暂且空余, 也可以统一定时更新
    //TO DO...
}

- (void)fmUpdateMySharedChannelListWithChannelName:(NSString *)channelName
{
    if (![self fmIsChannelInMySharedChannelList:channelName])
    {
        if (!appDelegate.allChannelGroup)
        {
            appDelegate.allChannelGroup = [self fmGetAllChannelInfos];
        }
        for (ChannelGroup *singleChannelGroup in appDelegate.allChannelGroup)
        {
            for (ChannelInfo *singleChannelInfo in singleChannelGroup.channelArray)
            {
                if ([singleChannelInfo.channelName isEqualToString:channelName])
                {
                    [appDelegate.currentUserInfo.userSharedChannelLists insertObject:singleChannelInfo atIndex:0];
                }
            }
            
        }

    }
}

- (BOOL)fmIsChannelInMySharedChannelList:(NSString *)channelName
{
    for (ChannelInfo *singleChannelInfo in appDelegate.currentUserInfo.userSharedChannelLists)
    {
        if ([singleChannelInfo.channelName isEqualToString:channelName])
        {
            return TRUE;
        }
    }
    
    return FALSE;
}



- (NSInteger)searchTweetInfoWithID:(NSString *)tweetID isMyTweetGroup:(BOOL)isMine
{
    NSMutableArray *tweetInfoGroup = nil;
    if (isMine)
    {
        tweetInfoGroup = appDelegate.currentUserInfo.userTweeterList;
    }
    else
    {
        if (!appDelegate.tweetInfoGroup)
        {
            [self fmGetTweetInfoInLocal];
        }
        tweetInfoGroup = appDelegate.tweetInfoGroup;
    }
    NSInteger idx = 0;
    for (TweetInfo *singleTweetInfo in tweetInfoGroup)
    {
        if ([singleTweetInfo.tweetID isEqualToString: tweetID])
        {
            return idx;
        }
        else
        {
            idx++;
        }
    }
    NSAssert(FALSE, @"TweetData Error :Can not find the right  TweetInfo");
    return -1;
}



#pragma LoginOperation

- (BOOL)fmLoginInLocalWithLoginInfo:(LogInfo *)logInfo
{
    NSDictionary *logDic = [Utils gennerateDicitonaryWithPlistFile:@"loginData"];
    if ([logInfo isLoginSuccessfull:logDic])
    {
        NSDictionary *userDic = [Utils gennerateDicitonaryWithPlistFile:@"userData"];
        currentUserInfo = [appDelegate.currentUserInfo initWithDictionary:userDic];
        return TRUE;
    }
    return FALSE;
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
