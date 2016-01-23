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
#import "FunServer.h"
#import "NSDate+Util.h"



extern const CGFloat kNameFontSize;
extern const CGFloat kDateLikeFontSize;
extern const CGFloat kSmallLabelHeight;
extern const CGFloat kMainImageHeight;
extern const CGFloat kLabelWidthDistance;
extern const CGFloat kLabelHeightDistance;
extern const CGFloat kCellEdgeDistance;

static const CGFloat kIdealTweetCommentHeight = 60;
static const CGFloat kNilTweeterCommentHeight = 2;
static const CGFloat kExtraCommentHeight = 35;

static NSString *kTweetID        = @"tweetID";
static NSString *kTweetImage     = @"tweetImage";
static NSString *kTweetName      = @"tweetName";
static NSString *kChannelImage   = @"channelImage";
static NSString *kChannelName    = @"channelName";
static NSString *kTweeterComment = @"tweeterComment";
static NSString *kTweetDate      = @"tweetDate";
static NSString *kIsLike         = @"isLike";
static NSString *kLikeCount      = @"likeCount";
static NSString *kTweeterType    = @"tweeterType";
static NSString *kInfoType       = @"infoType";
static NSString *kCellHeight     = @"cellHeight";

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
        _tweetDate      = dict[@"date"];
        _isLike         = dict[@"like"];
        
        NSString *comment = dict[@"tweeterComment"];
        _tweeterComment = [comment stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
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



- (instancetype)initWithTweeterCommentByLocal:(NSString *)comment
{
    self = [super init];
    if (self)
    {
        NSDictionary *localTweet = [self gennerateLocalTweeterDictionaryWithComment:comment];
        return  [self initWithTweetDic:localTweet];
    }
    
    return  self;
}


- (NSDictionary *)gennerateLocalTweeterDictionaryWithComment:(NSString *)comment
{
    FunServer *funServer = [[FunServer alloc] init];
    UserInfo *currentUserInfo = [funServer fmGetCurrentUserInfo];
    PlayerInfo *currentPlayerInfo = [funServer fmGetCurrentPlayerInfo];
    NSString *tweeterImage = currentUserInfo.userImage;
    NSString *tweeterName  = currentUserInfo.userName;
    NSString *channelName  = currentPlayerInfo.currentChannel.channelName;
    NSString *channelImage = currentPlayerInfo.currentChannel.channelImage;
    NSString *tweetDate = [NSDate gennerateCurrentTimeString];
    //本地产生的tweetID暂时采用时间作为标示，但是服务器后台应该有一个唯一的ID标示位
    NSString *tweetID = tweetDate;
    NSString *isLike = @"1";
    NSString *tweeterComment;
    NSString *tweeterType;
    tweeterComment = [comment stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    ([tweeterComment isEqualToString:@""]) ? (tweeterType = @"1") : (tweeterType = @"2");
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

- (instancetype)initWithTweetInfo:(TweetInfo *)tweetInfo
{
    self = [super init];
    if (self)
    {
        _tweetID        = tweetInfo.tweetID;
        _tweeterImage   = tweetInfo.tweeterImage;
        _tweeterName    = tweetInfo.tweeterName;
        _channelImage   = tweetInfo.channelImage;
        _channelName    = tweetInfo.channelName;
        _tweeterComment = tweetInfo.tweeterComment;
        _tweetDate      = tweetInfo.tweetDate;
        _isLike         = tweetInfo.isLike;
        _likeCount      = tweetInfo.likeCount;
        _tweeterType    = tweetInfo.tweeterType;
        _infoType       = tweetInfo.infoType;
        _cellHeight     = tweetInfo.cellHeight;
    }
    
    return self;
}



- (void)setTweetHeight
{
    //boundingRectWithSize 参数是一个constraint ,用于在绘制文本时作为参考。但是，如果绘制完整个文本需要更大的空间，则返回的矩形大小可能比 size 更大。
    //一般，绘制时会采用constraint 提供的宽度，但高度则会根据需要而定。
    CGSize textSize;
    if (![_tweeterComment isEqualToString:@""])
    {
        textSize.height = [_tweeterComment boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 2*kCellEdgeDistance, kIdealTweetCommentHeight)
                                                        options: NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kNameFontSize]}
                                                        context:nil].size.height;
        textSize.height = textSize.height + kExtraCommentHeight;
    }
    else
    {
        textSize.height = kNilTweeterCommentHeight;
    }
    CGFloat cellheight = textSize.height + (kSmallLabelHeight * 2) + kMainImageHeight + (kCellEdgeDistance * 2) + (kLabelHeightDistance * 3);
    _cellHeight = cellheight;
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.tweetID forKey:kTweetID];
    [aCoder encodeObject:self.tweeterImage forKey:kTweetImage];
    [aCoder encodeObject:self.tweeterName forKey:kTweetName];
    [aCoder encodeObject:self.channelImage forKey:kChannelImage];
    [aCoder encodeObject:self.channelName forKey:kChannelName];
    [aCoder encodeObject:self.tweeterComment forKey:kTweeterComment];
    [aCoder encodeObject:self.tweetDate forKey:kTweetDate];
    [aCoder encodeObject:self.isLike forKey:kIsLike];
    [aCoder encodeInteger:self.likeCount forKey:kLikeCount];
    [aCoder encodeInteger:self.tweeterType forKey:kTweeterType];
    [aCoder encodeInteger:self.infoType forKey:kInfoType];
    [aCoder encodeInteger:self.cellHeight forKey:kCellHeight];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        self.tweetID        = [aDecoder decodeObjectForKey:kTweetID];
        self.tweeterImage   = [aDecoder decodeObjectForKey:kTweetImage];
        self.tweeterName    = [aDecoder decodeObjectForKey:kTweetName];
        self.channelImage   = [aDecoder decodeObjectForKey:kChannelImage];
        self.channelName    = [aDecoder decodeObjectForKey:kChannelName];
        self.tweeterComment = [aDecoder decodeObjectForKey:kTweeterComment];
        self.tweetDate      = [aDecoder decodeObjectForKey:kTweetDate];
        self.isLike         = [aDecoder decodeObjectForKey:kIsLike];
        self.likeCount      = [aDecoder decodeIntegerForKey:kLikeCount];
        self.tweeterType    = [aDecoder decodeIntegerForKey:kTweeterType];
        self.infoType       = [aDecoder decodeIntegerForKey:kInfoType];
        self.cellHeight     = [aDecoder decodeIntegerForKey:kCellHeight];
    }
    
    return self;
}


@end
