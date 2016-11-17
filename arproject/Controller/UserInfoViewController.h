//
//  UserInfoViewController.h
//  arproject
//
//  Created by 王健 on 16/11/17.
//  Copyright © 2016年 王健. All rights reserved.
//

#import "BaseViewController.h"
#import "ISSAsyncImageView.h"


@interface UserInfoViewController : BaseViewController<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,SZMGConnectDelegate>
{
    ISSAsyncImageView * userHead;
    UITextField * userNick;
    
    UIImagePickerController * imgPicker;
    NSString * headPath;
}
@end
