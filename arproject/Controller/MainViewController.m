//
//  MainViewController.m
//  arproject
//
//  Created by 王健 on 16/11/12.
//  Copyright © 2016年 王健. All rights reserved.
//

#import "MainViewController.h"
#import "RegistViewController.h"
#import "LoginViewController.h"
#import "AppDelegate.h"

extern AppDelegate * appDelegate;
@implementation MainViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}
-(void)dealloc
{
    FREEOBJECT(mainBg);
    FREEOBJECT(bgMaskView);
    FREEOBJECT(loginContain);
    [super dealloc];
}
-(void)viewDidLoad {
    [super viewDidLoad];
    [self initControls];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initControls
{
    [self setNavBg:self title:@"合视AR" back:@"test" right:@""];
    bgMaskView = [[UIButton alloc] init];
    [bgMaskView setFrame:CGRectMake(0, 0, appDelegate.screenWidth, appDelegate.screenHeight)];
    [bgMaskView setBackgroundColor:RGBACOLOR(0, 0, 0, 0.6)];
    [bgMaskView setAlpha:0];
    [bgMaskView setUserInteractionEnabled:NO];
    [bgMaskView addTarget:self action:@selector(maskViewAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.view addSubview:bgMaskView];
    
    mainBg = [[UIImageView alloc] init];
    [mainBg setFrame:CGRectMake(-1*appDelegate.screenWidth, 0, [appDelegate getSlipWidth], [appDelegate getSlipHeight])];
    [mainBg setContentMode:UIViewContentModeScaleAspectFill];
    [mainBg setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [mainBg setImage:[UIImage imageNamed:@"main_bg"]];
    [mainBg setUserInteractionEnabled:YES];
    [self.navigationController.view addSubview:mainBg];
    UIImageView * logo = [[UIImageView alloc] init];
    [logo setFrame:CGRectMake(0, 0, 50, 50)];
    [logo setCenter:CGPointMake(mainBg.frame.size.width/2, 40)];
    [logo setContentMode:UIViewContentModeScaleAspectFill];
    [logo setImage:[UIImage imageNamed:@"logo"]];
    [mainBg addSubview:logo];
    [logo release];
    
    
    [self initLoginView];
    [self initNormalView];
}
-(void)initLoginView
{
    loginContain = [[UIView alloc] initWithFrame:mainBg.bounds];
    [loginContain setBackgroundColor:[UIColor clearColor]];
    [loginContain setUserInteractionEnabled:YES];
    [mainBg addSubview:loginContain];

    loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginBtn setFrame:CGRectMake(0, 0, 80, 80)];
    [loginBtn setCenter:CGPointMake(loginContain.frame.size.width/2, 130)];
    [loginBtn addTarget:self action:@selector(loginAction:) forControlEvents:UIControlEventTouchUpInside];
    [loginBtn setBackgroundColor:[UIColor whiteColor]];
    [loginBtn.layer setCornerRadius:loginBtn.frame.size.width/2];
    [loginContain addSubview:loginBtn];
    
    regBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [regBtn setFrame:CGRectMake(0, OBJBOTTOM(loginBtn) + 20, 80, 30)];
    [regBtn setCenter:CGPointMake(loginContain.frame.size.width/2, regBtn.center.y)];
    [regBtn addTarget:self action:@selector(regAction:) forControlEvents:UIControlEventTouchUpInside];
    [regBtn setBackgroundColor:[UIColor whiteColor]];
    [regBtn setTitle:@"注册" forState:UIControlStateNormal];
    [regBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [regBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [loginContain addSubview:regBtn];
    
    UIView * bgView = [[UIView alloc] init];
    [bgView setFrame:CGRectMake(0, OBJBOTTOM(regBtn) + 20, CGRectGetWidth(loginContain.frame), CGRectGetHeight(loginContain.frame) - (OBJBOTTOM(regBtn) + 20))];
    [bgView setBackgroundColor:[UIColor whiteColor]];
    [loginContain addSubview:bgView];
    [bgView release];
    UILabel * titleLab = [[UILabel alloc] init];
    [titleLab setFrame:CGRectMake(20, 0, bgView.frame.size.width, 40)];
    [titleLab setTextColor:RGBACOLOR(180, 180, 180, 1)];
    [titleLab setFont:[UIFont systemFontOfSize:12]];
    [titleLab setText:@"功能与设置"];
    [bgView addSubview:titleLab];
    [titleLab release];
    TBMargin margin = TBMargionMake(8, 8, 15, 8);
    TBButton * scanRecod = [[TBButton alloc] init];
    [scanRecod setFrame:CGRectMake(0, OBJBOTTOM(titleLab), bgView.frame.size.width, 40)];
    [scanRecod setImgMargion:margin];
    [scanRecod setImgAndData:@"scanr" data:@"扫描记录"];
    [scanRecod addTarget:self action:@selector(recodAction:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:scanRecod];
    [scanRecod release];
    TBButton * faq = [[TBButton alloc] init];
    [faq setFrame:CGRectMake(0, OBJBOTTOM(scanRecod), bgView.frame.size.width, 40)];
    [faq setImgMargion:margin];
    [faq setImgAndData:@"faq" data:@"如何使用"];
    [faq addTarget:self action:@selector(faqAction:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:faq];
    [faq release];
    TBButton * setting = [[TBButton alloc] init];
    [setting setFrame:CGRectMake(0, OBJBOTTOM(faq), bgView.frame.size.width, 40)];
    [setting setImgMargion:margin];
    [setting setImgAndData:@"setting" data:@"系统设置"];
    [setting addTarget:self action:@selector(setAction:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:setting];
    [setting release];
}
-(void)initNormalView
{

}
#pragma mark --- 登录
-(void)loginAction:(UIButton*)btn
{
    DEBUG_NSLOG(@"%s",__FUNCTION__);
    UINavigationController * topNav = [appDelegate getTopNav];
    LoginViewController * login = [[LoginViewController alloc] initWithNibName:nil bundle:nil];
    [topNav pushViewController:login animated:NO];
    [login release];
    [appDelegate showTopNav:YES];
}
-(void)regAction:(UIButton*)btn
{
    DEBUG_NSLOG(@"%s",__FUNCTION__);
    UINavigationController * topNav = [appDelegate getTopNav];
    RegistViewController * regist = [[RegistViewController alloc] initWithNibName:nil bundle:nil];
    [topNav pushViewController:regist animated:YES];
    [regist release];
    [appDelegate showTopNav:YES];
}
-(void)recodAction:(UIButton*)btn
{
    DEBUG_NSLOG(@"%s",__FUNCTION__);
}
-(void)faqAction:(UIButton*)btn
{
    DEBUG_NSLOG(@"%s",__FUNCTION__);
}
-(void)setAction:(UIButton*)btn
{
    DEBUG_NSLOG(@"%s",__FUNCTION__);
}
-(void)backAction:(UIButton *)btn
{
    [self showSlipView];
}
#pragma mark -- 抽屉ui
-(void)showSlipView
{
    [UIView animateWithDuration:0.3 animations:^(){
        [bgMaskView setAlpha:1.0f];
        [mainBg setFrame:CGRectMake(0, mainBg.frame.origin.y, [appDelegate getSlipWidth], [appDelegate getSlipHeight])];
    } completion:^(BOOL isFinished){
        [bgMaskView setUserInteractionEnabled:YES];
    }];
}
-(void)hideSlipView
{
    [UIView animateWithDuration:0.3 animations:^(){
        [bgMaskView setAlpha:0.0f];
        [mainBg setFrame:CGRectMake(-1*appDelegate.screenWidth, mainBg.frame.origin.y, [appDelegate getSlipWidth], [appDelegate getSlipHeight])];
    } completion:^(BOOL isFinished){
        [bgMaskView setUserInteractionEnabled:NO];
    }];
}
-(void)maskViewAction:(UIButton*)btn
{
    [self hideSlipView];
}
@end