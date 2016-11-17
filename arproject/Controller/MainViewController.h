//
//  MainViewController.h
//  arproject
//
//  Created by 王健 on 16/11/12.
//  Copyright © 2016年 王健. All rights reserved.
//

#import "BaseViewController.h"
#import "ISSAsyncImageView.h"
#import "TBViews.h"

@interface MainViewController : BaseViewController<ISSAsyncImageViewDelegate>
{
    //背景
    UIButton * bgMaskView;
    UIImageView * mainBg;
    
    UIView * loginContain;
    UIButton * loginBtn;
    UIButton * regBtn;
    
    UIView * normalContain;
    ISSAsyncImageView * headerView;
    UILabel * userNick;
}
@end
