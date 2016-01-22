//
//  MusicPlayerViewController.h
//  FunMusic
//
//  Created by frankie on 15/12/31.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MusicPlayerViewController : UIViewController

- (void)dawnAndNightMode;

- (void)pauseClicked;

- (void)playClicked;

- (void)skipClicked;

+ (instancetype)sharedInstance;

@end
