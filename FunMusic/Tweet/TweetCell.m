//
//  TweetCell.m
//  FunMusic
//
//  Created by frankie on 16/1/2.
//  Copyright © 2016年 Wang Bo. All rights reserved.
//

#import "TweetCell.h"
#import "TweetInfo.h"
#import <UIImageView+WebCache.h>
#import <Masonry.h>

@interface TweetCell ()

@property (nonatomic, strong) UIImageView *tweeterImageView;
@property (nonatomic, strong) UILabel *tweeterNameLabel;
@property (nonatomic, strong) UIImageView *channelImageView;
@property (nonatomic, strong) UILabel *channelNameLabel;
@property (nonatomic, strong) UILabel *tweeterTypeLabel;
@property (nonatomic, strong) UILabel *tweeterCommentLabel;
@property (nonatomic, strong) UILabel *tweetDateLabel;
@property (nonatomic, strong) UIButton *likeButton;
@property (nonatomic, strong) UILabel *likeCountLabel;
@property (nonatomic, strong) UIButton *deleteButton;

@property (nonatomic, strong) NSString *tweetID;
@property (nonatomic, assign) BOOL isLike;
@property (nonatomic, assign) CGFloat tweetCellHeight;

@end

@implementation TweetCell

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self setUpUI];
        [self setTweetLayout];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return self;
}



- (void)setUpTweetCellWithTweetInfo:(TweetInfo *)tweetInfo
{
    _deleteButton.hidden = NO;
    if (tweetInfo.infoType == infoTypeLocal)
    {
        //[_tweeterImageView sd_setImageWithURL:[NSURL URLWithString:tweetInfo.tweeterImage] placeholderImage:[UIImage imageNamed:@"wait to put"]];
        //Login功能还没开发，暂时从本地获取
        [_tweeterImageView setImage:[UIImage imageNamed:tweetInfo.tweeterImage]];
    }
    else
    {
        [_tweeterImageView setImage:[UIImage imageNamed:tweetInfo.tweeterImage]];
        _deleteButton.hidden = YES;
    }
    
    _tweeterNameLabel.text = tweetInfo.tweeterName;
    [_channelImageView setImage:[UIImage imageNamed:tweetInfo.channelImage]];
    _channelNameLabel.text = [NSString stringWithFormat:@"    频道 ：%@",tweetInfo.channelName];
    (tweetInfo.tweeterType == tweeterTypeShared) ? (_tweeterTypeLabel.text = @"分享频道") : (_tweeterTypeLabel.text = @"评论频道");
    if (tweetInfo.tweeterType == tweeterTypeComment)
    {
         _tweeterCommentLabel.text = [NSString stringWithFormat:@"评论 ：%@",tweetInfo.tweeterComment];
    }
    else
    {
        _tweeterCommentLabel.text = nil;
        
    }
    _tweetDateLabel.text = tweetInfo.tweetDate;
    _likeCountLabel.text = [NSString stringWithFormat:@"%ld",(long)tweetInfo.likeCount];
    _tweetID = tweetInfo.tweetID;
    [tweetInfo.isLike isEqualToString:@"1"] ? (_isLike = FALSE) : (_isLike = TRUE);
     
}


- (void)setUpUI
{
    //tweeterImageView
    _tweeterImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:_tweeterImageView];
    
    //channelImageView
    _channelImageView = [[UIImageView alloc] init];
    _channelImageView.layer.cornerRadius = kMainImageHeight / 2;
    [self.contentView addSubview:_channelImageView];
    
    //tweeterNameLabel
    _tweeterNameLabel = [[UILabel alloc] init];
    _tweeterNameLabel.textColor = [UIColor orangeColor];
    _tweeterNameLabel.font = [UIFont systemFontOfSize:kNameFontSize];
    [self.contentView addSubview:_tweeterNameLabel];
    
    //channelName
    _channelNameLabel = [[UILabel alloc] init];
    _channelNameLabel.font = [UIFont systemFontOfSize:kNameFontSize];
    _channelNameLabel.backgroundColor = [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0];
    //UILabel默认是不允许交互的！！！
    _channelNameLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *scrolViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(channelNameImageClicked)];
    [_channelNameLabel addGestureRecognizer:scrolViewTap];
    [self.contentView addSubview:_channelNameLabel];
    
    //likeButton
    _likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //_isLike = NO;
    [_likeButton setImage:[UIImage imageNamed:@"赞1"] forState:UIControlStateNormal];
    [_likeButton addTarget:self action:@selector(likeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_likeButton];
    
    //DeleteButton
    _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_deleteButton setTitle:@"删除" forState:UIControlStateNormal];
    _deleteButton.titleLabel.font = [UIFont systemFontOfSize:kDateLikeFontSize];
    [_deleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_deleteButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.contentView addSubview:_deleteButton];
    
    //tweeterTypeLabel
    _tweeterTypeLabel = [[UILabel alloc] init];
    _tweeterTypeLabel.font = [UIFont systemFontOfSize:kDateLikeFontSize];
    [self.contentView addSubview:_tweeterTypeLabel];
    
    //tweeterDataLabel
    _tweetDateLabel = [[UILabel alloc] init];
    _tweetDateLabel.font = [UIFont systemFontOfSize:kDateLikeFontSize];
    [self.contentView addSubview:_tweetDateLabel];
    
    //likeCountLabel
    _likeCountLabel = [[UILabel alloc] init];
    _likeCountLabel.font = [UIFont systemFontOfSize:kDateLikeFontSize];
    [self.contentView addSubview:_likeCountLabel];
    
    //tweeterComment
    _tweeterCommentLabel = [[UILabel alloc] init];
    _tweeterCommentLabel.font = [UIFont systemFontOfSize:kDateLikeFontSize];
    //计算多行文本数据高度必须设置为0
    _tweeterCommentLabel.numberOfLines = 0;
    [self.contentView addSubview:_tweeterCommentLabel];
       
    
}

