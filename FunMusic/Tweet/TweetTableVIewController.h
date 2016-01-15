//
//  TweetTableVIewController.h
//  FunMusic
//
//  Created by frankie on 16/1/2.
//  Copyright © 2016年 Wang Bo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TweetTableVIewController : UITableViewController

- (instancetype)initWithUserID:(NSString *)ID TweeterName:(NSString *)name;
- (void)fetchTweetData;

- (void)dawnAndNightMode;

@end
