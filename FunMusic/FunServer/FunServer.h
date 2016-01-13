//
//  FunServer.h
//  FunMusic
//
//  Created by frankie on 15/12/25.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChannelGroup.h"



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



@class TweetInfo;
@class LogInfo;

@interface FunServer : NSObject

#pragma songOperation
- (void)fmSongOperationWithType:(SongOperationType) operationType;
@property (nonatomic, copy) void (^getSongListFail)();

#pragma channelOperation
- (void)fmGetChannelWithTypeInLocal:(ChannelType)channelType;
- (ChannelInfo *)searchChannelInfoWithName:(NSString *)channelName;
- (NSMutableArray *)fmGetAllChannelInfos;
- (void)fmUpdateMySharedChannelListWithChannelName:(NSString *)channelName;

#pragma TweeterOperation
- (void)fmGetTweetInfoInLocal;
- (NSMutableArray *)fmGetTweetInfoWithUserID:(NSString *)userID;
- (void)fmSharedTweeterWithTweetInfo:(TweetInfo *)tweetInfo;
- (void)fmUpdateTweetLikeCountWithTweetID:(NSString *)tweetID like:(BOOL)isLike;
- (NSInteger)searchTweetInfoWithID:(NSString *)tweetID isMyTweetGroup:(BOOL)isMine;

#pragma LoginOperation
- (BOOL)fmLoginInLocalWithLoginInfo:(LogInfo *)logInfo;












@end
