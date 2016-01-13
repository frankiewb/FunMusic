//
//  SharedChannelTableController.h
//  FunMusic
//
//  Created by frankie on 16/1/13.
//  Copyright © 2016年 Wang Bo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SharedChannelTableController : UITableViewController

@property(nonatomic, copy) void(^presidentView)(NSInteger indexPath);

@end
