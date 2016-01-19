//
//  SideBarCell.h
//  FunMusic
//
//  Created by frankie on 16/1/11.
//  Copyright © 2016年 Wang Bo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MenuInfo;

@interface SideMenuCell : UITableViewCell

- (void)setSideMenuCellWithOPInfo:(MenuInfo *)sideMenuInfo;

- (void)dawnAndNightMode;

- (void)changeDawnCell;


@end
