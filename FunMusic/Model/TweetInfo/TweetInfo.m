//
//  TweetInfo.m
//  FunMusic
//
//  Created by frankie on 16/1/2.
//  Copyright © 2016年 Wang Bo. All rights reserved.
//

#import "TweetInfo.h"
#import "ChannelInfo.h"
#import "PlayerInfo.h"
#import "UserInfo.h"
#import "AppDelegate.h"
#import "NSDate+Util.h"


#define USERIMAGEURL @"http://img3.douban.com/icon/ul%@-1.jpg"
@implementation TweetInfo


- (instancetype)initWithTweetDic:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        _tweeterImage = dict[@"userImage"];
        _tweeterName  = dict[@"userName"];
        _channelName = dict[@"channelName"];
        _channelImage = dict[@"channelImage"];
        _tweeterComment = dict[@"tweeterComment"];
        _tweetDate = dict[@"date"];
        _likeCount = dict[@"likeCount"];
        NSString *Ttype = dict[@"tweeterType"];
        [Ttype isEqualToString:@"1"] ? (_tweeterType = tweeterTypeShared) : (_tweeterType = tweeterTypeComment);
        NSString *Itype = dict[@"infoType"];
        [Itype isEqualToString:@"1"] ? (_infoType = infoTypeFriend) : (_infoType = infoTypeLocal);
    }
    
    return  self;
}


- (instancetype)initWithTweeterCommentByLocal:(NSString *)comment Local:(AppDelegate *)appDelegate
{
    self = [super init];
    if (self)
    {
        NSDictionary *localTweet = [self gennerateLocalTweeterDictionaryWithComment:comment Local:appDelegate];
        return  [self initWithTweetDic:localTweet];
    }
    
    return  self;
}


- (NSDictionary *)gennerateLocalTweeterDictionaryWithComment:(NSString *)comment Local:(AppDelegate *)appDelegate
{
    NSString *tweeterImage = [NSString stringWithFormat:USERIMAGEURL,appDelegate.currentUserInfo.userID];
    NSString *tweeterName = appDelegate.currentUserInfo.userName;
    NSString *channelName = appDelegate.currentPlayerInfo.currentChannel.channelName;
    NSString *channelImage = appDelegate.currentPlayerInfo.currentChannel.channelImage;
    //理论上本地发布的时间应该以服务器时间为准，毕竟本地时间不实标准时间
    NSString *tweetDate = [NSDate gennerateCurrentTimeString];
    NSString *tweeterComment;
    NSString *tweeterType;
    if (comment)
    {
        tweeterComment = comment;
        tweeterType = @"2";
    }
    else
    {
        tweeterComment = @"";
        tweeterType = @"1";
    }
    NSString *likeCount = @"0";
    NSString *infoType = @"2";
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          tweeterImage,   @"userImage",
                          tweeterName,    @"userName",
                          channelName,    @"channelName",
                          channelImage,   @"channelImage",
                          tweetDate,      @"date",
                          tweeterComment, @"tweeterComment",
                          tweeterType,    @"tweeterType",
                          likeCount,      @"likeCount",
                          infoType,       @"infoType",nil];
    
    return dict;
    
    

}




@end
