//
//  AppDelegate.m
//  arproject
//
//  Created by 王健 on 16/11/12.
//  Copyright © 2016年 王健. All rights reserved.
//

#import "AppDelegate.h"
#import "Def.h"
#import "CamViewController.h"
#import "MainViewController.h"
#import "LoginViewController.h"

AppDelegate * appDelegate;//全局访问对象

@implementation AppDelegate
@synthesize screenWidth,screenHeight;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    appDelegate = (AppDelegate*)self;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.screenWidth = [[UIScreen mainScreen] bounds].size.width;
    self.screenHeight = [[UIScreen mainScreen] bounds].size.height;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
    
    //主操作界面nav
    MainViewController * main = [[MainViewController alloc] initWithNibName:nil bundle:nil];
    mainNav = [[UINavigationController alloc] initWithRootViewController:main];
    self.window.rootViewController = mainNav;
    [main release];
    
    topNav = [[UINavigationController alloc] initWithNibName:nil bundle:nil];
    [self.window addSubview:topNav.view];
    [self hideTopNav:NO];
    
    [self initWechat];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark -- 自定义function
-(float)getSlipHeight
{
    return appDelegate.screenHeight*(1);
}
-(float)getSlipWidth
{
    return appDelegate.screenWidth*(1-R_W);
}
-(UINavigationController*)getTopNav
{
    return topNav;
}
-(void)hideTopNav:(BOOL)isAnim
{
    [UIView animateWithDuration:(isAnim ? 0.3 : 0) animations:^(){
        [topNav.view setCenter:CGPointMake(screenWidth*1.5, topNav.view.center.y)];
    } completion:^(BOOL isFinished){}];
}
-(void)showTopNav:(BOOL)isAnim
{
    [UIView animateWithDuration:(isAnim ? 0.3 : 0) animations:^(){
        [topNav.view setCenter:CGPointMake(screenWidth*0.5, topNav.view.center.y)];
    } completion:^(BOOL isFinished){}];
}
#pragma mark --- 用户数据
-(void)addUser:(NSString*)userId userObj:(UserInfoObj*)dataObj
{
    if(STRNULL(dataObj.userId).length == 0)return;
    NSString * infoPath = [ISSFileOp ReturnDocumentPath];
    NSString * listPath = [NSString stringWithFormat:@"%@/userlist.plist",infoPath];
    NSMutableDictionary * userList = nil;
    if([[NSFileManager defaultManager] fileExistsAtPath:listPath]){
        userList = [NSMutableDictionary dictionaryWithContentsOfFile:listPath];
    }
    else{
        userList = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    [userList setValue:dataObj.userId forKey:dataObj.userId];
    [userList writeToFile:listPath atomically:YES];
    //详情
    NSString * detailPath = [NSString stringWithFormat:@"%@/%@.plist",infoPath,dataObj.userId];
    NSMutableDictionary * detailDict = [NSMutableDictionary dictionaryWithCapacity:1];
    [detailPath setValue:[dataObj toJson] forKey:@"jsonStr"];
    [detailDict writeToFile:detailPath atomically:YES];
}
-(void)removeUser:(NSString*)userId
{
    
}
-(void)getUserList
{
    NSString * infoPath = [ISSFileOp ReturnDocumentPath];
    infoPath = [NSString stringWithFormat:@"%@/userlist.plist",infoPath];
    NSMutableDictionary * userList = nil;
    if([[NSFileManager defaultManager] fileExistsAtPath:infoPath]){
        userList = [NSMutableDictionary dictionaryWithContentsOfFile:infoPath];
    }
    else{
        DEBUG_NSLOG(@"userlist为空");
    }
}


#pragma mark - message View
-(void)showMsg:(NSString *)msg hiddenTime:(NSTimeInterval)time
{
    //add by wj msg 为nil或@""不显示
    if(msg == nil || msg.length == 0 || [msg rangeOfString:@"登录超时"].location != NSNotFound)return;
    

    if([gAlertView.message isEqualToString:msg])return;
    
    [self dismissAlertView];
    
    
    
    gAlertView = [[UIAlertView alloc] initWithTitle:@""
                                            message:msg
                                           delegate:nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:nil, nil];
    [gAlertView show];
    [self performSelector:@selector(dismissAlertView) withObject:nil afterDelay:time];
}

-(void)showAlertOKWithMessage:(NSString *)msg
{
    //add by wj msg 为nil或@""不显示
    if(msg == nil || msg.length == 0 || [msg rangeOfString:@"登录超时"].location != NSNotFound)return;
    
    if (gAlertView) {
        [gAlertView dismissWithClickedButtonIndex:0 animated:NO];
        [gAlertView release];
        gAlertView = nil;
    }
    
    
    
    gAlertView = [[UIAlertView alloc] initWithTitle:@""
                                            message:msg
                                           delegate:nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"确定", nil];
    [gAlertView show];
    
}
-(void)dismissAlertView{
    if (gAlertView) {
        [gAlertView dismissWithClickedButtonIndex:0 animated:NO];
        [gAlertView release];
        gAlertView = nil;
    }
}


#pragma mark - handleOpenURL
- (BOOL)application:(UIApplication *)application  handleOpenURL:(NSURL *)url{
    return [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
        return [WXApi handleOpenURL:url delegate:self];
}
//wechat
-(void)initWechat
{
    //向微信注册
    [WXApi registerApp:WeiXinChatAppID];
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
                    NSDictionary * dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:aUserInfoData.unionid,aUserInfoData.openid,aUserInfoData.nickname,aUserInfoData.headimgurl, nil] forKeys:[NSArray arrayWithObjects:WXUNIONID_KEY,WXOPENID_KEY,WXNICK_KEY,WXFACE_KEY, nil]];
                    [[NSNotificationCenter defaultCenter] postNotificationName:[LoginViewController wxLoginOkNotifyKey] object:dict];
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
@end
