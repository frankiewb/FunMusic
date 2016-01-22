//
//  SongInfo.m
//  FunMusic
//
//  Created by frankie on 15/12/25.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import "SongInfo.h"

static NSString *kSongArtist     = @"songArtist";
static NSString *kSongTitle      = @"songTitle";
static NSString *kSongURL        = @"songURL";
static NSString *kSongPictureUrl = @"songPictureURL";
static NSString *kSongTimeLong   = @"songTimeLong";
static NSString *kSongIsLike     = @"songIsLike";
static NSString *kSongId         = @"songID";

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

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.songArtist forKey:kSongArtist];
    [aCoder encodeObject:self.songTitle forKey:kSongTitle];
    [aCoder encodeObject:self.songUrl forKey:kSongURL];
    [aCoder encodeObject:self.songPictureUrl forKey:kSongPictureUrl];
    [aCoder encodeObject:self.songTimeLong forKey:kSongTimeLong];
    [aCoder encodeObject:self.songIsLike forKey:kSongIsLike];
    [aCoder encodeObject:self.songId forKey:kSongId];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        self.songArtist     = [aDecoder decodeObjectForKey:kSongArtist];
        self.songTitle      = [aDecoder decodeObjectForKey:kSongTitle];
        self.songUrl        = [aDecoder decodeObjectForKey:kSongURL];
        self.songPictureUrl = [aDecoder decodeObjectForKey:kSongPictureUrl];
        self.songTimeLong   = [aDecoder decodeObjectForKey:kSongTimeLong];
        self.songIsLike     = [aDecoder decodeObjectForKey:kSongIsLike];
        self.songId         = [aDecoder decodeObjectForKey:kSongId];
    }
    
    return self;
}



@end
