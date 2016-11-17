//
//  Def.h
//  arproject
//
//  Created by 王健 on 16/11/12.
//  Copyright © 2016年 王健. All rights reserved.
//

#ifndef Def_h
#define Def_h


/*network*/
#define kAPIVersion                 @"1"
#define KServerURL                  @"http://119.29.53.118:8080/"
#define KLoginApi                   @"user/login"
#define KRegistAPI                  @"user/register"
#define KModifyInfoApi              @"user/update"


/*微信 开放平台*/
#define WeiXinChatAppID        	@"wx7ed55c8eb2b6e6d7"
#define WeiXinChatAppKey     	@"a53f1c8207c3f2a84dc1aa38843731f0"
#define WeiXinPartnerId     	@""


/*pub use*/
#define R_W  0.2
#define B_H  0.1
#define STRNULRETURN(obj)       {if(obj == nil || obj.length == 0){DEBUG_NSLOG(@"错误：字符串空 %s",__FUNCTION__);return;}}
#define STRNULL(obj)            ((obj == nil || [obj isEqualToString:@"(null)"]) ? @"" : obj)
#define STRNULLDEF(obj,default) ((obj == nil || [obj isEqualToString:@"(null)"]) ? default : obj)
#define OBJRIGHT(obj)           (obj.frame.origin.x + obj.frame.size.width)
#define OBJBOTTOM(obj)          (obj.frame.origin.y + obj.frame.size.height)
#define FREEOBJECT(obj)         if(obj != nil){ [obj release]; obj = nil;}
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? ([[UIScreen mainScreen] currentMode].size.height >= 1136) : NO)
#define SYSVERSION              [[[UIDevice currentDevice] systemVersion] floatValue]

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f \
blue:(b)/255.0f alpha:1.0f]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f \
alpha:(a)]

/*debug opt*/

#ifdef DEBUG
#define DEBUG_NSLOG(format, ...) NSLog(format, ## __VA_ARGS__)
#define MCRelease(x) [x release]
#define DEBUGTAG
#else
#define DEBUG_NSLOG(format, ...)
#define MCRelease(x) [x release], x = nil
#define DEBUGTAG        cur is release mod please del this tag
#endif

/*customview*/
#define GREEN_BTN_COLOR     RGBCOLOR(10, 200, 10)
#define GRAY_FONT_COLOR     [UIColor colorWithRed:190/255.0f green:190/255.0f blue:190/255.0f alpha:1.0]
#define MAIN_CACHE_PATH                 @"myCaches"
#define AsyncImgFILE_FOLDER             @"AsyncImg"
#endif /* Def_h */



