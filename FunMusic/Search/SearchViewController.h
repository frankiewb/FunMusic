//
//  SearchViewController.h
//  FunMusic
//
//  Created by frankie on 15/12/30.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UITableViewController

@property(nonatomic, copy) void(^presidentView)(NSInteger indexPath);

@end
