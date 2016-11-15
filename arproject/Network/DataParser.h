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


@interface ErrorObject : NSObject
{
    NSInteger ErroeCode;
    NSString * ErrorMsg;
}
@property NSInteger ErrorCode;
@property (nonatomic,retain) NSString * ErrorMsg;
@end


@interface CheckCodeResObj : NSObject
@property NSInteger status;
@property NSInteger count;
@property(nonatomic,copy)NSString * msg;
@end

@interface UserInfoObj : ErrorObject
@property(nonatomic,copy)NSString * userId;
@property(nonatomic,copy)NSString * userName;
@property(nonatomic,copy)NSString * userPwd;
@property(nonatomic,copy)NSString * userNick;
@property(nonatomic,copy)NSString * userWeixinId;
@property(nonatomic,copy)NSString * userHead;
@property int isAdmin;
@property int userAge;
@property int userSex;
@end

@interface DataParser : NSObject
+(NSString*)idToStr:(id)obj key:(NSString *)_key;
+(NSInteger)idToInt:(id)obj key:(NSString *)_key;
+(float)idToFloat:(id)obj key:(NSString *)_key;
+(CheckCodeResObj*)parseCheckCode:(NSData*)_data;
+(UserInfoObj*)parseUserInfo:(NSData*)_data;
@end
