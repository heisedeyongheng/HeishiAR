//
//  LoginViewController.m
//  arproject
//
//  Created by 王健 on 16/11/14.
//  Copyright © 2016年 王健. All rights reserved.
//

#import "LoginViewController.h"
#import "ISSFileOp.h"
#import "AppDelegate.h"

extern AppDelegate * appDelegate;
@implementation LoginViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}
-(void)dealloc
{
    DEBUG_NSLOG(@"%s",__FUNCTION__);
    [self unInitLoginNotify];
    FREEOBJECT(userNameField);
    FREEOBJECT(userPwdField);
    [super dealloc];
}
-(void)viewDidLoad {
    [super viewDidLoad];
    [self initControls];
    [self initLoginNotify];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)initControls
{
    [self setNavBg:self title:@"登录" back:@"" right:nil];
    CGFloat horOffset = 40;
    CGFloat contentW = appDelegate.screenWidth - horOffset*2;
    userNameField = [[UITextField alloc] init];
    [userNameField setFrame:CGRectMake(horOffset, 20, contentW, 40)];
    [userNameField setBorderStyle:UITextBorderStyleRoundedRect];
    [userNameField setPlaceholder:@"用户名"];
    [userNameField setFont:[UIFont systemFontOfSize:14]];
    [self.view addSubview:userNameField];
    userPwdField = [[UITextField alloc] init];
    [userPwdField setFrame:CGRectMake(horOffset, OBJBOTTOM(userNameField) + 20, contentW, 40)];
    [userPwdField setBorderStyle:UITextBorderStyleRoundedRect];
    [userPwdField setPlaceholder:@"密码"];
    [userPwdField setSecureTextEntry:YES];
    [userPwdField setFont:[UIFont systemFontOfSize:14]];
    [self.view addSubview:userPwdField];
    UIButton * loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginBtn setFrame:CGRectMake(horOffset, OBJBOTTOM(userPwdField) + 20, contentW, 40)];
    [loginBtn setBackgroundImage:[ISSFileOp getImgByColor:RGBCOLOR(0, 0, 0) size:CGSizeMake(1, 1)] forState:UIControlStateNormal];
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(loginAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];
    
    UIButton * weixinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [weixinBtn setFrame:CGRectMake(appDelegate.screenWidth/2 - 20, OBJBOTTOM(loginBtn) + 20, 40, 40)];
    [weixinBtn setImage:[UIImage imageNamed:@"weixin"] forState:UIControlStateNormal];
    [weixinBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [weixinBtn addTarget:self action:@selector(weiXinLoginAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:weixinBtn];
}
#pragma mark --- 初始化这个页面所需通知
-(void)initLoginNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWxLogin:) name:[LoginViewController wxLoginOkNotifyKey] object:nil];
}
-(void)unInitLoginNotify
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[LoginViewController wxLoginOkNotifyKey] object:nil];
}
+(NSString*)wxLoginOkNotifyKey
{
    return @"wxloginok";
}
#pragma mark -- action
-(void)backAction:(UIButton *)btn
{
    [self.navigationController popToRootViewControllerAnimated:NO];
    [appDelegate hideTopNav:YES];
}
-(void)loginAction:(UIButton*)btn
{
    NSString * errMsg = nil;
    NSString * userName = userNameField.text;
    NSString * userPwd = userPwdField.text;
    if(STRNULL(userName).length == 0)errMsg = @"请输入用户名";
    if(STRNULL(userPwd).length == 0)errMsg = @"请输入密码";
    if(errMsg != nil){
        [appDelegate showAlertOKWithMessage:errMsg];
        return;
    }
    SZMGConnect * con = [[SZMGConnect alloc] init];
    [con setDatadelegate:self];
    [con httpLogin:userName pwd:userPwd weixinid:@""];
    [con release];
}
#pragma mark - wei xin 登录
-(void)weiXinLoginAction:(UIButton*)btn
{
    if ([WXApi isWXAppSupportApi] && [WXApi isWXAppSupportApi]){
        [self sendAuthRequest];
    }
}

//发送请求 登录
-(void)sendAuthRequest
{
    //构造SendAuthReq结构体
    SendAuthReq* req =[[[SendAuthReq alloc] init] autorelease];
    req.scope = @"snsapi_userinfo" ;
    req.state = [[NSBundle mainBundle] bundleIdentifier];
    //第三方向微信终端发送一个SendAuthReq消息结构
    [WXApi sendReq:req];    
    [WXApi sendAuthReq:req viewController:self delegate:appDelegate];
}

-(void)onWxLogin:(id)obj
{
    if([obj isKindOfClass:[NSNotification class]])
    {
        NSNotification * notify = (NSNotification*)obj;
        NSDictionary * dict = (NSDictionary*)notify.object;
//        FREEOBJECT(thirdUserKey);
//        FREEOBJECT(thirdUserNick);
//        FREEOBJECT(thirdUserFace);
//        thirdUserNick = [[dict valueForKey:WXNICK_KEY] copy];
//        thirdUserFace = [[dict valueForKey:WXFACE_KEY] copy];
//        thirdUserKey = [[dict valueForKey:WXUNIONID_KEY] copy];
//        NSString * wxOpenId = [dict valueForKey:WXOPENID_KEY];
//        if(thirdUserKey == nil || thirdUserKey.length == 0)
//        {
//            [appDelegate showMsg:@"微信登录失败" hiddenTime:2];
//            return;
//        }
//        
//        //        [self loginWithKey:thirdUserKey thirdUserNick:thirdUserNick type:2 faceUrl:@""];//第三方登录成功，向本系统注册
//        [self loginWithKey:thirdUserKey thirdUserNick:thirdUserNick type:2 faceUrl:@"" wxOpenId:wxOpenId wxUnionId:thirdUserKey];
    }
}
#pragma mark -- network
-(void)onFinish:(NSData *)data url:(NSString *)url
{
    DEBUG_NSLOG(@"%s",__FUNCTION__);
    UserInfoObj * dataObj = [DataParser parseUserInfo:data];
    if(dataObj != nil && dataObj.ErrorCode == 200){
        [appDelegate addUser:dataObj.userId userObj:dataObj];
        [appDelegate setCurUser:dataObj];
        [appDelegate showMsg:@"登录成功" hiddenTime:2];
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
