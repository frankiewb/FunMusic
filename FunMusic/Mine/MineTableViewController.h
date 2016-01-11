//
//  MineTableViewController.h
//  FunMusic
//
//  Created by frankie on 16/1/7.
//  Copyright © 2016年 Wang Bo. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MineTableViewController : UITableViewController

@property (nonatomic, copy) void(^presentView)(NSInteger indexPath);

- (void)refreshUserView;

@end
