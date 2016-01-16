//
//  SharedViewController.m
//  FunMusic
//
//  Created by frankie on 16/1/5.
//  Copyright © 2016年 Wang Bo. All rights reserved.
//

#import "SharedViewController.h"
#import "FunServer.h"
#import "TweetInfo.h"
#import "PlayerInfo.h"
#import "ChannelInfo.h"
#import "AppDelegate.h"
#import "UIColor+Util.h"
#import <Masonry.h>

static const NSInteger kMaxWordCount         = 140;
static const CGFloat kTextViewBorderWidth    = 1.0;
static const CGFloat kTextViewCornerRadius   = 5.0;
static const CGFloat kChannelNameFont        = 18;
static const CGFloat kTextWordFont           = 16;

static const CGFloat kInputTextViewHeight    = 130;
static const CGFloat kPlaceHolderHeight      = 30;
static const CGFloat kPlaceHolderWidth       = 80;
static const CGFloat kResidueLabelHeight     = 30;
static const CGFloat kResidueLabelWidth      = 70;
static const CGFloat kChannelNameLabelHeight = 60;
static const CGFloat kChannelImageHeight     = 60;

static const CGFloat kInnerEdgeDistance      = 5;
static const CGFloat kOuterEdgeDistance      = 20;
static const CGFloat kLabelHeightDistance    = 20;
static const CGFloat kLabelWidthDistance     = 10;


@interface SharedViewController ()<UITextViewDelegate>
{
    AppDelegate *appDelegate;
    FunServer *funServer;
    TweetInfo *sharedTweetInfo;
    ChannelInfo *currentChannel;
}

@property (nonatomic, strong) UITextView *inputTextView;
@property (nonatomic, strong) UILabel *placeHolderLabel;
@property (nonatomic, strong) UILabel *residueLabel;//输入文本时显示剩余字数
@property (nonatomic, strong) UILabel *channelNameLabel;
@property (nonatomic, strong) UIImageView *channelImageView;

@end

@implementation SharedViewController


- (instancetype)init
{
    self = [super init];
    if (self)
    {
        //获取当前频道信息
        appDelegate = [[UIApplication sharedApplication] delegate];
        currentChannel = appDelegate.currentPlayerInfo.currentChannel;
        funServer = [[FunServer alloc] init];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定"
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(sureButtonClicked)];
    }
    
    return self;
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpUI];
    [self setUpLayOut];
}


- (void)setUpUI
{
    //self
    self.view.backgroundColor = [UIColor themeColor];
    
    //inPutTextView
    _inputTextView = [[UITextView alloc] init];
    _inputTextView.backgroundColor = [UIColor inputColor];
    _inputTextView.textColor = [UIColor standerTextColor];
    _inputTextView.editable = YES;
    _inputTextView.scrollEnabled = YES;
    //使用代理的时候记得设置代理！！！！费死劲了！
    _inputTextView.delegate = self;
    _inputTextView.font = [UIFont systemFontOfSize:kTextWordFont];
    _inputTextView.layer.borderWidth = kTextViewBorderWidth;
    _inputTextView.layer.cornerRadius = kTextViewCornerRadius;
    _inputTextView.layer.borderColor = UIColor.grayColor.CGColor;
    _inputTextView.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:_inputTextView];
    
    //placeHolderLabel
    _placeHolderLabel = [[UILabel alloc] init];
    _placeHolderLabel.font = [UIFont systemFontOfSize:kTextWordFont];
    _placeHolderLabel.numberOfLines = 0;
    _placeHolderLabel.text = @"说点什么";
    _placeHolderLabel.backgroundColor = [UIColor clearColor];
    _placeHolderLabel.textColor = [UIColor standerGreyTextColor];
    [self.view addSubview:_placeHolderLabel];
    
    //residueLabel
    _residueLabel = [[UILabel alloc] init];
    _residueLabel.backgroundColor = [UIColor clearColor];
    _residueLabel.font = [UIFont systemFontOfSize:kTextWordFont];
    _residueLabel.text = [NSString stringWithFormat:@"%ld/%ld",(long)kMaxWordCount,(long)kMaxWordCount];
    _residueLabel.textColor = [UIColor standerGreyTextColor];
    [self.view addSubview:_residueLabel];
    
    //ChannelNameLabel
    _channelNameLabel = [[UILabel alloc] init];
    _channelNameLabel.textColor = [UIColor standerTextColor];
    _channelNameLabel.font = [UIFont systemFontOfSize:kChannelNameFont];
    _channelNameLabel.backgroundColor = [UIColor standerTextBackGroudColor];
    _channelNameLabel.text = [NSString stringWithFormat:@"    频道 ：%@",currentChannel.channelName];
    [self.view addSubview:_channelNameLabel];
    
    
    //ChannelImageView
    _channelImageView = [[UIImageView alloc] init];
    _channelImageView.layer.cornerRadius = kChannelImageHeight / 2;
    [_channelImageView setImage:[UIImage imageNamed:currentChannel.channelImage]];
    [self.view addSubview:_channelImageView];
    
}

