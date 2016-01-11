//
//  AppDelegate.h
//  FunMusic
//
//  Created by frankie on 15/12/25.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <MediaPlayer/MediaPlayer.h>

@class UserInfo;
@class PlayerInfo;
@class ChannelGroup;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic) MPMoviePlayerController *MusicPlayer;

@property (nonatomic, strong) UserInfo *currentUserInfo;
@property (nonatomic, strong) PlayerInfo *currentPlayerInfo;
@property (nonatomic, strong) ChannelGroup *currentChannelGroup;
@property (nonatomic, strong) NSMutableArray *tweetInfoGroup;
@property (nonatomic, strong) NSMutableArray *allChannelGroup;




@property (nonatomic, readonly, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readonly, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (BOOL)isLogin;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end

