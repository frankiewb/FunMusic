//
//  TweetInfo.m
//  FunMusic
//
//  Created by frankie on 16/1/2.
//  Copyright © 2016年 Wang Bo. All rights reserved.
//

#import "TweetInfo.h"
#import "TweetCell.h"
#import "ChannelInfo.h"
#import "PlayerInfo.h"
#import "UserInfo.h"
#import "AppDelegate.h"
#import "NSDate+Util.h"



extern const CGFloat kNameFontSize;
extern const CGFloat kDateLikeFontSize;

extern const CGFloat kSmallLabelHeight;
extern const CGFloat kMainImageHeight;
extern const CGFloat kLabelWidthDistance;
extern const CGFloat kLabelHeightDistance;
extern const CGFloat kCellEdgeDistance;

static const CGFloat kIdealTweetCommentHeight = 60;


#define USERIMAGEURL @"http://img3.douban.com/icon/ul%@-1.jpg"
@implementation TweetInfo


- (instancetype)initWithTweetDic:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        _tweetID        = dict[@"id"];
        _tweeterImage   = dict[@"userImage"];
        _tweeterName    = dict[@"userName"];
        _channelName    = dict[@"channelName"];
        _channelImage   = dict[@"channelImage"];
        _tweeterComment = dict[@"tweeterComment"];
        _tweetDate      = dict[@"date"];
        _isLike         = dict[@"like"];
        NSString *likeCountString  = dict[@"likeCount"];
        _likeCount = [likeCountString integerValue];
        NSString *tweetertype = dict[@"tweeterType"];
        NSString *infotype = dict[@"infoType"];
        [tweetertype isEqualToString:@"1"] ? (_tweeterType = tweeterTypeShared) : (_tweeterType = tweeterTypeComment);
        [infotype isEqualToString:@"1"] ? (_infoType = infoTypeFriend) : (_infoType = infoTypeLocal);
       
        [self setTweetHeight];
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
    NSString *tweeterName  = appDelegate.currentUserInfo.userName;
    NSString *channelName  = appDelegate.currentPlayerInfo.currentChannel.channelName;
    NSString *channelImage = appDelegate.currentPlayerInfo.currentChannel.channelImage;
    //理论上本地发布的时间应该以服务器时间为准，毕竟本地时间不实标准时间
    NSString *tweetDate = [NSDate gennerateCurrentTimeString];
    //本地产生的tweetID暂时采用时间作为标示，但是服务器后台应该有一个唯一的ID标示位
    NSString *tweetID = tweetDate;
    NSString *isLike = @"1";
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
                          tweetID,        @"id",
                          tweeterImage,   @"userImage",
                          tweeterName,    @"userName",
                          channelName,    @"channelName",
                          channelImage,   @"channelImage",
                          tweetDate,      @"date",
                          tweeterComment, @"tweeterComment",
                          tweeterType,    @"tweeterType",
                          likeCount,      @"likeCount",
                          infoType,       @"infoType",
                          isLike,         @"like",nil];
    
    return dict;   

}



- (void)setTweetHeight
{
    //boundingRectWithSize 参数是一个constraint ,用于在绘制文本时作为参考。但是，如果绘制完整个文本需要更大的空间，则返回的矩形大小可能比 size 更大。
    //一般，绘制时会采用constraint 提供的宽度，但高度则会根据需要而定。
    CGSize textSize = [_tweeterComment boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 2*kCellEdgeDistance, kIdealTweetCommentHeight)
                                                    options: NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kNameFontSize]}
                                                    context:nil].size;
    CGFloat cellheight = textSize.height + (kSmallLabelHeight * 2) + kMainImageHeight + (kCellEdgeDistance * 2) + (kLabelHeightDistance * 3);
    _cellHeight = cellheight;

}




@end
