//
//  ScanHisViewController.m
//  arproject
//
//  Created by 王健 on 16/11/20.
//  Copyright © 2016年 王健. All rights reserved.
//

#import "ScanHisViewController.h"
#import "ISSFileOp.h"
#import "AppDelegate.h"

extern AppDelegate * appDelegate;

@implementation ScanHisViewController
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}
-(void)dealloc
{
    DEBUG_NSLOG(@"%s",__FUNCTION__);
    FREEOBJECT(mainTable);
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
    [self setNavBg:self title:@"历史记录" back:@"" right:nil];
    
    [mainScroll removeFromSuperview];
    mainTable = [[UITableView alloc] init];
    [mainTable setFrame:[self getMainTableFrame]];
    [mainTable setDataSource:self];
    [mainTable setDelegate:self];
    [mainTable  setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [mainTable  setSeparatorColor:[UIColor clearColor]];
    [mainTable setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:mainTable];
    
    refreshHeaderView = [[CWRefreshTableView alloc] initWithTableView:mainTable pullDirection:CWRefreshTableViewDirectionDown];
    [refreshHeaderView setIsNeedFixIOS7:YES];
    refreshHeaderView.delegate = self;
    
    [mainTable setContentSize:CGSizeMake(appDelegate.screenWidth, 2000)];
}
#pragma mark -- action
-(void)backAction:(UIButton *)btn
{
    [self.navigationController popToRootViewControllerAnimated:NO];
    [appDelegate hideTopNav:YES];
}
#pragma mark - Table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 30;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] autorelease];
    [cell.textLabel setText:@"hhhh"];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark - UITableViewDelegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [refreshHeaderView scrollViewDidScroll:scrollView];
    if(mainTable.contentOffset.y + mainTable.frame.size.height > mainTable.contentSize.height - 200){
        DEBUG_NSLOG(@"加载更多");
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [refreshHeaderView scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}
- (void)doneLoadingTableViewData{
    [refreshHeaderView DataSourceDidFinishedLoading];
}

#pragma mark -CWRefreshTableViewDelegate
-(BOOL)CWRefreshTableViewReloadTableViewDataSource:(CWRefreshTableViewPullType)refreshType
{
    if(refreshType == CWRefreshTableViewPullTypeLoadMore)
    {//下拉
        DEBUG_NSLOG(@"加载更多");
    }
    if(refreshType == CWRefreshTableViewPullTypeReload)
    {//上拉
        DEBUG_NSLOG(@"重现加载");
        
    }
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.5];
    return  YES;
}
@end
