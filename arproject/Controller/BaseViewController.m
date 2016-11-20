//
//  BaseViewController.m
//  DSSQ
//
//  Created by 王健 on 16/11/2.
//  Copyright © 2016年 王健. All rights reserved.
//

#import "BaseViewController.h"
#import "Def.h"
#import "ISSFileOp.h"
#import "AppDelegate.h"

extern AppDelegate * appDelegate;
@implementation UINavigationItem (margin)

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
- (void)setLeftBarButtonItem:(UIBarButtonItem *)_leftBarButtonItem
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        UIBarButtonItem *negativeSeperator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSeperator.width = -12;
        if (_leftBarButtonItem)
            [self setLeftBarButtonItems:@[negativeSeperator, _leftBarButtonItem]];
        else
            [self setLeftBarButtonItems:@[negativeSeperator]];
        [negativeSeperator release];
    }
    else
        [self setLeftBarButtonItem:_leftBarButtonItem animated:NO];
}
- (void)setRightBarButtonItem:(UIBarButtonItem *)_rightBarButtonItem
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        UIBarButtonItem *negativeSeperator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSeperator.width = -12;
        if (_rightBarButtonItem)
            [self setRightBarButtonItems:@[negativeSeperator, _rightBarButtonItem]];
        else
            [self setRightBarButtonItems:@[negativeSeperator]];
        [negativeSeperator release];
    }
    else
        [self setRightBarButtonItem:_rightBarButtonItem animated:NO];
}

#endif
@end


@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    mainScroll = [[TBScrollVIew alloc] initWithFrame:self.view.bounds];
    [mainScroll setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:mainScroll];
    // Do any additional setup after loading the view.
}
-(void)dealloc
{
    FREEOBJECT(mainScroll);
    [super dealloc];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)adapterForIOS7
{
#ifdef __IPHONE_7_0
    if(SYSVERSION >= 7.0)
    {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
        [self setExtendedLayoutIncludesOpaqueBars:NO];
        [self setModalPresentationCapturesStatusBarAppearance:NO];
    }
#endif
}

