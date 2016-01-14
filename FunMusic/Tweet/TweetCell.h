//
//  TweetCell.h
//  FunMusic
//
//  Created by frankie on 16/1/2.
//  Copyright © 2016年 Wang Bo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TweetInfo;

static const CGFloat kNameFontSize        = 16;
static const CGFloat kDateLikeFontSize    = 12;

static const CGFloat kSmallLabelHeight    = 20;
static const CGFloat kTweeterLabelWidth   = 50;
static const CGFloat kTweeterImageHeight  = 30;
static const CGFloat kMainlabelHeight     = 60;
static const CGFloat kMainImageHeight     = 60;
static const CGFloat kLabelWidthDistance  = 15;
static const CGFloat kLabelHeightDistance = 10;
static const CGFloat kCellEdgeDistance    = 15;

@interface TweetCell : UITableViewCell

@property (nonatomic, copy) void(^deleteTweetCell)(NSString *tweetID);
@property (nonatomic, copy) void(^updateTweetLikeCount)(NSString *tweetID, BOOL isLike);
@property (nonatomic, copy) void(^scrollView)(NSInteger index, NSString *channelName);

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

- (void)setUpTweetCellWithTweetInfo:(TweetInfo *)tweetInfo;

@end
