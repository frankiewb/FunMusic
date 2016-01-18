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
#import "MenuInfo.h"
#import "AFHTTPSessionManager+Util.h"
#import "Utils.h"
#import "Config.h"
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

#pragma SongOperation Function

- (MPMoviePlayerController *)fmGetCurrentMusicPlayer
{
    return appDelegate.MusicPlayer;
}

- (PlayerInfo *)fmGetCurrentPlayerInfo
{
    return appDelegate.currentPlayerInfo;
}


- (void)fmSongOperationWithType:(SongOperationType)operationType
{
    NSString *operationString = [self fmGetOperationString:operationType];
    NSString *playListURL = [self fmGetPlayeListURLWithType:operationString];
    
    
    fmManager = [self fmGennerateFMManagerWithType:managerTypeJOSN];
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


- (NSString *)fmGetPlayeListURLWithType:(NSString *)operationString
{
    NSString *currentSongID = appDelegate.currentPlayerInfo.currentSong.songId;
    NSString *currentChannelID = appDelegate.currentPlayerInfo.currentChannel.channelID;
    NSTimeInterval currentPlaybackTime = appDelegate.MusicPlayer.currentPlaybackTime;
    
    NSString *playListURL = [NSString stringWithFormat:PLAYERURLFORMATSTRING, operationString, currentSongID, currentPlaybackTime,currentChannelID];
    
    return playListURL;
}

- (NSString *)fmGetOperationString:(SongOperationType)operationType
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





#pragma ChannelOperation Function
//由于豆瓣ChannelID都是固定的，这里暂时采用读取本地JSON文档的方式获取Channel所有数据
//为该APP将来的扩展留下接口

- (ChannelGroup *)fmGetChannelWithTypeInLocal:(NSInteger)channelType
{
    [self fmGetAllChannelInfos];
    ChannelGroup *channelGroup = nil;
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
    
    return appDelegate.currentChannelGroup;
}



- (void)fmGetAllChannelInfos
{
    if (!appDelegate.allChannelGroup)
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
        
        appDelegate.allChannelGroup = allChannelArray;
    }
}



