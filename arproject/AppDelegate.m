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
@end
