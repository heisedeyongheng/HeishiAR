//
//  RegistViewController.h
//  arproject
//
//  Created by 王健 on 16/11/12.
//  Copyright © 2016年 王健. All rights reserved.
//

#import "BaseViewController.h"

@interface RegistViewController : BaseViewController<SZMGConnectDelegate>
{
    UITextField * userNameField;
    UITextField * userPwdField;
    UITextField * userPwdConfirmField;
}
@end
