//
//  UserInfoViewController.m
//  arproject
//
//  Created by 王健 on 16/11/17.
//  Copyright © 2016年 王健. All rights reserved.
//

#import "UserInfoViewController.h"
#import "PwdViewController.h"
#import "AppDelegate.h"

extern AppDelegate * appDelegate;
@implementation UserInfoViewController
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}
-(void)dealloc
{
    DEBUG_NSLOG(@"%s",__FUNCTION__);
    FREEOBJECT(userHead);
    FREEOBJECT(userNick);
    FREEOBJECT(headPath);
    FREEOBJECT(imgPicker);
    [super dealloc];
}
- (void)viewDidLoad {
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
    [self setNavBg:self title:@"我的信息" back:@"" right:@"保存"];
    
    [mainScroll setBackgroundColor:RGBACOLOR(230, 230, 230, 1)];
    CGFloat horOffset = 20;
    UIButton * oneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [oneBtn setFrame:CGRectMake(0, 0, appDelegate.screenWidth, 80)];
    [oneBtn setBackgroundColor:[UIColor whiteColor]];
    [oneBtn addTarget:self action:@selector(oneAction:) forControlEvents:UIControlEventTouchUpInside];
    [mainScroll addSubview:oneBtn];
    UILabel * headLab = [[UILabel alloc] init];
    [headLab setFrame:CGRectMake(horOffset, 0, oneBtn.frame.size.width/2, oneBtn.frame.size.height)];
    [headLab setText:@"头像"];
    [headLab setFont:[UIFont systemFontOfSize:14]];
    [oneBtn addSubview:headLab];
    [headLab release];
    CGFloat imgW = oneBtn.frame.size.height - 20;
    userHead = [[ISSAsyncImageView alloc] init];
    [userHead setFrame:CGRectMake(oneBtn.frame.size.width - imgW - horOffset, 10, imgW, imgW)];
    [userHead setIsUseSuperContentMode:YES];
    [userHead.layer setCornerRadius:userHead.frame.size.width/2];
    [userHead.layer setMasksToBounds:YES];
    [userHead setContentMode:UIViewContentModeScaleAspectFill];
    [userHead setUserInteractionEnabled:NO];
    [oneBtn addSubview:userHead];
    
    UIButton * twoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [twoBtn setFrame:CGRectMake(0, OBJBOTTOM(oneBtn) + 20, appDelegate.screenWidth, 40)];
    [twoBtn setBackgroundColor:[UIColor whiteColor]];
    [mainScroll addSubview:twoBtn];
    UILabel * nickLab = [[UILabel alloc] init];
    [nickLab setFrame:CGRectMake(horOffset, 0, 40, twoBtn.frame.size.height)];
    [nickLab setText:@"昵称"];
    [nickLab setFont:[UIFont systemFontOfSize:14]];
    [twoBtn addSubview:nickLab];
    [nickLab release];
    userNick = [[UITextField alloc] init];
    [userNick setFrame:CGRectMake(OBJRIGHT(nickLab), 0, twoBtn.frame.size.width - OBJRIGHT(nickLab) - horOffset*2, twoBtn.frame.size.height)];
    [userNick setTextAlignment:NSTextAlignmentRight];
    [twoBtn addSubview:userNick];
    
    UIButton * threeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [threeBtn setFrame:CGRectMake(0, OBJBOTTOM(twoBtn) + 20, appDelegate.screenWidth, 40)];
    [threeBtn setBackgroundColor:[UIColor whiteColor]];
    [threeBtn addTarget:self action:@selector(threeAction:) forControlEvents:UIControlEventTouchUpInside];
    [mainScroll addSubview:threeBtn];
    UILabel * pwdLab = [[UILabel alloc] init];
    [pwdLab setFrame:CGRectMake(horOffset, 0, 120, threeBtn.frame.size.height)];
    [pwdLab setText:@"修改密码"];
    [pwdLab setFont:[UIFont systemFontOfSize:14]];
    [threeBtn addSubview:pwdLab];
    [pwdLab release];
    
    UIButton * logoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [logoutBtn setFrame:CGRectMake(horOffset, OBJBOTTOM(threeBtn) + 20, appDelegate.screenWidth - horOffset*2, 40)];
    [logoutBtn setBackgroundImage:[ISSFileOp getImgByColor:GREEN_BTN_COLOR size:CGSizeMake(1, 1)] forState:UIControlStateNormal];
    [logoutBtn setTitle:@"退出登录" forState:UIControlStateNormal];
    [logoutBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [logoutBtn addTarget:self action:@selector(logoutAction:) forControlEvents:UIControlEventTouchUpInside];
    [mainScroll addSubview:logoutBtn];
    
    UserInfoObj * infoObj = [appDelegate getCurUser];
    [userHead loadImageFromCache:infoObj.userHead];
    [userNick setText:infoObj.userNick];
}
-(void)backAction:(UIButton *)btn
{
    [self.navigationController popToRootViewControllerAnimated:NO];
    [appDelegate hideTopNav:YES];
}
#pragma mark -- 修改头像
-(void)oneAction:(UIButton*)btn
{
    DEBUG_NSLOG(@"%s",__FUNCTION__);
    [self closeKeyboard];
    
    UIActionSheet * actionSheet = [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从手机相册选", nil] autorelease];
    [actionSheet showInView:self.view];
}
#pragma mark -- 修改密码
-(void)threeAction:(UIButton*)btn
{
    [self closeKeyboard];
    PwdViewController * pwd = [[PwdViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:pwd animated:YES];
    [pwd release];
}
-(void)rightAction:(UIButton *)btn
{
    UserInfoObj * infoObj = [appDelegate getCurUser];
    SZMGConnect * con = [[SZMGConnect alloc] init];
    [con setDatadelegate:self];
    [con httpModifyUserInfo:infoObj.userId nick:userNick.text head:headPath pwd:nil oldpwd:nil];
    [con release];
}
#pragma mark -- 退出
-(void)logoutAction:(UIButton*)btn
{
    [appDelegate clearCurUser];
    [appDelegate showMsg:@"退出成功" hiddenTime:2];
    [self performSelector:@selector(backAction:) withObject:nil afterDelay:2];
}
#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    DEBUG_NSLOG(@"%d",(int)buttonIndex);
    if(buttonIndex == 0){
        [self initImagePickerWithCamera:YES];
    }
    if(buttonIndex == 1){
        [self initImagePickerWithCamera:NO];
    }
}
-(void)closeKeyboard
{
    [userNick resignFirstResponder];
}


#pragma mark - UIImagePickerController
-(void)initImagePickerWithCamera:(BOOL)isCamera
{
    
    if (SYSVERSION >= 7.0) {
        NSString *mediaType = AVMediaTypeVideo; // Or AVMediaTypeAudio
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        if(authStatus == AVAuthorizationStatusRestricted){
            DEBUG_NSLOG(@"Camera Restricted");
        }
        else if(authStatus == AVAuthorizationStatusDenied){
            DEBUG_NSLOG(@"Camera Denied");
        }
        else if(authStatus == AVAuthorizationStatusAuthorized){
            DEBUG_NSLOG(@"Camera Authorized");
        }
        else if(authStatus == AVAuthorizationStatusNotDetermined){
            [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(granted){
                        // UI updates as needed
                        DEBUG_NSLOG(@"Granted access to %@", mediaType);
                    }
                    else {
                        // UI updates as needed
                        DEBUG_NSLOG(@"Not granted access to %@", mediaType);
                    }
                });
            }];
        }
        else {
            DEBUG_NSLOG (@"Unknown authorization status");
        }
        if (authStatus != AVAuthorizationStatusAuthorized) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"访问相机或相册授权失败"
                                                            message:@"「AR」无法使用您的相机或相册，你可以在「隐私设置」中启用。"
                                                           delegate:nil
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:nil,nil];
            
            [alert show];
            [alert release];
            return;
        }
    }
    
    if(imgPicker == nil)
        imgPicker= [[UIImagePickerController alloc] init];
    imgPicker.delegate = self;
    
    //调iphone的相机功能
    BOOL isHasCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    
    
    if(isHasCamera && isCamera){
        imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imgPicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:imgPicker.sourceType];
        imgPicker.videoQuality = UIImagePickerControllerQualityTypeLow;
        imgPicker.allowsEditing = YES;
        [self presentViewController:imgPicker animated:YES completion:nil];
    }
    else{
        imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imgPicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:imgPicker.sourceType];
        imgPicker.videoQuality = UIImagePickerControllerQualityTypeLow;
        imgPicker.allowsEditing = YES;
        [self presentViewController:imgPicker animated:YES completion:nil];
    }
}



