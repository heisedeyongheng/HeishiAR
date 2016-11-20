//
//  BaseViewController.h
//  DSSQ
//
//  Created by 王健 on 16/11/2.
//  Copyright © 2016年 王健. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBViews.h"
#import "Def.h"
#import "SZMGConnect.h"


#define NAVBARBG        2000
#define BASEBG          2200

@interface UINavigationItem (margin)

@end


@interface BaseViewController : UIViewController
{
    TBScrollVIew * mainScroll;
}
-(void)setNavBg:(UIViewController *)target title:(id)titleObj back:(id)backObj right:(id)rightObj;
-(void)backAction:(UIButton*)btn;
-(void)rightAction:(UIButton*)btn;
-(BOOL)isIOS7;
-(void)setAutoAdjustScrollInsets:(BOOL)flag;
-(CGFloat)getFixOffY;
-(CGRect)getMainTableFrame;
@end
