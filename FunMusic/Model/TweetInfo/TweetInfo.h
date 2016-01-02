//
//  TweetInfo.h
//  FunMusic
//
//  Created by frankie on 16/1/2.
//  Copyright © 2016年 Wang Bo. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, tweeterType)
{
    tweeterTypeShared = 1,// 分享频道
    tweeterTypeComment,// 评论频道
};


typedef NS_ENUM(NSInteger, infoType)
{
    infoTypeLocal = 1, //本地发出
    infoTypeFriend, //朋友发出
};

@class AppDelegate;
@interface TweetInfo : NSObject

@property (nonatomic, copy) NSString *tweeterImage;
@property (nonatomic, copy) NSString *tweeterName;
@property (nonatomic, copy) NSString *channelImage;
@property (nonatomic, copy) NSString *channelName;
@property (nonatomic, copy) NSString *tweeterComment;
@property (nonatomic, copy) NSString *tweetDate;
@property (nonatomic, copy) NSString *likeCount;
@property (nonatomic, assign) tweeterType tweeterType;
@property (nonatomic, assign) infoType infoType;


- (instancetype) initWithTweetDic:(NSDictionary *)dict;
- (instancetype)initWithTweeterCommentByLocal:(NSString *)comment Local:(AppDelegate *)appDelegate;

@end