- (void)setUpLayOut
{
    [_inputTextView mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.top.equalTo(self.view.mas_top).offset(kOuterEdgeDistance);
        make.left.equalTo(self.view.mas_left).offset(kOuterEdgeDistance);
        make.right.equalTo(self.view.mas_right).offset(-kOuterEdgeDistance);
        make.height.mas_equalTo(kInputTextViewHeight);
    }];
    
    [_placeHolderLabel mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.top.equalTo(_inputTextView.mas_top).offset(kInnerEdgeDistance);
        make.left.equalTo(_inputTextView.mas_left).offset(kInnerEdgeDistance);
        make.height.mas_equalTo(kPlaceHolderHeight);
        make.width.mas_equalTo(kPlaceHolderWidth);
    }];
    
    [_residueLabel mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.bottom.equalTo(_inputTextView.mas_bottom).offset(-kInnerEdgeDistance);
        make.right.equalTo(_inputTextView.mas_right).offset(-kInnerEdgeDistance);
        make.height.mas_equalTo(kResidueLabelHeight);
        make.width.mas_equalTo(kResidueLabelWidth);
    }];
    
    [_channelNameLabel mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.top.equalTo(_inputTextView.mas_bottom).offset(kLabelHeightDistance);
        make.left.equalTo(self.view.mas_left).offset(kOuterEdgeDistance);
        make.right.equalTo(_channelImageView.mas_left).offset(-kLabelWidthDistance);
        make.height.mas_equalTo(kChannelNameLabelHeight);
    }];
    
    [_channelImageView mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.top.equalTo(_inputTextView.mas_bottom).offset(kLabelHeightDistance);
        make.left.equalTo(_channelNameLabel.mas_right).offset(kLabelWidthDistance);
        make.right.equalTo(self.view.mas_right).offset(-kOuterEdgeDistance);
        make.height.and.width.mas_equalTo(kChannelImageHeight);
    }];
}


#pragma TextView Delegate

- (void)textViewDidChange:(UITextView *)textView
{
    if ([_inputTextView.text length] == 0)
    {
        _placeHolderLabel.text = @"说点什么";
    }
    else
    {
        _placeHolderLabel.text = @"";
    }
    
    //计算剩余字数
    NSString *textContent = textView.text;
    NSInteger existTextNum = [textContent length];
    NSInteger remainTextNum = kMaxWordCount - existTextNum;
    _residueLabel.text = [NSString stringWithFormat:@"%ld/%ld",(long)remainTextNum,(long)kMaxWordCount];
}

//超出MaxWordCount字字数设置不可输入
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])//这里的“\n"对应的是键盘的retrun回收键盘用
    {
        [_inputTextView resignFirstResponder];
        return YES;
    }
    BOOL flag;
    (range.location >= kMaxWordCount) ? (flag = NO) : (flag = YES);
    return  flag;
}

- (void)sureButtonClicked
{
    sharedTweetInfo = [[TweetInfo alloc] initWithTweeterCommentByLocal:_inputTextView.text Local:appDelegate];
    [funServer fmSharedTweeterWithTweetInfo:sharedTweetInfo];
    [funServer fmUpdateMySharedChannelListWithChannelName:sharedTweetInfo.channelName];
    [self.navigationController popViewControllerAnimated:NO];
    if (_presidentView)
    {
        _presidentView(funViewTypeTweeter);
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
