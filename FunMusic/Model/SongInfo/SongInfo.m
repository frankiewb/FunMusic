//
//  SongInfo.m
//  FunMusic
//
//  Created by frankie on 15/12/25.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import "SongInfo.h"

@implementation SongInfo

- (instancetype)initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    if (self)
    {
        self.songArtist     = dic[@"artist"];
        self.songTitle      = dic[@"title"];
        self.songUrl        = dic[@"url"];
        self.songPictureUrl = dic[@"picture"];
        self.songTimeLong   = dic[@"length"];
        self.songIsLike     = dic[@"like"];
        self.songId         = dic[@"sid"];
    }
    return self;
}



@end
