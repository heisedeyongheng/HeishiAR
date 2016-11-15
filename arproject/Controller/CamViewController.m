//
//  CamViewController.m
//  arproject
//
//  Created by 王健 on 16/11/12.
//  Copyright © 2016年 王健. All rights reserved.
//

#import "CamViewController.h"
#import "AppDelegate.h"

extern AppDelegate * appDelegate;
@implementation CamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIButton * testBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [testBtn setFrame:CGRectMake(20, 30, 80, 40)];
    [testBtn setBackgroundColor:[UIColor blackColor]];
    [testBtn addTarget:self action:@selector(testAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testBtn];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)testAction:(UIButton*)btn
{
    [appDelegate showSlipView];
}
@end
