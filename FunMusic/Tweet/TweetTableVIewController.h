//
//  TweetTableVIewController.h
//  FunMusic
//
//  Created by frankie on 16/1/2.
//  Copyright © 2016年 Wang Bo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TweetTableVIewController : UITableViewController

@property(nonatomic, copy) void(^presidentView)(NSInteger indexPath);

- (void)fetchTweetData;

@end
