//
//  AppDelegate.h
//  arproject
//
//  Created by 王健 on 16/11/12.
//  Copyright © 2016年 王健. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"
#import "DataParser.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,WXApiDelegate>
{
    UINavigationController * mainNav;
    UINavigationController * topNav;
    UIAlertView * gAlertView;
    
}
@property (retain, nonatomic) UIWindow *window;
@property float screenWidth;
@property float screenHeight;
-(float)getSlipWidth;
-(float)getSlipHeight;
-(UINavigationController*)getTopNav;
-(void)hideTopNav:(BOOL)isAnim;
-(void)showTopNav:(BOOL)isAnim;
-(void)showMsg:(NSString *)msg hiddenTime:(NSTimeInterval)time;
-(void)showAlertOKWithMessage:(NSString *)msg;

-(void)addUser:(NSString*)userId userObj:(UserInfoObj*)dataObj;
-(void)removeUser:(NSString*)userId;
-(UserInfoObj*)getCurUser;
-(void)setCurUser:(UserInfoObj*)dataObj;
@end

