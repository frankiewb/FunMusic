//
//  MineOPCell.h
//  FunMusic
//
//  Created by frankie on 16/1/7.
//  Copyright © 2016年 Wang Bo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MenuInfo;

@interface MineOPCell : UITableViewCell

- (void)setMineOPCellWithOPInfo:(MenuInfo *)opInfo;

- (void)dawnAndNightMode;

- (void)changeDawnCell;

@end
