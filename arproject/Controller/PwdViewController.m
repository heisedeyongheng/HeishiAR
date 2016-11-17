//
//  PwdViewController.m
//  arproject
//
//  Created by 王健 on 16/11/17.
//  Copyright © 2016年 王健. All rights reserved.
//

#import "PwdViewController.h"
#import "ISSFileOp.h"
#import "AppDelegate.h"

extern AppDelegate * appDelegate;
@implementation PwdViewController
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}
-(void)dealloc
{
    DEBUG_NSLOG(@"%s",__FUNCTION__);
    FREEOBJECT(curPwd);
    FREEOBJECT(newPwd);
    FREEOBJECT(confirmPwd);
    [super dealloc];
}
- (void)viewDidLoad {
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
    [self setNavBg:self title:@"修改密码" back:@"" right:@""];
    
    [mainScroll setBackgroundColor:RGBACOLOR(230, 230, 230, 1)];
    [mainScroll setIsCloseKeyboardWhenTouch:YES];
    
    CGFloat horOffset = 20;
    UIView * curView = [[UIView alloc] init];
    [curView setFrame:CGRectMake(0, 0, appDelegate.screenWidth, 40)];
    [curView setBackgroundColor:[UIColor whiteColor]];
    [mainScroll addSubview:curView];
    [curView release];
    curPwd = [[UITextField alloc] init];
    [curPwd setFrame:CGRectMake(horOffset, 0, appDelegate.screenWidth - horOffset*2, curView.frame.size.height)];
    [curPwd setSecureTextEntry:YES];
    [curPwd setPlaceholder:@"当前密码"];
    [curView addSubview:curPwd];
    
    UIView * pwdView = [[UIView alloc] init];
    [pwdView setFrame:CGRectMake(0, OBJBOTTOM(curView) + 20, appDelegate.screenWidth, 40)];
    [pwdView setBackgroundColor:[UIColor whiteColor]];
    [mainScroll addSubview:pwdView];
    [pwdView release];
    newPwd = [[UITextField alloc] init];
    [newPwd setFrame:CGRectMake(horOffset, 0, appDelegate.screenWidth - horOffset*2, pwdView.frame.size.height)];
    [newPwd setSecureTextEntry:YES];
    [newPwd setPlaceholder:@"新密码"];
    [pwdView addSubview:newPwd];
    
    UIView * confirmView = [[UIView alloc] init];
    [confirmView setFrame:CGRectMake(0, OBJBOTTOM(pwdView) + 20, appDelegate.screenWidth, 40)];
    [confirmView setBackgroundColor:[UIColor whiteColor]];
    [mainScroll addSubview:confirmView];
    [confirmView release];
    confirmPwd = [[UITextField alloc] init];
    [confirmPwd setFrame:CGRectMake(horOffset, 0, appDelegate.screenWidth - horOffset*2, confirmView.frame.size.height)];
    [confirmPwd setSecureTextEntry:YES];
    [confirmPwd setPlaceholder:@"确认新密码"];
    [confirmView addSubview:confirmPwd];
    
    
    UIButton * sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [sureBtn setFrame:CGRectMake(horOffset, OBJBOTTOM(confirmView) + 20, appDelegate.screenWidth - horOffset*2, 40)];
    [sureBtn setBackgroundImage:[ISSFileOp getImgByColor:GREEN_BTN_COLOR size:CGSizeMake(1, 1)] forState:UIControlStateNormal];
    [sureBtn setTitle:@"保存" forState:UIControlStateNormal];
    [sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(sureAction:) forControlEvents:UIControlEventTouchUpInside];
    [mainScroll addSubview:sureBtn];
}

-(void)sureAction:(UIButton*)btn
{
    NSString * oldPwdStr = curPwd.text;
    NSString * newPwdStr = newPwd.text;
    NSString * confirmPwdStr = confirmPwd.text;
    NSString * errMsg = nil;
    if(STRNULL(oldPwdStr).length == 0)errMsg=@"请输入当前密码";
    if(STRNULL(newPwdStr).length == 0)errMsg=@"请输入新密码";
    if([STRNULL(confirmPwdStr) isEqualToString:confirmPwdStr] == NO)errMsg=@"两次新密码不一致";
    if(errMsg != nil){
        [appDelegate showMsg:errMsg hiddenTime:2];
        return;
    }
    
    UserInfoObj * infoObj = [appDelegate getCurUser];
    SZMGConnect * con = [[SZMGConnect alloc] init];
    [con setDatadelegate:self];
    [con httpModifyUserInfo:infoObj.userId nick:nil head:nil pwd:newPwdStr oldpwd:oldPwdStr];
}

#pragma mark -- network
-(void)onFinish:(NSData *)data url:(NSString *)url
{
    DEBUG_NSLOG(@"%s",__FUNCTION__);
    UserInfoObj * dataObj = [DataParser parseUserInfo:data];
    if(dataObj != nil && dataObj.ErrorCode == 200){
        [appDelegate addUser:dataObj.userId userObj:dataObj];
        [appDelegate setCurUser:dataObj];
        [appDelegate showMsg:@"保存成功" hiddenTime:2];
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
