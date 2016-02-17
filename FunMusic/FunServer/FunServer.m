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

typedef NS_ENUM(NSUInteger, managerType)
{
    managerTypeJOSN = 1,
    managerTypeHTTP,
};


@interface FunServer ()
{
    AppDelegate *_appDelegate;
    AFHTTPSessionManager *_fmManager;
    managerType _fmManagerType;
}


@end

@implementation FunServer


- (id)init
{
    self = [super init];
    if (self)
    {
        _appDelegate = [[UIApplication sharedApplication] delegate];
    }
    
    return self;
}

#pragma mark SongOperation Function

- (MPMoviePlayerController *)fmGetCurrentMusicPlayer
{
    return _appDelegate.MusicPlayer;
}

- (PlayerInfo *)fmGetCurrentPlayerInfo
{
    return _appDelegate.currentPlayerInfo;
}


- (void)fmSongOperationWithType:(SongOperationType)operationType
{
    NSString *operationString = [self fmGetOperationString:operationType];
    NSString *playListURL = [self fmGetPlayeListURLWithType:operationString];
    
    
    _fmManager = [self fmGennerateFMManagerWithType:managerTypeJOSN];
    [_fmManager GET:playListURL
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
             
             NSLog(@"当前歌曲 : %@", _appDelegate.currentPlayerInfo.currentSong.songTitle);
             SongInfo * currentSongInfo = [_appDelegate.currentPlayerInfo.currentSong initWithDictionary:songDic];
             [_appDelegate.MusicPlayer setContentURL:[NSURL URLWithString:_appDelegate.currentPlayerInfo.currentSong.songUrl]];
             [_appDelegate.MusicPlayer play];
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
    NSString *currentSongID = _appDelegate.currentPlayerInfo.currentSong.songId;
    NSString *currentChannelID = _appDelegate.currentPlayerInfo.currentChannel.channelID;
    NSTimeInterval currentPlaybackTime = _appDelegate.MusicPlayer.currentPlaybackTime;
    
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





#pragma mark ChannelOperation Function
//由于豆瓣ChannelID都是固定的，这里暂时采用读取本地JSON文档的方式获取Channel所有数据

- (ChannelGroup *)fmGetChannelWithTypeInLocal:(NSInteger)channelType
{
    [self fmGetAllChannelInfos];
    ChannelGroup *channelGroup = nil;
    switch (channelType)
    {
        case ChannelTypeFeeling:
            channelGroup = _appDelegate.allChannelGroup[0];
            break;
        case ChannelTypeLanguage:
            channelGroup = _appDelegate.allChannelGroup[1];
            break;
        case ChannelTypeRecomand:
            channelGroup = _appDelegate.allChannelGroup[2];
            break;
        case ChannelTypeSongStyle:
            channelGroup = _appDelegate.allChannelGroup[3];
            break;
    }
    _appDelegate.currentChannelGroup = channelGroup;
    
    return _appDelegate.currentChannelGroup;
}



- (void)fmGetAllChannelInfos
{
    if (!_appDelegate.allChannelGroup)
    {
        NSArray *channelsName = @[@"channelFeeling",
                                  @"channelLanguage",
                                  @"channelRecomand",
                                  @"channelSongStyle"];
        
        NSMutableArray *allChannelArray = [[NSMutableArray alloc] init];
        for (NSString *singleChannelName in channelsName)
        {
            NSDictionary *channelGroupDic = [Utils getDicitonaryWithPlistFile:singleChannelName];
            ChannelType type = [Utils getChannelGroupTypeWithChannelName:singleChannelName];
            ChannelGroup *channelGroup = [[ChannelGroup alloc] initWithChannelType:type channelName:singleChannelName channelGroupDictionary:channelGroupDic];
            [allChannelArray addObject:channelGroup];
        }
        
        _appDelegate.allChannelGroup = allChannelArray;
    }
}



- (ChannelInfo *)fmSearchChannelInfoWithName:(NSString *)channelName
{
    [self fmGetAllChannelInfos];
    NSMutableArray *allChannelInfo = _appDelegate.allChannelGroup;
    
    
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
    [_appDelegate.currentUserInfo.userSharedChannelLists removeObjectAtIndex:channelIndex];
    [Config saveUserSharedChannelList:_appDelegate.currentUserInfo.userSharedChannelLists];
}

- (void)fmUpdateMySharedChannelListWithChannelName:(NSString *)channelName
{
    if (![self fmIsChannelInMySharedChannelList:channelName])
    {
        [self fmGetAllChannelInfos];
        for (ChannelGroup *singleChannelGroup in _appDelegate.allChannelGroup)
        {
            for (ChannelInfo *singleChannelInfo in singleChannelGroup.channelArray)
            {
                if ([singleChannelInfo.channelName isEqualToString:channelName])
                {
                    [_appDelegate.currentUserInfo.userSharedChannelLists insertObject:singleChannelInfo atIndex:0];
                    [Config saveUserSharedChannelList:_appDelegate.currentUserInfo.userSharedChannelLists];
                }
            }
        }
        
    }
}

- (BOOL)fmIsChannelInMySharedChannelList:(NSString *)channelName
{
    for (ChannelInfo *singleChannelInfo in _appDelegate.currentUserInfo.userSharedChannelLists)
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
    ChannelInfo *updateChannelInfo = [_appDelegate.currentPlayerInfo.currentChannel initWithChannelInfo:newCurrentChannelInfo];
    [Config saveCurrentChannelInfo:updateChannelInfo];
}

- (ChannelInfo *)fmGetCurrentChannel
{
    return _appDelegate.currentPlayerInfo.currentChannel;
}


#pragma mark TweetFunction


- (void)fmGetTweetInfoInLocal
{
    if ([_appDelegate.tweetInfoGroup count] == 0)
    {
        NSString *tweetGroupName = @"localTweetData";
        NSDictionary *tweetGroupDic = [Utils getDicitonaryWithPlistFile:tweetGroupName];
        [self fmGetTweetGroupWithDictionary:tweetGroupDic TweetInfoGroup:_appDelegate.tweetInfoGroup];
        [Config saveTweetInfoGroup:_appDelegate.tweetInfoGroup];
    }
}

- (NSMutableArray *)fmGetTweetInfoWithType:(NSInteger)type
{
    if (type == 1)
    {
        [self fmGetTweetInfoInLocal];
        return _appDelegate.tweetInfoGroup;
    }
    else if (type == 2)
    {
        return _appDelegate.currentUserInfo.userTweeterList;
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
    [_appDelegate.tweetInfoGroup removeObjectAtIndex:localTweetIndex];
    NSInteger myTweetIndex = [self fmSearchTweetInfoWithID:tweetID isMyTweetGroup:YES];
    [_appDelegate.currentUserInfo.userTweeterList removeObjectAtIndex:myTweetIndex];
    [Config saveUserTweetList:_appDelegate.currentUserInfo.userTweeterList];
    [Config saveTweetInfoGroup:_appDelegate.tweetInfoGroup];
}


- (void)fmSharedTweeterWithTweetInfo:(TweetInfo *)tweetInfo
{
    [self fmGetTweetInfoInLocal];
    NSMutableArray *tweetInfoGroup = _appDelegate.tweetInfoGroup;
    NSMutableArray *userTweetInfoGroup = _appDelegate.currentUserInfo.userTweeterList;
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
    TweetInfo *updatedTweetInfo = _appDelegate.tweetInfoGroup[index];
    isLike ? (updatedTweetInfo.likeCount++) : (updatedTweetInfo.likeCount--);
    isLike ? (updatedTweetInfo.isLike = @"2") : (updatedTweetInfo.isLike = @"1");
    [Config saveTweetInfoGroup:_appDelegate.tweetInfoGroup];
    if (isMine)
    {
        NSInteger mineIndex = [self fmSearchTweetInfoWithID:tweetID isMyTweetGroup:YES];
        TweetInfo *mineUpdateTweetInfo = _appDelegate.currentUserInfo.userTweeterList[mineIndex];
        isLike ? (mineUpdateTweetInfo.likeCount++) : (mineUpdateTweetInfo.likeCount--);
        isLike ? (mineUpdateTweetInfo.isLike = @"2") : (mineUpdateTweetInfo.isLike = @"1");
        [Config saveUserTweetList:_appDelegate.currentUserInfo.userTweeterList];
    }
    
}

- (NSInteger)fmSearchTweetInfoWithID:(NSString *)tweetID isMyTweetGroup:(BOOL)isMine
{
    NSMutableArray *tweetInfoGroup = nil;
    if (isMine)
    {
        tweetInfoGroup = _appDelegate.currentUserInfo.userTweeterList;
    }
    else
    {
        [self fmGetTweetInfoInLocal];
        tweetInfoGroup = _appDelegate.tweetInfoGroup;
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



#pragma mark LoginOperation

- (UserInfo *)fmGetCurrentUserInfo
{
    return _appDelegate.currentUserInfo;
}


- (BOOL)fmLoginInLocalWithLoginInfo:(LogInfo *)logInfo
{
    NSDictionary *logDic = [Utils getDicitonaryWithPlistFile:@"loginData"];
    if ([logInfo isLoginSuccessfull:logDic])
    {
        NSDictionary *userDic = [Utils getDicitonaryWithPlistFile:@"userData"];
        UserInfo *currentUserInfo = [_appDelegate.currentUserInfo initWithDictionary:userDic];
        [Config saveUserInfo:currentUserInfo];
        return TRUE;
    }
    return FALSE;
}

- (BOOL)fmIsLogin
{
    return  _appDelegate.currentUserInfo.isLogin;
}

- (void)fmLogOut
{
    _appDelegate.currentUserInfo.isLogin = FALSE;
    [Config saveUserInfo:_appDelegate.currentUserInfo];
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



#pragma mark sharedChannelList

- (NSMutableArray *)fmGetMySharedChannelList
{
    return _appDelegate.currentUserInfo.userSharedChannelLists;
}


#pragma mark searchChannelList

- (NSMutableArray *)fmGetSearchChannelList
{
    [self fmGetAllChannelInfos];
    return _appDelegate.allChannelGroup;
}

#pragma mark DawnAndNightMode

- (void)fmSetNightMode:(BOOL)isNightMode
{
    _appDelegate.isNightMode = isNightMode;
    [Config saveDawnAndNightMode:_appDelegate.isNightMode];
}

- (BOOL)fmGetNightMode
{
    return _appDelegate.isNightMode;
}


#pragma mark clearAllData

- (void)fmClearAllData
{
    [Config clearAllDataInUserDefaults];
}


#pragma mark Common Fuction

- (AFHTTPSessionManager *)fmGennerateFMManagerWithType:(managerType)type
{
    AFHTTPSessionManager *manager;
    switch (type)
    {
        case managerTypeJOSN:
            if (!_fmManager || _fmManagerType != managerTypeJOSN)
            {
                manager = [AFHTTPSessionManager fmJSONManager];
                _fmManagerType = managerTypeJOSN;
                return manager;
            }
            break;
        case managerTypeHTTP:
            if (!_fmManager || _fmManagerType != managerTypeHTTP)
            {
                manager = [AFHTTPSessionManager fmHTTPManager];
                _fmManagerType = managerTypeHTTP;
                return manager;
            }
            break;
    }
    return _fmManager;
}



@end
