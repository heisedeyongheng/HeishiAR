//
//  DataParser.h
//  Ubunta
//
//  Created by 王健 on 13-8-13.
//  Copyright (c) 2013年 wj. All rights reserved.
//

#import <Foundation/Foundation.h>


#define PARSELISTCOMMON NSString *result = [[[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding] autorelease];id obj = [result JSONValue];if(obj == nil){[appDelegate showMsg:JSONERROR hiddenTime:2];    return nil;}int code = [DataParser idToInt:obj key:@"code"];if(code != 1){    NSString * msg = [DataParser idToStr:obj key:@"text"];    [appDelegate showMsg:msg hiddenTime:2];    return nil;}id dataObj = [obj objectForKey:@"data"];if(dataObj == nil)return nil;
#define PARSELISTCOMMON_NOMSG NSString *result = [[[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding] autorelease];id obj = [result JSONValue];if(obj == nil){return nil;}int code = [DataParser idToInt:obj key:@"code"];if(code != 1){    return nil;}id dataObj = [obj objectForKey:@"data"];if(dataObj == nil)return nil;

@interface DataModel : NSObject
/*
 *序列化和反序列化
 */
-(NSString*)toJson;
-(void)setDataByJson:(NSString*)jsonStr;
-(void)setArrByJson:(NSString*)keyStr valueStr:(NSString*)valueStr;
@end

@interface ErrorObject : DataModel
{
    NSInteger ErroeCode;
    NSString * ErrorMsg;
}
@property NSInteger ErrorCode;
@property (nonatomic,retain) NSString * ErrorMsg;
@property NSInteger totalPage;
@property NSInteger curPage;
@end


@interface CheckCodeResObj : NSObject
@property NSInteger status;
@property NSInteger count;
@property(nonatomic,copy)NSString * msg;
@end


/**
 *	@brief	微信登录获取 access_token
 */
@interface WeiXinAccessToken : NSObject
@property(nonatomic,copy)NSString * accessToken;
@property NSInteger expires;     //access_token接口调用凭证超时时间，单位（秒）
@property(nonatomic,copy)NSString * refreshToken;
@property(nonatomic,copy)NSString * openid;
@property(nonatomic,copy)NSString * scope;
@end
/**
 *	@brief	微信获取用户数据
 */
@interface WeiXinUserInfo : DataModel
@property(nonatomic,copy)NSString * openid; //普通用户的标识，对当前开发者帐号唯一
@property(nonatomic,copy)NSString * nickname; //普通用户昵称
@property NSInteger sex;     //普通用户性别，1为男性，2为女性
@property(nonatomic,copy)NSString * province;
@property(nonatomic,copy)NSString * city;
@property(nonatomic,copy)NSString * country;
@property(nonatomic,copy)NSString * headimgurl;//用户头像，最后一个数值代表正方形头像大小（有0、46、64、96、132数值可选，0代表640*640正方形头像），用户没有头像时该项为空
@property(nonatomic,copy)NSString * unionid; //用户统一标识。针对一个微信开放平台帐号下的应用，同一用户的unionid是唯一的。
@end



@interface UserInfoObj : ErrorObject
@property(nonatomic,copy)NSString * userId;
@property(nonatomic,copy)NSString * userName;
@property(nonatomic,copy)NSString * userPwd;
@property(nonatomic,copy)NSString * userNick;
@property(nonatomic,copy)NSString * userWeixinId;
@property(nonatomic,copy)NSString * userHead;
@property(nonatomic,copy)NSString * isAdmin;
@property int userAge;
@property int userSex;
@end
@interface ScanHisObj : ErrorObject
@property(nonatomic,copy)NSString * logoUrl;
@property(nonatomic,copy)NSString * name;
@property(nonatomic,copy)NSString * time;
@end
@interface ScanCountObj : ErrorObject
@property(nonatomic,copy)NSString * logoUrl;
@property(nonatomic,copy)NSString * name;
@property(nonatomic,copy)NSString * time;
@property(nonatomic,copy)NSString * count;
@end


@interface DataParser : NSObject
+(NSString*)idToStr:(id)obj key:(NSString *)_key;
+(NSInteger)idToInt:(id)obj key:(NSString *)_key;
+(float)idToFloat:(id)obj key:(NSString *)_key;
+(CheckCodeResObj*)parseCheckCode:(NSData*)_data;
+(id)parseWeiXinAccessToken:(NSString *)_data;
+(id)parseWeiXinUserInfo:(NSString *)_data;
+(UserInfoObj*)parseUserInfo:(NSData*)_data;
@end