- (ChannelInfo *)fmSearchChannelInfoWithName:(NSString *)channelName
{
    [self fmGetAllChannelInfos];
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


- (void)fmDeleteMySharedChannelListWithChannelIndex:(NSInteger)channelIndex
{
    [appDelegate.currentUserInfo.userSharedChannelLists removeObjectAtIndex:channelIndex];
    [Config saveUserSharedChannelList:appDelegate.currentUserInfo.userSharedChannelLists];
}

- (void)fmUpdateMySharedChannelListWithChannelName:(NSString *)channelName
{
    if (![self fmIsChannelInMySharedChannelList:channelName])
    {
        [self fmGetAllChannelInfos];
        for (ChannelGroup *singleChannelGroup in appDelegate.allChannelGroup)
        {
            for (ChannelInfo *singleChannelInfo in singleChannelGroup.channelArray)
            {
                if ([singleChannelInfo.channelName isEqualToString:channelName])
                {
                    [appDelegate.currentUserInfo.userSharedChannelLists insertObject:singleChannelInfo atIndex:0];
                    [Config saveUserSharedChannelList:appDelegate.currentUserInfo.userSharedChannelLists];
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

- (void)fmUpdateCurrentChannelInfo:(ChannelInfo *)newCurrentChannelInfo
{
    ChannelInfo *updateChannelInfo = [appDelegate.currentPlayerInfo.currentChannel initWithChannelInfo:newCurrentChannelInfo];
    [Config saveCurrentChannelInfo:updateChannelInfo];
}

- (ChannelInfo *)fmGetCurrentChannel
{
    return appDelegate.currentPlayerInfo.currentChannel;
}


#pragma TweetFunction


- (void)fmGetTweetInfoInLocal
{
    if ([appDelegate.tweetInfoGroup count] == 0)
    {
        NSString *tweetGroupName = @"localTweetData";
        NSDictionary *tweetGroupDic = [Utils gennerateDicitonaryWithPlistFile:tweetGroupName];
        [self fmGetTweetGroupWithDictionary:tweetGroupDic TweetInfoGroup:appDelegate.tweetInfoGroup];
        [Config saveTweetInfoGroup:appDelegate.tweetInfoGroup];
    }
    
}

- (NSMutableArray *)fmGetTweetInfoWithType:(NSInteger)type
{
    if (type == 1)
    {
        [self fmGetTweetInfoInLocal];
        return appDelegate.tweetInfoGroup;
    }
    else if (type == 2)
    {
        return appDelegate.currentUserInfo.userTweeterList;
    }
    else
    {
        NSAssert(FALSE, @"Invalid TweetType");
        return nil;
    }
}



- (void)fmGetTweetGroupWithDictionary:(NSDictionary *)dic TweetInfoGroup:(NSMutableArray *)tweetInfoGroup
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

- (void)fmDeleteTweetInfoWithTweetID:(NSString *)tweetID
{
    NSInteger localTweetIndex = [self fmSearchTweetInfoWithID:tweetID isMyTweetGroup:NO];
    [appDelegate.tweetInfoGroup removeObjectAtIndex:localTweetIndex];
    NSInteger myTweetIndex = [self fmSearchTweetInfoWithID:tweetID isMyTweetGroup:YES];
    [appDelegate.currentUserInfo.userTweeterList removeObjectAtIndex:myTweetIndex];
    [Config saveUserTweetList:appDelegate.currentUserInfo.userTweeterList];
    [Config saveTweetInfoGroup:appDelegate.tweetInfoGroup];
}


- (void)fmSharedTweeterWithTweetInfo:(TweetInfo *)tweetInfo
{
    [self fmGetTweetInfoInLocal];
    NSMutableArray *tweetInfoGroup = appDelegate.tweetInfoGroup;
    NSMutableArray *userTweetInfoGroup = appDelegate.currentUserInfo.userTweeterList;
    NSAssert(tweetInfoGroup, @"tweetInfoGroup invalid !!");
    [tweetInfoGroup insertObject:tweetInfo atIndex:0];
    TweetInfo *userTweetInfo = [[TweetInfo alloc] initWithTweetInfo:tweetInfo];
    [userTweetInfoGroup insertObject:userTweetInfo atIndex:0];
    [Config saveUserTweetList:userTweetInfoGroup];
    [Config saveTweetInfoGroup:tweetInfoGroup];
}


- (void)fmUpdateTweetLikeCountWithTweetID:(NSString *)tweetID like:(BOOL)isLike isMineTweet:(BOOL)isMine
{
    NSInteger index = [self fmSearchTweetInfoWithID:tweetID isMyTweetGroup:NO];
    TweetInfo *updatedTweetInfo = appDelegate.tweetInfoGroup[index];
    isLike ? (updatedTweetInfo.likeCount++) : (updatedTweetInfo.likeCount--);
    isLike ? (updatedTweetInfo.isLike = @"2") : (updatedTweetInfo.isLike = @"1");
    [Config saveTweetInfoGroup:appDelegate.tweetInfoGroup];
    if (isMine)
    {
        NSInteger mineIndex = [self fmSearchTweetInfoWithID:tweetID isMyTweetGroup:YES];
        TweetInfo *mineUpdateTweetInfo = appDelegate.currentUserInfo.userTweeterList[mineIndex];
        isLike ? (mineUpdateTweetInfo.likeCount++) : (mineUpdateTweetInfo.likeCount--);
        isLike ? (mineUpdateTweetInfo.isLike = @"2") : (mineUpdateTweetInfo.isLike = @"1");
        [Config saveUserTweetList:appDelegate.currentUserInfo.userTweeterList];
    }
    
}

- (NSInteger)fmSearchTweetInfoWithID:(NSString *)tweetID isMyTweetGroup:(BOOL)isMine
{
    NSMutableArray *tweetInfoGroup = nil;
    if (isMine)
    {
        tweetInfoGroup = appDelegate.currentUserInfo.userTweeterList;
    }
    else
    {
        [self fmGetTweetInfoInLocal];
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

- (UserInfo *)fmGetCurrentUserInfo
{
    return appDelegate.currentUserInfo;
}


- (BOOL)fmLoginInLocalWithLoginInfo:(LogInfo *)logInfo
{
    NSDictionary *logDic = [Utils gennerateDicitonaryWithPlistFile:@"loginData"];
    if ([logInfo isLoginSuccessfull:logDic])
    {
        NSDictionary *userDic = [Utils gennerateDicitonaryWithPlistFile:@"userData"];
        currentUserInfo = [appDelegate.currentUserInfo initWithDictionary:userDic];
        [Config saveUserInfo:currentUserInfo];
        return TRUE;
    }
    return FALSE;
}

- (BOOL)fmIsLogin
{
    BOOL islogin;
    appDelegate.currentUserInfo.isLogin ? (islogin = TRUE) : (islogin = FALSE);
    return islogin;
}

- (void)fmLogOut
{
    appDelegate.currentUserInfo.isLogin = FALSE;
    [Config saveUserInfo:appDelegate.currentUserInfo];
}



#pragma sideMenuInfo

- (NSMutableArray *)fmGetSideMenuInfo
{
    NSArray *menuNameList = @[@"频道",@"音乐圈",@"清除缓存",@"夜间模式",@"注销登录"];
    NSArray *menuImageNameList = @[@"频道",@"音乐圈",@"缓存",@"夜间模式",@"注销"];
    return [self fmGetMenuInfoListWithNameList:menuNameList imageList:menuImageNameList];
}

- (NSMutableArray *)fmGetMineMenuInfo
{
    NSArray *menuNameList = @[@"我的频道",@"我的音乐圈",@"清除缓存",@"夜间模式"];
    NSArray *menuImageNameList = @[@"频道",@"音乐圈",@"缓存",@"夜间模式"];
    return [self fmGetMenuInfoListWithNameList:menuNameList imageList:menuImageNameList];
}


- (NSMutableArray *)fmGetMenuInfoListWithNameList:(NSArray *)menuNameList imageList:(NSArray *)menuImageList
{
    NSMutableArray *menuInfoList = [[NSMutableArray alloc] init];
    [menuNameList enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL *stop)
     {
         MenuInfo *menuInfo = [[MenuInfo alloc] init];
         menuInfo.menuName = name;
         menuInfo.menuImageName = menuImageList[idx];
         [menuInfoList addObject:menuInfo];
     }];
    
    return menuInfoList;
}



#pragma sharedChannelList

- (NSMutableArray *)fmGetMySharedChannelList
{
    return appDelegate.currentUserInfo.userSharedChannelLists;
}


#pragma searchChannelList

- (NSMutableArray *)fmGetSearchChannelList
{
    [self fmGetAllChannelInfos];
    return appDelegate.allChannelGroup;
}

#pragma DawnAndNightMode

- (void)fmSetNightMode:(BOOL)isNightMode
{
    appDelegate.isNightMode = isNightMode;
    [Config saveDawnAndNightMode:appDelegate.isNightMode];
}

- (BOOL)fmGetNightMode
{
    return appDelegate.isNightMode;
}


#pragma clearAllData

- (void)fmClearAllData
{
    [Config clearAllDataInUserDefaults];
}





#pragma Common Fuction

- (AFHTTPSessionManager *)fmGennerateFMManagerWithType:(managerType)type
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
