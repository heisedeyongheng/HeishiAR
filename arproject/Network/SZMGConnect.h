//
//  SZMGConnect.h
//  Ubunta
//
//  Created by 王健 on 13-8-13.
//  Copyright (c) 2013年 wj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import<CommonCrypto/CommonDigest.h>
#import "MBProgressHUD.h"
#import "ProcessImageView.h"
#import "DataParser.h"


#define NETTIME         20//网络超时
//网络回调接口
@protocol SZMGConnectDelegate <NSObject>
@optional//可以不实现
-(void)onFinish:(NSData*)data url:(NSString*)url;
-(void)onCancel;
-(void)onNetError:(ErrorObject*)error;
@end

@interface SZMGConnect : NSObject<NSURLConnectionDelegate>
{
    //URL
	NSString*			connectionUrl;
    //连接对象
    NSURLConnection*    netConnection;
    //数据对象
    NSMutableData*      netData;
    NSString *          postStr;
    Boolean isPost;
    id<SZMGConnectDelegate> datadelegate;
    
    MBProgressHUD * waitProcess;
    ProcessImageView * processBar;
    long long totalLen;
    UIButton * cancelBtn;
    BOOL isLock;
}
@property(retain) id<SZMGConnectDelegate> datadelegate;
-(id)init;
-(id)initWithProcessBar:(UIView*)parentView;
-(id)initWithIndicator:(UIView *)parentView;
-(id)initWithHUD:(UIView*)parentView hudTitle:(NSString*)title;
-(void)httpLogin:(NSString*)username pwd:(NSString*)pwd weixinid:(NSString*)weixinid;
-(void)httpRegist:(NSString*)username pwd:(NSString*)pwd;
@end



@interface NSString (Base64Addition)
+(NSString *)stringFromBase64String:(NSString *)base64String;
-(NSString *)base64String;
-(NSString *)md5String;
@end
@interface NSData (Base64Addition)
+(NSData *)dataWithBase64String:(NSString *)base64String;
-(NSString *)base64String;
@end
@interface MF_Base64Codec : NSObject
+(NSData *)dataFromBase64String:(NSString *)base64String;
+(NSString *)base64StringFromData:(NSData *)data;
@end
