//
//  Config.m
//  FunMusic
//
//  Created by frankie on 16/1/17.
//  Copyright © 2016年 Wang Bo. All rights reserved.
//

#import "Config.h"
#import "UserInfo.h"
#import "TweetInfo.h"
#import "ChannelInfo.h"
#import "SongInfo.h"

static  NSString *kNightModeKey       = @"nightMode";
static  NSString *kUserID             = @"userID";
static  NSString *kUserLogin          = @"userLogin";
static  NSString *kUserName           = @"userName";
static  NSString *kUserImage          = @"userImage";
static  NSString *kTweetInfoList      = @"tweetInfoList";
static  NSString *kSharedChannelList  = @"sharedChannelList";
static  NSString *kCurrentChannelInfo = @"currentChannelInfo";
static  NSString *kCurrentSongInfo    = @"currentSongInfo";
static  NSString *kTweetInfoGroup     = @"tweetInfoGroup";

@implementation Config

#pragma clear all

+ (void)clearAllDataInUserDefaults
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:kNightModeKey];
    [userDefaults removeObjectForKey:kUserID];
    [userDefaults removeObjectForKey:kUserLogin];
    [userDefaults removeObjectForKey:kUserName];
    [userDefaults removeObjectForKey:kUserImage];
    [userDefaults removeObjectForKey:kTweetInfoList];
    [userDefaults removeObjectForKey:kSharedChannelList];
    [userDefaults removeObjectForKey:kCurrentChannelInfo];
    [userDefaults removeObjectForKey:kTweetInfoGroup];
}



#pragma DawnAndNight

+ (void)saveDawnAndNightMode:(BOOL)isNightMode
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(isNightMode) forKey:kNightModeKey];
    [userDefaults synchronize];
}

//如果不存在返回NO
+ (BOOL)getDawnAndNightMode
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isNightMode = [[userDefaults objectForKey:kNightModeKey] boolValue];
    return isNightMode;
}


#pragma UserInfo

+ (void)saveUserInfo:(UserInfo *)userInfo
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(userInfo.isLogin) forKey:kUserLogin];
    [userDefaults setObject:userInfo.userID forKey:kUserID];
    [userDefaults setObject:userInfo.userName forKey:kUserName];
    [userDefaults setObject:userInfo.userImage forKey:kUserImage];
    [self saveUserTweetList:userInfo.userTweeterList];
    [self saveUserSharedChannelList:userInfo.userSharedChannelLists];
    [userDefaults synchronize];
}

+ (UserInfo *)getUserInfo
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    UserInfo *userInfo = [[UserInfo alloc] init];
    userInfo.isLogin = [[userDefaults objectForKey:kUserLogin] boolValue];
    userInfo.userID = [userDefaults objectForKey:kUserID];
    userInfo.userName = [userDefaults objectForKey:kUserName];
    userInfo.userImage = [userDefaults objectForKey:kUserImage];
    userInfo.userTweeterList = [self getUserTweetList];
    userInfo.userSharedChannelLists = [self getUserSharedChannelList];
    
    return userInfo;
    
}


#pragma UserTweetList
//NSUserDefaults存储的对象全是不可变的，如果想存储一个NSMutableArray对象，必须创建一个不可变数组NSArray，再将其存入NSUserDefaults中去
+ (void)saveUserTweetList:(NSMutableArray *)userTweetList
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *tempTweetDataList = [[NSMutableArray alloc] init];
    for (TweetInfo *singleTweetInfo in userTweetList)
    {
        NSData *tweetData = [NSKeyedArchiver archivedDataWithRootObject:singleTweetInfo];
        [tempTweetDataList addObject:tweetData];
    }
    NSArray *tweetDataList = [NSArray arrayWithArray:tempTweetDataList];
    [userDefaults setObject:tweetDataList forKey:kTweetInfoList];
    [userDefaults synchronize];
    
}

