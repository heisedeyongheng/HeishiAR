//
//  DataParser.m
//  Ubunta
//
//  Created by 王健 on 13-8-13.
//  Copyright (c) 2013年 wj. All rights reserved.
//

#import "DataParser.h"
#import <objc/runtime.h>
#import "JSON.h"
#import "Def.h"
#import "AppDelegate.h"

extern AppDelegate * appDelegate;


@implementation DataModel
-(NSString*)toJson
{
    NSString * result = @"";
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    id sClass = self.class;
    unsigned int outCount, i;
    objc_property_t * properties = class_copyPropertyList(sClass, &outCount);//获取该类的所有属性
    for (i = 0; i < outCount; i++)
    {
        objc_property_t property = properties[i];
        NSString * propertyName = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        id propertyValue = [self valueForKey:(NSString *)propertyName];
        if(propertyValue != nil){
            if([propertyValue isKindOfClass:[NSString class]])
                [dict setValue:propertyValue forKey:propertyName];
            else if([propertyValue isKindOfClass:[NSMutableArray class]]){
                NSMutableArray * jsonArr = [[NSMutableArray alloc] init];
                NSMutableArray * arr = (NSMutableArray*)propertyValue;
                for(id obj in arr){
                    if([obj isKindOfClass:[DataModel class]]){
                        NSString * json = [(DataModel*)obj toJson];
                        [jsonArr addObject:json];
                    }
                }
                [dict setValue:jsonArr forKey:propertyName];
                [jsonArr release];
            }
            else{
                [dict setValue:propertyValue forKey:propertyName];
            }
        }
        [propertyName release];
    }
    result = [dict JSONRepresentation];
    [dict release];
    return result;
}
-(void)setDataByJson:(NSString *)jsonStr
{
    id obj = [jsonStr JSONValue];
    NSArray * allKeys = [obj allKeys];
    for(NSString * key in allKeys){
        id valueObj = [obj valueForKey:key];
        if([valueObj isKindOfClass:[NSDictionary class]]){
            NSDictionary * dict = (NSDictionary*)valueObj;
            for(int i=0;i<dict.count;i++){
                NSString * str = (NSString*)[dict.allValues objectAtIndex:i];
                [self setArrByJson:key valueStr:str];
            }
        }
        else if([valueObj isKindOfClass:[NSArray class]]){
            NSArray * arr = (NSArray*)valueObj;
            for(int i=0;i<arr.count;i++){
                NSString * str = (NSString*)[arr objectAtIndex:i];
                [self setArrByJson:key valueStr:str];
            }
        }
        else{
            [self setValue:valueObj forKey:key];
        }
    }
}
-(void)setArrByJson:(NSString *)keyStr valueStr:(NSString *)valueStr
{
    //this method need subclass to overwrite
}
@end


@implementation ErrorObject
@synthesize ErrorCode;
@synthesize ErrorMsg;
-(void)dealloc
{
    DEBUG_NSLOG(@"%s",__FUNCTION__);
    FREEOBJECT(ErrorMsg);
    [super dealloc];
}
@end


@implementation CheckCodeResObj
@synthesize status,count,msg;
-(void)dealloc
{
    FREEOBJECT(msg);
    [super dealloc];
}
@end

/**
 *	@brief	微信登录获取 access_token
 */
@implementation WeiXinAccessToken
@synthesize accessToken,expires,refreshToken,openid,scope;
-(id)init
{
    self = [super init];    
    return self;
}
-(void)dealloc
{
    FREEOBJECT(accessToken);
    FREEOBJECT(refreshToken);
    FREEOBJECT(openid);
    FREEOBJECT(scope);
    [super dealloc];
}
@end
/**
 *	@brief	微信用户数据
 */
@implementation WeiXinUserInfo
@synthesize openid,nickname,province,sex,city,country,headimgurl,unionid;
-(id)init
{
    self = [super init];
    return self;
}
-(void)dealloc
{
    FREEOBJECT(openid);
    FREEOBJECT(nickname);
    FREEOBJECT(province);
    FREEOBJECT(city);
    FREEOBJECT(country);
    FREEOBJECT(headimgurl);
    FREEOBJECT(unionid);
    [super dealloc];
}
@end

@implementation UserInfoObj
@synthesize userId,userName,userPwd,userAge,userSex,userHead,userNick,userWeixinId,isAdmin;
-(void)dealloc
{
    FREEOBJECT(userId);
    FREEOBJECT(userName);
    FREEOBJECT(userPwd);
    FREEOBJECT(userHead);
    FREEOBJECT(userNick);
    FREEOBJECT(userWeixinId);
    [super dealloc];
}
@end

@implementation DataParser
+(NSString*)idToStr:(id)obj key:(NSString *)_key
{
    id value = [obj valueForKey:_key];
    if(value != nil)
    {
        if([value isKindOfClass:[NSNumber class]])
            return [NSString stringWithFormat:@"%d",[value intValue]];
        else if([value isKindOfClass:[NSString class]])
            return (NSString*)value;
        else
            return @"";
    }
    else
        return @"";
}

