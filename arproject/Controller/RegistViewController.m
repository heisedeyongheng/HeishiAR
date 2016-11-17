//
//  RegistViewController.m
//  arproject
//
//  Created by 王健 on 16/11/12.
//  Copyright © 2016年 王健. All rights reserved.
//

#import "RegistViewController.h"
#import "ISSFileOp.h"
#import "AppDelegate.h"

extern AppDelegate * appDelegate;
@implementation RegistViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}
-(void)dealloc
{
    FREEOBJECT(userNameField);
    FREEOBJECT(userPwdField);
    [super dealloc];
}
-(void)viewDidLoad {
    [super viewDidLoad];
    [self initControls];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initControls
{
    [self setNavBg:self title:@"注册" back:@"" right:nil];
    
    CGFloat horOffset = 40;
    CGFloat contentW = appDelegate.screenWidth - horOffset*2;
    userNameField = [[UITextField alloc] init];
    [userNameField setFrame:CGRectMake(horOffset, 20, contentW, 40)];
    [userNameField setBorderStyle:UITextBorderStyleRoundedRect];
    [userNameField setPlaceholder:@"用户名"];
    [userNameField setFont:[UIFont systemFontOfSize:14]];
    [mainScroll addSubview:userNameField];
    userPwdField = [[UITextField alloc] init];
    [userPwdField setFrame:CGRectMake(horOffset, OBJBOTTOM(userNameField) + 20, contentW, 40)];
    [userPwdField setBorderStyle:UITextBorderStyleRoundedRect];
    [userPwdField setPlaceholder:@"密码"];
    [userPwdField setSecureTextEntry:YES];
    [userPwdField setFont:[UIFont systemFontOfSize:14]];
    [mainScroll addSubview:userPwdField];
    userPwdConfirmField = [[UITextField alloc] init];
    [userPwdConfirmField setFrame:CGRectMake(horOffset, OBJBOTTOM(userPwdField) + 20, contentW, 40)];
    [userPwdConfirmField setBorderStyle:UITextBorderStyleRoundedRect];
    [userPwdConfirmField setPlaceholder:@"确认密码"];
    [userPwdConfirmField setSecureTextEntry:YES];
    [userPwdConfirmField setFont:[UIFont systemFontOfSize:14]];
    [mainScroll addSubview:userPwdConfirmField];
    userNick = [[UITextField alloc] init];
    [userNick setFrame:CGRectMake(horOffset, OBJBOTTOM(userPwdConfirmField) + 20, contentW, 40)];
    [userNick setBorderStyle:UITextBorderStyleRoundedRect];
    [userNick setPlaceholder:@"昵称"];
    [userNick setFont:[UIFont systemFontOfSize:14]];
    [mainScroll addSubview:userNick];
    
    UIButton * regBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [regBtn setFrame:CGRectMake(horOffset, OBJBOTTOM(userNick) + 20, contentW, 40)];
    [regBtn setBackgroundImage:[ISSFileOp getImgByColor:RGBCOLOR(0, 0, 0) size:CGSizeMake(1, 1)] forState:UIControlStateNormal];
    [regBtn setTitle:@"注册" forState:UIControlStateNormal];
    [regBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [regBtn addTarget:self action:@selector(regAction:) forControlEvents:UIControlEventTouchUpInside];
    [mainScroll addSubview:regBtn];
    
    [mainScroll setIsCloseKeyboardWhenTouch:YES];
    [mainScroll relayoutContentSize];
}
-(void)backAction:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)regAction:(UIButton*)btn
{
    NSString * errMsg = nil;
    NSString * userName = userNameField.text;
    NSString * userPwd = userPwdField.text;
    NSString * userPwdConfirm = userPwdConfirmField.text;
    if(STRNULL(userName).length == 0)errMsg = @"请输入用户名";
    if(STRNULL(userPwd).length == 0)errMsg = @"请输入密码";
    if([STRNULL(userPwd) isEqualToString:userPwdConfirm] == NO)errMsg = @"两次密码不一致";
    if(errMsg != nil){
        [appDelegate showAlertOKWithMessage:errMsg];
        return;
    }
    SZMGConnect * con = [[SZMGConnect alloc] init];
    [con setDatadelegate:self];
    [con httpRegist:userName pwd:userPwd];
    [con release];
}
#pragma mark -- network
-(void)onFinish:(NSData *)data url:(NSString *)url
{
    DEBUG_NSLOG(@"%s",__FUNCTION__);
    UserInfoObj * dataObj = [DataParser parseUserInfo:data];
    if(dataObj != nil && dataObj.ErrorCode == 200){
        [appDelegate addUser:dataObj.userId userObj:dataObj];
        [appDelegate setCurUser:dataObj];
        [appDelegate showMsg:@"注册成功" hiddenTime:2];
        [self performSelector:@selector(backAction:) withObject:nil afterDelay:0.2];
    }
    else{
        if(STRNULL(dataObj.ErrorMsg).length > 0){
            [appDelegate showMsg:dataObj.ErrorMsg hiddenTime:2];
        }
    }
}
-(void)onNetError:(ErrorObject *)error
{
    
}
@end
