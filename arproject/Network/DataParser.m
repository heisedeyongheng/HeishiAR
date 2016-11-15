//
//  DataParser.m
//  Ubunta
//
//  Created by 王健 on 13-8-13.
//  Copyright (c) 2013年 wj. All rights reserved.
//

#import "DataParser.h"
#import "JSON.h"
#import "Def.h"
#import "AppDelegate.h"

extern AppDelegate * appDelegate;

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