+(NSInteger)idToInt:(id)obj key:(NSString *)_key
{
    id value = [obj valueForKey:_key];
    if(value != nil)
    {
        if([obj isKindOfClass:[NSNumber class]])
            return [value intValue];
        else
            return [(NSString*)value intValue];
    }
    else
        return -1;
}
+(float)idToFloat:(id)obj key:(NSString *)_key
{
    id value = [obj valueForKey:_key];
    if(value != nil)
    {
        if([obj isKindOfClass:[NSNumber class]])
            return [value floatValue];
        else
            return [(NSString*)value floatValue];
    }
    else
        return -1;
}


+(CheckCodeResObj*)parseCheckCode:(NSData *)_data
{
    CheckCodeResObj * resultObj = nil;;
    
    NSString *result = [[[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding] autorelease];
    id obj = [result JSONValue];
    if(obj == nil){
        [appDelegate showMsg:@"json解析错误" hiddenTime:2];
        return nil;
    }
    resultObj = [[CheckCodeResObj alloc] init];
    resultObj.status = [DataParser idToInt:obj key:@"status"];
    id rObj = [obj objectForKey:@"result"];
    if(rObj != nil){
        id countObj = [rObj objectForKey:@"result"];
        if([countObj isKindOfClass:[NSArray class]] || [countObj isKindOfClass:[NSDictionary class]]){
            resultObj.count = [DataParser idToInt:countObj key:@"count"];
        }
        else
            resultObj.msg = (NSString*)countObj;
    }
    else{
        resultObj.msg = @"抱歉出错了";
    }
    return resultObj;
}

+(id)parseWeiXinAccessToken:(NSString *)_data
{
    
    id obj = [_data JSONValue];
    if(obj == nil)return nil;//json error
    
    if ([obj valueForKey:@"errcode"] == nil) {
        WeiXinAccessToken * wxAccessToken = [[[WeiXinAccessToken alloc]init] autorelease];        
        wxAccessToken.accessToken = [DataParser idToStr:obj key:@"access_token"];
        wxAccessToken.expires = [DataParser idToInt:obj key:@"expires_in"];
        wxAccessToken.refreshToken = [DataParser idToStr:obj key:@"refresh_token"];
        wxAccessToken.openid = [DataParser idToStr:obj key:@"openid"];
        wxAccessToken.scope = [DataParser idToStr:obj key:@"scope"];
        return wxAccessToken;
    }
    else{
        ErrorObject * tmp = [[ErrorObject alloc] init];
        tmp.ErrorCode = [[obj valueForKey:@"errcode"] integerValue];
        tmp.ErrorMsg = [NSString stringWithFormat:@"%@",[DataParser idToStr:obj key:@"errmsg"]];
        return tmp;
    }
}


/**
 *	@brief	微信登录  通过access_token 和 openid 获取用户信息
 *
 *	@param 	_data 数据出参
 *
 *	@return
 */
+(id)parseWeiXinUserInfo:(NSString *)_data
{
    id obj = [_data JSONValue];
    if(obj == nil)return nil;//json error
    
    if ([obj valueForKey:@"errcode"] == nil) {
        WeiXinUserInfo *wxUserInfo = [[[WeiXinUserInfo alloc]init] autorelease];
        wxUserInfo.openid = [DataParser idToStr:obj key:@"openid"];
        wxUserInfo.nickname = [DataParser idToStr:obj key:@"nickname"];
        wxUserInfo.sex = [DataParser idToInt:obj key:@"sex"];
        wxUserInfo.province = [DataParser idToStr:obj key:@"province"];
        wxUserInfo.city = [DataParser idToStr:obj key:@"city"];
        wxUserInfo.country = [DataParser idToStr:obj key:@"country"];
        wxUserInfo.headimgurl = [DataParser idToStr:obj key:@"headimgurl"];
        wxUserInfo.unionid = [DataParser idToStr:obj key:@"unionid"];
        return wxUserInfo;
    }
    else{
        ErrorObject * tmp = [[ErrorObject alloc] init];
        tmp.ErrorCode = [[obj valueForKey:@"errcode"] integerValue];
        tmp.ErrorMsg = [NSString stringWithFormat:@"%@",[DataParser idToStr:obj key:@"errmsg"]];
        return tmp;
    }
}

+(UserInfoObj*)parseUserInfo:(NSData *)_data
{
    UserInfoObj * resultObj = nil;;
    
    NSString *result = [[[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding] autorelease];
    id obj = [result JSONValue];
    if(obj == nil){
        [appDelegate showMsg:@"json解析错误" hiddenTime:2];
        return nil;
    }
    resultObj = [[UserInfoObj alloc] init];
    resultObj.ErrorCode = [DataParser idToInt:obj key:@"code"];
    resultObj.ErrorMsg = [DataParser idToStr:obj key:@"msg"];
    
    return resultObj;
}
@end
