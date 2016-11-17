//
//  PwdViewController.h
//  arproject
//
//  Created by 王健 on 16/11/17.
//  Copyright © 2016年 王健. All rights reserved.
//

#import "BaseViewController.h"

@interface PwdViewController : BaseViewController<SZMGConnectDelegate>
{
    UITextField * curPwd;
    UITextField * newPwd;
    UITextField * confirmPwd;
}
@end
