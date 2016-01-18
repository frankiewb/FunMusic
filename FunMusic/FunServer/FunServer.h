//
//  FunServer.h
//  FunMusic
//
//  Created by frankie on 15/12/25.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SongOperationType)
{
    SongOperationTypeNext = 1, //None. Used for get a song list only.
    SongOperationTypeEnd,      //Ended a song normally.
    SongOperationTypeUnlike,   //Unlike a hearted song.
    SongOperationTypeLike,     //Like a song.
    SongOperationTypeSkip,     //Skip a song.
    SongOperationTypeDelete,   //Delete a song.
    SongOperationTypePlay,     //Use to get a song list when the song in playlist was all played.
};


typedef NS_ENUM(NSInteger,funViewType)
{
    funViewTypeMusic = 0,
    funViewTypeChannel,
    funViewTypeTweeter,
    funViewTypeMine,
};


@class TweetInfo;
@class LogInfo;
@class UserInfo;
@class ChannelGroup;
@class ChannelInfo;
@class PlayerInfo;
@class MPMoviePlayerController;


@interface FunServer : NSObject

#pragma SongOperation
- (PlayerInfo *)fmGetCurrentPlayerInfo;
- (MPMoviePlayerController *)fmGetCurrentMusicPlayer;
- (void)fmSongOperationWithType:(SongOperationType) operationType;
@property(nonatomic, copy) void (^getSongListFail)();

#pragma CShannelOperation
- (void)fmUpdateMySharedChannelListWithChannelName:(NSString *)channelName;
- (void)fmDeleteMySharedChannelListWithChannelIndex:(NSInteger)channelIndex;
- (ChannelGroup *)fmGetChannelWithTypeInLocal:(NSInteger)channelType;
- (ChannelInfo *)fmSearchChannelInfoWithName:(NSString *)channelName;
- (ChannelInfo *)fmGetCurrentChannel;
- (void)fmUpdateCurrentChannelInfo:(ChannelInfo *)newCurrentChannelInfo;
- (void)fmGetAllChannelInfos;

#pragma TweeterOperation
- (void)fmGetTweetInfoInLocal;
- (void)fmSharedTweeterWithTweetInfo:(TweetInfo *)tweetInfo;
- (void)fmDeleteTweetInfoWithTweetID:(NSString *)tweetID;
- (void)fmUpdateTweetLikeCountWithTweetID:(NSString *)tweetID like:(BOOL)isLike isMineTweet:(BOOL)isMine;
- (NSInteger)searchTweetInfoWithID:(NSString *)tweetID isMyTweetGroup:(BOOL)isMine;
- (NSMutableArray *)fmGetTweetInfoWithType:(NSInteger)type;

#pragma LoginOperation
- (UserInfo *)fmGetCurrentUserInfo;
- (BOOL)fmLoginInLocalWithLoginInfo:(LogInfo *)logInfo;
- (BOOL)fmIsLogin;
- (void)fmLogOut;

#pragma DawnAndNightMode
- (void)fmSetNightMode:(BOOL)isNightMode;
- (BOOL)fmGetNightMode;

#pragma MenuInfo
- (NSMutableArray *)fmGetSideMenuInfo;
- (NSMutableArray *)fmGetMineMenuInfo;

#pragma MysharedChannelList
- (NSMutableArray *)fmGetMySharedChannelList;

#pragma SearchChannelList
- (NSMutableArray *)fmGetSearchChannelList;

#pragma ClearAllData
- (void)fmClearAllData;














@end