- (void)setTweetLayout
{
    [_tweeterImageView mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.top.equalTo(self.contentView.mas_top).offset(kCellEdgeDistance);
         make.width.and.height.mas_equalTo(kTweeterImageHeight);
         make.left.equalTo(self.contentView.mas_left).offset(kCellEdgeDistance);
     }];
    
    [_tweeterNameLabel mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.top.equalTo(self.contentView.mas_top).offset(kCellEdgeDistance);
         make.left.equalTo(_tweeterImageView.mas_right).offset(kLabelWidthDistance);
         make.height.mas_equalTo(kSmallLabelHeight);
         make.width.mas_equalTo(kTweeterLabelWidth);
         //make.right.equalTo(_tweeterTypeLabel).offset(-kLabelWidthDistance);
     }];
    
    [_tweeterTypeLabel mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.top.equalTo(self.contentView.mas_top).offset(kCellEdgeDistance);
         make.left.equalTo(_tweeterNameLabel.mas_right).offset(kLabelWidthDistance);
         make.height.mas_equalTo(kSmallLabelHeight);
         make.right.equalTo(self.contentView.mas_right).offset(-kCellEdgeDistance);
     }];
    
    [_channelNameLabel mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.left.equalTo(_tweeterImageView.mas_right).offset(kLabelWidthDistance);
         make.top.equalTo(_tweeterNameLabel.mas_bottom).offset(kLabelHeightDistance);
         make.height.mas_equalTo(kMainlabelHeight);
         make.right.equalTo(_channelImageView.mas_left).offset(-kLabelWidthDistance);
     }];
    
    [_channelImageView mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.top.equalTo(_tweeterNameLabel.mas_bottom).offset(kLabelHeightDistance);
         make.height.and.width.mas_equalTo(kMainImageHeight);
         make.right.equalTo(self.contentView.mas_right).offset(-kCellEdgeDistance);
         make.left.equalTo(_channelNameLabel.mas_right).offset(kLabelWidthDistance);
     }];
    
    [_tweetDateLabel mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.left.equalTo(_tweeterImageView.mas_right).offset(kLabelWidthDistance);
         make.top.equalTo(_channelNameLabel.mas_bottom).offset(kLabelHeightDistance);
         make.height.mas_equalTo(kSmallLabelHeight);
         make.right.equalTo(_deleteButton.mas_left).offset(-kLabelWidthDistance);
     }];
    
    [_deleteButton mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.left.equalTo(_tweetDateLabel.mas_right).offset(kLabelWidthDistance);
         make.top.equalTo(_channelNameLabel.mas_bottom).offset(kLabelHeightDistance);
         make.height.mas_equalTo(kSmallLabelHeight);
         make.right.equalTo(_likeButton.mas_left).offset(-kLabelWidthDistance);
     }];
    
    [_likeButton mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.left.equalTo(_deleteButton.mas_right).offset(kLabelWidthDistance);
         make.top.equalTo(_channelNameLabel.mas_bottom).offset(kLabelHeightDistance);
         make.height.and.width.mas_equalTo(kSmallLabelHeight);
         make.right.equalTo(_likeCountLabel.mas_left).offset(-kLabelWidthDistance);
     }];
    
    [_likeCountLabel mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.left.equalTo(_likeButton.mas_right).offset(kLabelWidthDistance);
         make.top.equalTo(_channelNameLabel.mas_bottom).offset(kLabelHeightDistance);
         make.height.mas_equalTo(kSmallLabelHeight);
         make.right.equalTo(self.contentView).offset(-kCellEdgeDistance);
     }];
    
    [_tweeterCommentLabel mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.left.equalTo(_tweeterImageView.mas_right).offset(kLabelWidthDistance);
         make.right.equalTo(self.contentView.mas_right).offset(-kCellEdgeDistance);
         make.top.equalTo(_tweetDateLabel.mas_bottom).offset(kLabelHeightDistance);
         make.bottom.equalTo(self.contentView.mas_bottom).offset(-kCellEdgeDistance);
     }];
    
    
}


- (void)deleteButtonClicked:(UIButton *)sender
{
    if (_deleteTweetCell)
    {
        _deleteTweetCell(_tweetID);
    }
}


- (void)likeButtonClicked:(UIButton *)sender
{
    NSInteger count = [_likeCountLabel.text integerValue];
    if (!_isLike)
    {
        [_likeButton setImage:[UIImage imageNamed:@"赞2"] forState:UIControlStateNormal];
        _isLike = YES;
       
        _likeCountLabel.text = [NSString stringWithFormat:@"%ld",(long)++count];
        
    }
    else
    {
        [_likeButton setImage:[UIImage imageNamed:@"赞1"] forState:UIControlStateNormal];
        _isLike = NO;
        _likeCountLabel.text = [NSString stringWithFormat:@"%ld",(long)--count];
    }
    if (_updateTweetLikeCount)
    {
        _updateTweetLikeCount(_tweetID,_isLike);
    }
}


- (void)channelNameImageClicked
{
    if (_scrollView)
    {
        NSArray *channelName = [_channelNameLabel.text componentsSeparatedByString:@"："];
        _scrollView(0, channelName[1]);
    }
}


//gesture的代理事件需要再UIView类型上来写


@end