//在系统navbar的基础上修改背景来实现自定义效果
//backobj nill sys default. string show .button show button
//rightobj nil do not show right. string show .button show button
//titleobj is same as up two
-(void)setNavBg:(UIViewController *)target title:(id)titleObj back:(id)backObj right:(id)rightObj
{
    NSString * navBgImg = @"img_nav_bg7";
    if(SYSVERSION >= 7.0)
        navBgImg = @"img_nav_bg";
    
    [self adapterForIOS7];
    //NSString * imagePath = [[SkinTool defaultInstance] getSkin:navBgImg];
    NSString * imagePath = [NSString stringWithFormat:@"%@",navBgImg];
    UIImage * barBgImg = [UIImage imageNamed:navBgImg];
    barBgImg = [barBgImg resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0) resizingMode:UIImageResizingModeStretch];
    UINavigationBar * navBar = self.navigationController.navigationBar;
    
    if ([navBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)])
    {
        //if iOS 5.0 and later
        [navBar setBackgroundImage:barBgImg forBarMetrics:UIBarMetricsDefault];
        //        [navBar setBackgroundImage:[UIImage imageNamed:imagePath] forBarPosition:UIBarPositionTop barMetrics:UIBarMetricsDefault];
    }
    else
    {
        UIImageView *imageView = (UIImageView *)[navBar viewWithTag:NAVBARBG];
        if (imageView == nil)
        {
            imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imagePath]];
            [imageView setTag:NAVBARBG];
            [navBar insertSubview:imageView atIndex:0];
            [imageView release];
        }
    }
    //返回按钮背景
    if(backObj != nil)
    {
        UIView * backContain = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
        [backContain setBackgroundColor:[UIColor clearColor]];
        if([backObj isKindOfClass:[NSString class]])
        {
            UIButton * backbtn = [UIButton buttonWithType:UIButtonTypeCustom];
            backbtn.frame = CGRectMake(0, (backContain.frame.size.height - 30)/2, 53, 30);
            [backbtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            backbtn.titleLabel.font = [UIFont systemFontOfSize:13];
            
            NSString * backStr = (NSString*)backObj;
            if(backStr.length == 0)
                //[backbtn setImage:[UIImage imageNamed:[[SkinTool defaultInstance] getSkin:@"img_backBtn"]] forState:UIControlStateNormal];
                [backbtn setImage:[UIImage imageNamed:@"img_nav_back"] forState:UIControlStateNormal];
            else
                [backbtn setTitle:backStr forState:UIControlStateNormal];
            
            //[backbtn setBackgroundImage:[UIImage imageNamed:[[SkinTool defaultInstance] getSkin:@"img_backBg"]] forState:UIControlStateNormal];
            [backbtn setBackgroundImage:[UIImage imageNamed:@"img_nav_label"] forState:UIControlStateNormal];
            
            [backbtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
            [backbtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [backbtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
            [backbtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
            [backContain addSubview:backbtn];
            UIBarButtonItem * backItem = [[UIBarButtonItem alloc] initWithCustomView:backContain];
            target.navigationItem.leftBarButtonItem = backItem;
            [backItem release];
        }
        else if([backObj isKindOfClass:[UIButton class]])
        {
            [backContain addSubview:(UIButton*)backObj];
            UIBarButtonItem * backItem = [[UIBarButtonItem alloc]initWithCustomView:(UIButton*)backContain];
            target.navigationItem.leftBarButtonItem = backItem;
            [backItem release];
        }
        [backContain release];
    }
    //rightbtn
    if(rightObj != nil)
    {
        if([rightObj isKindOfClass:[NSString class]])
        {
            UIButton * rightbtn = [UIButton buttonWithType:UIButtonTypeCustom];
            rightbtn.frame = CGRectMake(0, 5, 51, 30);
            
            [rightbtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            rightbtn.titleLabel.font = [UIFont systemFontOfSize:13];
            NSString * rightStr = (NSString*)rightObj;
            if(rightStr.length == 0)
            {
                //[rightbtn setImage:[UIImage imageNamed:[[SkinTool defaultInstance] getSkin:@"img_rightBtn"]] forState:UIControlStateNormal];
                [rightbtn setImage:[UIImage imageNamed:@"img_nav_label"] forState:UIControlStateNormal];
                [rightbtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
                [rightbtn setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
            }
            else
                [rightbtn setTitle:NSLocalizedString(rightStr, nil) forState:UIControlStateNormal];
            //[rightbtn setBackgroundImage:[UIImage imageNamed:[[SkinTool defaultInstance] getSkin:@"img_rightBg"]] forState:UIControlStateNormal];
            [rightbtn setBackgroundImage:[UIImage imageNamed:@"img_nav_label"] forState:UIControlStateNormal];
            [rightbtn addTarget:self action:@selector(rightAction:) forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightbtn];
            target.navigationItem.rightBarButtonItem = rightItem ;
            [rightItem release];
        }
        else if([rightObj isKindOfClass:[UIButton class]])
        {
            UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithCustomView:(UIButton*)rightObj];
            target.navigationItem.rightBarButtonItem = rightItem ;
            [rightItem release];
        }
    }
    
    
    if(titleObj != nil)
    {
        if([titleObj isKindOfClass:[NSString class]])
        {
            NSString * titleStrl = (NSString*)titleObj;
            if(titleStrl.length > 0)
            {
                
                UILabel * title = [[UILabel alloc] init];
                [title setBackgroundColor:[UIColor clearColor]];
                [title setFrame:CGRectMake(0, 0, appDelegate.screenWidth/2, 44)];
                [title setTextAlignment:NSTextAlignmentCenter];
                [title setTextColor:[UIColor whiteColor]];
                [title setText:titleStrl];
                [title setFont:[UIFont systemFontOfSize:20]];
                target.navigationItem.titleView = title;
                [title release];
            }
            else
            {
                UIImageView * logoView = [[UIImageView alloc] init];
                UIImage * logo = [UIImage imageNamed:@"img_navLogo"];
                [logoView setFrame:CGRectMake(0, 0, 42, 25)];
                [logoView setImage:logo];
                [logoView setContentMode:UIViewContentModeScaleAspectFit];
                [target.navigationItem.titleView setBackgroundColor:[UIColor clearColor]];
                target.navigationItem.titleView = logoView;
                [logoView release];
            }
        }
        else
        {
            if([titleObj isKindOfClass:[UIView class]])
                [target.navigationItem.titleView addSubview:titleObj];
        }
    }
}
-(void)backAction:(UIButton*)btn
{
    if(self.navigationController != nil)
        [self.navigationController popViewControllerAnimated:YES];
    else
    {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0f) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else
            [self dismissModalViewControllerAnimated:YES];
    }
}
-(void)rightAction:(UIButton*)btn
{
    
}

-(BOOL)isIOS7
{
    if (SYSVERSION >= 7.0){
        int result = [ISSFileOp compareVersionNumber:@"7.1.0" compareWith:[[UIDevice currentDevice] systemVersion]];
        if (result == 0)
            return YES;
        else
            return NO;
    }
    return NO;
}
-(void)setAutoAdjustScrollInsets:(BOOL)flag
{
    if(SYSVERSION >= 7.0)
        [self setAutomaticallyAdjustsScrollViewInsets:flag];
}
-(CGFloat)getFixOffY
{
    CGFloat offsetY = 0.0f;
    if (SYSVERSION >= 7.0){
        /*
         return = -1   有错
         return = 0    @"7.1" > systemVersion
         return = 1    相同
         return = 2    @"7.1" < systemVersion
         */
        offsetY = 64.0f;
        int result = [ISSFileOp compareVersionNumber:@"7.1.0" compareWith:[[UIDevice currentDevice] systemVersion]];
        if (result == 0) {
            offsetY = 0.0;
        }
        
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
    return offsetY;
}
-(CGRect)getMainTableFrame
{
    CGFloat offsetY = [self getFixOffY];
    CGRect tableFrame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height - 64.0f);
    if(SYSVERSION < 7.0)
        tableFrame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height + offsetY - 44.0f);
    return tableFrame;
}
@end
