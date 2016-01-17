//
//  Config.h
//  FunMusic
//
//  Created by frankie on 16/1/17.
//  Copyright © 2016年 Wang Bo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UserInfo;
@class ChannelInfo;

@interface Config : NSObject


+ (void)saveDawnAndNightMode:(BOOL)isNightMode;
+ (BOOL)getDawnAndNightMode;

+ (void)saveUserInfo:(UserInfo *)userInfo;
+ (UserInfo *)getUserInfo;

+ (void)saveCurrentChannelInfo:(ChannelInfo *)channelInfo;
+ (ChannelInfo *)getCurrentChannelInfo;

+ (void)saveTweetInfoGroup:(NSMutableArray *)tweetInfoGroup;
+ (NSMutableArray *)getTweetInfoGroup;

+ (void)saveUserTweetList:(NSMutableArray *)userTweetList;
+ (NSMutableArray *)getUserTweetList;

+ (void)saveUserSharedChannelList:(NSMutableArray *)userSharedChannelList;
+ (NSMutableArray *)getUserSharedChannelList;

+ (void)clearAllDataInUserDefaults;



@end
