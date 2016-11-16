//
//  LoginViewController.h
//  arproject
//
//  Created by 王健 on 16/11/14.
//  Copyright © 2016年 王健. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

#define WXOPENID_KEY        @"wxopenid"
#define WXUNIONID_KEY       @"wxunionid"
#define WXNICK_KEY          @"wxnick"
#define WXFACE_KEY          @"wxface"

@interface LoginViewController : BaseViewController<SZMGConnectDelegate>
{
    UITextField * userNameField;
    UITextField * userPwdField;
}
+(NSString*)wxLoginOkNotifyKey;
@end
