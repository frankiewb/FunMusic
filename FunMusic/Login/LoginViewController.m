//
//  LoginViewController.m
//  FunMusic
//
//  Created by frankie on 16/1/7.
//  Copyright © 2016年 Wang Bo. All rights reserved.
//

#import "LoginViewController.h"
#import "LogInfo.h"
#import "FunServer.h"
#import <Masonry.h>


static const CGFloat kTextFont             = 18;

static const CGFloat kTextFielTop          = 20;
static const CGFloat kTextFieldHeight      = 30;
static const CGFloat kEdgeDistance         = 20;
static const CGFloat kButtonHeight         = 30;
static const CGFloat kTextHeightDistance   = 10;
static const CGFloat kButtonHeightDistance = 20;

@interface LoginViewController ()<UITextFieldDelegate>
{
    LogInfo *currentLogInfo;
    FunServer *funServer;
}

@property (nonatomic, strong) UITextField *loginNameTextField;
@property (nonatomic, strong) UITextField *loginPassWordTextField;
@property (nonatomic, strong) UIButton *loginButton;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"登陆";
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUpLoginUI];
    [self setLoginLayOut];

}


- (void)setUpLoginUI
{
    NSMutableArray *UIList = [[NSMutableArray alloc] init];
    
    //loginNameTextField
    _loginNameTextField = [[UITextField alloc] init];
    _loginNameTextField.placeholder = @"邮箱 ／ 用户名";
    [UIList addObject:_loginNameTextField];
    
    
    //loginPasswordTextField
    _loginPassWordTextField = [[UITextField alloc] init];
    _loginPassWordTextField.placeholder = @"密码";
    [UIList addObject:_loginPassWordTextField];
    
    
    //Atrribute Setting
    
    for (UITextField *loginTextField in UIList)
    {
        loginTextField.borderStyle = UITextBorderStyleRoundedRect;
        loginTextField.textAlignment = NSTextAlignmentLeft;
        loginTextField.font = [UIFont systemFontOfSize:kTextFont];
        //设置输入框右侧一次性清除小叉按钮
        loginTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        //是否启用自动纠错
        loginTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        //设置再次编辑时输入框是否为空
        loginTextField.clearsOnBeginEditing = NO;
        //设置内容垂直对齐方式
        loginTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        //设置内容自适应输入框大小
        loginTextField.adjustsFontSizeToFitWidth = YES;
        //设置键盘样式
        loginTextField.keyboardType = UIKeyboardTypeEmailAddress;
        //设置首字母是否大写
        loginTextField.autocapitalizationType = UITextBorderStyleNone;
        //设置Return键盘字样
        loginTextField.returnKeyType = UIReturnKeyDone;
        //设置键盘外观
        loginTextField.keyboardAppearance = UIKeyboardAppearanceAlert;
        [self.view addSubview:loginTextField];
    }
        
    //loginButton
    _loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _loginButton.backgroundColor = [UIColor orangeColor];
    _loginButton.layer.cornerRadius = 6;
    [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_loginButton setTitle:@"登陆" forState:UIControlStateNormal];
    [_loginButton.titleLabel setFont:[UIFont systemFontOfSize:kTextFont]];
    [_loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_loginButton];
}

- (void)setLoginLayOut
{
    
    [_loginNameTextField mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.top.equalTo(self.view.mas_top).offset(kTextFielTop);
        make.left.equalTo(self.view.mas_left).offset(kEdgeDistance);
        make.right.equalTo(self.view.mas_right).offset(-kEdgeDistance);
        make.height.mas_equalTo(kTextFieldHeight);
    }];
    
    [_loginPassWordTextField mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.top.equalTo(_loginNameTextField.mas_bottom).offset(kTextHeightDistance);
        make.left.equalTo(self.view.mas_left).offset(kEdgeDistance);
        make.right.equalTo(self.view.mas_right).offset(-kEdgeDistance);
        make.height.mas_equalTo(kTextFieldHeight);

    }];
    
    [_loginButton mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.top.equalTo(_loginPassWordTextField.mas_bottom).offset(kButtonHeightDistance);
        make.left.equalTo(self.view.mas_left).offset(kEdgeDistance);
        make.right.equalTo(self.view.mas_right).offset(-kEdgeDistance);
        make.height.mas_equalTo(kButtonHeight);
    }];

}


- (void)login
{
    LogInfo *logInfo = [[LogInfo alloc] init];
    logInfo.loginName = _loginNameTextField.text;
    logInfo.passWord = _loginPassWordTextField.text;
    funServer = [[FunServer alloc] init];
    if ([funServer fmLoginInLocalWithLoginInfo:logInfo])
    {
        if (_refreshUserView)
        {
            _refreshUserView();
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"登录失败"
                                                                                 message:@"请检查您的用户名和密码是否正确"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action)
                                   {
                                       _loginNameTextField.text = @"";
                                       _loginPassWordTextField.text = @"";
                                   }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];

    }
    
}



- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_loginNameTextField resignFirstResponder];
    [_loginPassWordTextField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
