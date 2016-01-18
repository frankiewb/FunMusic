//
//  TweetTableVIewController.h
//  FunMusic
//
//  Created by frankie on 16/1/2.
//  Copyright © 2016年 Wang Bo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,tweetViewType)
{
    tweetViewTypeLocal = 1,
    tweetViewTypeMine,
};



@interface TweetTableVIewController : UITableViewController

- (instancetype)initWithType:(tweetViewType)type TweeterName:(NSString *)name;
- (void)fetchTweetData;

- (void)dawnAndNightMode;

@end
