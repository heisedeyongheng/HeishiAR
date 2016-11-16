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
    [WXApi sendAuthReq:req viewController:self delegate:self];
}

-(void)onWxLogin:(WeiXinUserInfo*)obj
{
    if([obj isKindOfClass:[NSNotification class]])
    {
//        FREEOBJECT(thirdUserKey);
//        FREEOBJECT(thirdUserNick);
//        FREEOBJECT(thirdUserFace);
//        thirdUserNick = [[dict valueForKey:WXNICK_KEY] copy];
//        thirdUserFace = [[dict valueForKey:WXFACE_KEY] copy];
//        thirdUserKey = [[dict valueForKey:WXOPENID_KEY] copy];
//        if(thirdUserKey == nil || thirdUserKey.length == 0)
//        {
//            [appDelegate showMsg:@"微信登录失败" hiddenTime:2];
//            return;
//        }
//        
//        [self loginWithKey:thirdUserKey thirdUserNick:thirdUserNick type:2 faceUrl:thirdUserFace];//第三方登录成功，向本系统注册
    }
}
#pragma mark - 微信 and QQ QQApiInterface Delegate
-(void)onReq:(id)req
{
    
}

-(void)onResp:(id)resp
{
    //-----------微信授权
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp *reponse = (SendAuthResp *) resp;
        if ([reponse.state isEqualToString:[[NSBundle mainBundle] bundleIdentifier]]) {
            NSString *urlString = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",WeiXinChatAppID,WeiXinChatAppKey,reponse.code];
            NSString * strReturn = [self requestWeiXinWithURL:urlString];
            
            DEBUG_NSLOG(@" Weixin access_token result =======>>>>>> %@",strReturn);
            id tmpWXData = [DataParser parseWeiXinAccessToken:strReturn];
            if ([tmpWXData isKindOfClass:[WeiXinAccessToken class]]) {
                
                //-----------获取用户个人信息
                WeiXinAccessToken *aWXData = (WeiXinAccessToken *)tmpWXData;
                NSString *urlForUserInfoString = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",aWXData.accessToken, aWXData.openid];
                NSString *strUserInfoReturn = [self requestWeiXinWithURL:urlForUserInfoString];
                id tmpWXUserInfoData = [DataParser parseWeiXinUserInfo:strUserInfoReturn];
                
                if ([tmpWXUserInfoData isKindOfClass:[WeiXinUserInfo class]]){
                    WeiXinUserInfo *aUserInfoData = (WeiXinUserInfo *)tmpWXUserInfoData;
                    DEBUG_NSLOG(@"unionid  =====>>>  %@",aUserInfoData.unionid);
                    DEBUG_NSLOG(@"nickname  =====>>>  %@",aUserInfoData.nickname);
                    DEBUG_NSLOG(@"headimgurl  =====>>>  %@",aUserInfoData.headimgurl);
                    [self onWxLogin:aUserInfoData];
                }
            }
        }
    }
    //-------------- 分享成功
    else if ([resp isKindOfClass:[BaseResp class]])
    {
        BaseResp *reponse = (BaseResp *) resp;
        DEBUG_NSLOG(@"微信  %s----%d   type  == %d",__FUNCTION__,reponse.errCode , reponse.type);
        if (reponse.errCode == WXSuccess) {
            if (reponse.type == WXSceneSession) {
                
            }
            else if (reponse.type == WXSceneTimeline){
                
            }
        }
    }
}

-(NSString *)requestWeiXinWithURL:(NSString *)aUrlString
{
    NSString *urlString = [aUrlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    DEBUG_NSLOG(@" Weixin access_token  =======>>>>>> %@",urlString);
    // 实例化NSMutableURLRequest，并进行参数配置
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    [request setURL:[NSURL URLWithString: urlString]];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setTimeoutInterval: 60];
    [request setHTTPShouldHandleCookies:FALSE];
    [request setHTTPMethod:@"GET"];
    
    // Response对象，用来得到返回后的数据，比如，用statusCode==200 来判断返回正常
    NSHTTPURLResponse *response;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request
                                               returningResponse:&response error:nil];
    // 处理返回的数据
    NSString *strReturn = [[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding] autorelease];
    return strReturn;
}

#pragma mark -- network
-(void)onFinish:(NSData *)data url:(NSString *)url
{
    DEBUG_NSLOG(@"%s",__FUNCTION__);
}
-(void)onNetError:(ErrorObject *)error
{

}
@end
