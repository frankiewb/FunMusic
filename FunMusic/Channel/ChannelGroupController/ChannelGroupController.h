//
//  ChannelGroupController.h
//  FunMusic
//
//  Created by frankie on 15/12/27.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChannelGroup.h"

@interface ChannelGroupController : UITableViewController

@property(nonatomic, copy) void(^presidentView)(NSInteger indexPath);

- (instancetype)initWithChannelGroupName:(NSString *)channelGroupName;



@end