#pragma mark - UIImagePickerController delegate 拍照
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    DEBUG_NSLOG(@"委托  UIImagePickerController");
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"])
    {
        UIImage *photoImage = [info objectForKey:UIImagePickerControllerEditedImage];
        if(photoImage == nil)
        {
            
            [picker dismissViewControllerAnimated:YES completion:nil];
            [[picker parentViewController] dismissViewControllerAnimated:YES completion:nil];
            return ;
        }
        UIImage * fixedImage = [ISSFileOp fixOrientation:photoImage];
        fixedImage = [ISSFileOp squareImageWithImage:fixedImage scaledToSize:CGSizeMake(150, 150)];
        [userHead setImage:fixedImage];
        
        NSString * headTmpPath = [ISSFileOp ReturnDocumentPath];
        headPath = [[NSString stringWithFormat:@"%@/tmp.png",headTmpPath] copy];
        [UIImageJPEGRepresentation(fixedImage, 1.0) writeToFile:headPath atomically:YES];
    }
    
    DEBUG_NSLOG(@"UIImagePickerController 消失");
    [picker dismissViewControllerAnimated:YES completion:nil];
    [[picker parentViewController] dismissViewControllerAnimated:YES completion:nil];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    DEBUG_NSLOG(@"%s",__FUNCTION__);
    [picker dismissViewControllerAnimated:YES completion:nil];
    [[picker parentViewController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- network
-(void)onFinish:(NSData *)data url:(NSString *)url
{
    DEBUG_NSLOG(@"%s",__FUNCTION__);
    UserInfoObj * dataObj = [DataParser parseUserInfo:data];
    if(dataObj != nil && dataObj.ErrorCode == 200){
        [appDelegate addUser:dataObj.userId userObj:dataObj];
        [appDelegate setCurUser:dataObj];
        [appDelegate showMsg:@"保存成功" hiddenTime:2];
    }
    else{
        if(STRNULL(dataObj.ErrorMsg).length > 0){
            [appDelegate showMsg:dataObj.ErrorMsg hiddenTime:2];
        }
    }
}
-(void)onNetError:(ErrorObject *)error
{
    
}
@end