+ (NSMutableArray *)getUserTweetList
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *tempTweetDataList = [userDefaults objectForKey:kTweetInfoList];
    NSMutableArray *tweetInfoList = [[NSMutableArray alloc] init];
    for (NSData *singleTweetData in tempTweetDataList)
    {
        TweetInfo *tweetInfo = [NSKeyedUnarchiver unarchiveObjectWithData:singleTweetData];
        if (tweetInfo)
        {
            [tweetInfoList addObject:tweetInfo];
        }
        
    }
    
    return tweetInfoList;
}

#pragma TweetInfoGroup

+ (void)saveTweetInfoGroup:(NSMutableArray *)tweetInfoGroup
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *tempTweetDataList = [[NSMutableArray alloc] init];
    for (TweetInfo *singleTweetInfo in tweetInfoGroup)
    {
        NSData *tweetData = [NSKeyedArchiver archivedDataWithRootObject:singleTweetInfo];
        [tempTweetDataList addObject:tweetData];
    }
    NSArray *tweetDataList = [NSArray arrayWithArray:tempTweetDataList];
    [userDefaults setObject:tweetDataList forKey:kTweetInfoGroup];
    [userDefaults synchronize];
}

+ (NSMutableArray *)getTweetInfoGroup
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *tempTweetDataList = [userDefaults objectForKey:kTweetInfoGroup];
    NSMutableArray *tweetInfoGroup = [[NSMutableArray alloc] init];
    for (NSData *singleTweetData in tempTweetDataList)
    {
        TweetInfo *tweetInfo = [NSKeyedUnarchiver unarchiveObjectWithData:singleTweetData];
        if (tweetInfo)
        {
            [tweetInfoGroup addObject:tweetInfo];
        }
        
    }
    
    return tweetInfoGroup;
}



#pragma UserSharedChannelList

+ (void)saveUserSharedChannelList:(NSMutableArray *)userSharedChannelList
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *tempSharedChannelList = [[NSMutableArray alloc] init];
    for (ChannelInfo *singleChannelInfo in userSharedChannelList)
    {
        NSData *channelData = [NSKeyedArchiver archivedDataWithRootObject:singleChannelInfo];
        [tempSharedChannelList addObject:channelData];
    }
    NSArray *sharedChannelList = [NSArray arrayWithArray:tempSharedChannelList];
    [userDefaults setObject:sharedChannelList forKey:kSharedChannelList];
    [userDefaults synchronize];
}

+ (NSMutableArray *)getUserSharedChannelList
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *tempSharedChannelList = [userDefaults objectForKey:kSharedChannelList];
    NSMutableArray *sharedChannelList = [[NSMutableArray alloc] init];
    for (NSData *singleChannelData in tempSharedChannelList)
    {
        ChannelInfo *channelInfo = [NSKeyedUnarchiver unarchiveObjectWithData:singleChannelData];
        if (channelInfo)
        {
            [sharedChannelList addObject:channelInfo];
        }
    }
    
    return sharedChannelList;
}


#pragma CurrentChannel

+ (void)saveCurrentChannelInfo:(ChannelInfo *)channelInfo
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *currentChannelData = [NSKeyedArchiver archivedDataWithRootObject:channelInfo];
    [userDefaults setObject:currentChannelData forKey:kCurrentChannelInfo];
    [userDefaults synchronize];
}

+ (ChannelInfo *)getCurrentChannelInfo
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *currentChannelData = [userDefaults objectForKey:kCurrentChannelInfo];
    ChannelInfo *currentChannelInfo = [NSKeyedUnarchiver unarchiveObjectWithData:currentChannelData];
    return currentChannelInfo;
}

#pragma CurrentSong

+ (void)saveCurrentSongInfo:(SongInfo *)songInfo
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *currentSongData = [NSKeyedArchiver archivedDataWithRootObject:songInfo];
    [userDefaults setObject:currentSongData forKey:kCurrentSongInfo];
    [userDefaults synchronize];
}

+ (SongInfo *)getCurrentSongInfo
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *currentSongData = [userDefaults objectForKey:kCurrentSongInfo];
    SongInfo *currentSongInfo = [NSKeyedUnarchiver unarchiveObjectWithData:currentSongData];
    return currentSongInfo;
}

@end
