//
//  SongInfo.h
//  FunMusic
//
//  Created by frankie on 15/12/25.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SongInfo : NSObject

@property (nonatomic, copy) NSString *songTitle;
@property (nonatomic, copy) NSString *songArtist;
@property (nonatomic, copy) NSString *songPictureUrl;
@property (nonatomic, copy) NSString *songTimeLong;
@property (nonatomic, copy) NSString *songIsLike;
@property (nonatomic, copy) NSString *songUrl;
@property (nonatomic, copy) NSString *songId;


- (instancetype)initWithDictionary:(NSDictionary *)dic;

@end
