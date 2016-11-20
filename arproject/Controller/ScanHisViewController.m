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

@implementation HisCell
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    return self;
}
-(void)dealloc
{
    FREEOBJECT(logoImage);
    FREEOBJECT(nameLab);
    FREEOBJECT(timeLab);
    [super dealloc];
}
-(void)initControls
{
    TBMargin margin = TBMargionMake(10, 10, 10, 10);
    CGFloat imgS = [HisCell cellH] - margin.t - margin.b;
    logoImage = [[ISSAsyncImageView alloc] init];
    [logoImage setFrame:CGRectMake(margin.l, margin.t, imgS, imgS)];
    [logoImage setIsUseSuperContentMode:YES];
    [logoImage setContentMode:UIViewContentModeScaleAspectFit];
    [self.contentView addSubview:logoImage];
    CGFloat nameLabW = appDelegate.screenWidth - margin.l - margin.r - 5;
    nameLab = [[UILabel alloc] init];
    [nameLab setFrame:CGRectMake(OBJRIGHT(logoImage) + 5, logoImage.frame.origin.y, nameLabW, CGRectGetHeight(logoImage.frame)/2)];
    [nameLab setBackgroundColor:[UIColor clearColor]];
    [nameLab setFont:[UIFont systemFontOfSize:14]];
    [self.contentView addSubview:nameLab];
    timeLab = [[UILabel alloc] init];
    [timeLab setFrame:CGRectMake(OBJRIGHT(logoImage) + 5, OBJBOTTOM(nameLab), nameLabW, CGRectGetHeight(logoImage.frame)/2)];
    [timeLab setBackgroundColor:[UIColor clearColor]];
    [timeLab setFont:[UIFont systemFontOfSize:14]];
    [self.contentView addSubview:timeLab];
}
-(void)setData:(ScanHisObj *)data
{
    if(data == nil)return;
    [logoImage loadImageFromCache:data.logoUrl isCancelLast:YES];
    [nameLab setText:data.name];
    [timeLab setText:data.time];
}
+(CGFloat)cellH
{
    return 60;
}
@end


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
    FREEOBJECT(dataList);
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
    
    MJRefreshNormalHeader *refreshHeader = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(onPullRefresh)];
    refreshHeader.lastUpdatedTimeLabel.hidden = YES;
    mainTable.mj_header = refreshHeader;
    MJRefreshAutoFooter *refreshFooter = [MJRefreshAutoFooter footerWithRefreshingTarget: self refreshingAction:@selector(onPullLoadMore)];
    refreshFooter.triggerAutomaticallyRefreshPercent = -10;
    // 忽略掉底部inset
    mainTable.mj_footer.ignoredScrollViewContentInsetBottom = 44;
    mainTable.mj_footer = refreshFooter;
    
    dataList = [[NSMutableArray alloc] init];
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
    return dataList.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * identifier = @"cell";
    NSInteger row = [indexPath row];
    HisCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    ScanHisObj * data = [dataList objectAtIndex:row];
    if(cell == nil){
        cell = [[[HisCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
    }
    [cell setData:data];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [HisCell cellH];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - event response
-(void)onPullRefresh
{
    DEBUG_NSLOG(@"%s",__FUNCTION__);
//    pageno = 1;
//    [self loadDataFromNet];
}
-(void)onPullLoadMore
{
    DEBUG_NSLOG(@"%s",__FUNCTION__);
//    if (pageno >= allpage) {
//        [mainTable.mj_footer endRefreshingWithNoMoreData];
//    }else{
//        pageno ++;
//        [self loadDataFromNet];
//    }
    
//    if (pageno < allpage) {
//        [mainTable.mj_footer resetNoMoreData];
//    }else{
//        [mainTable.mj_footer endRefreshingWithNoMoreData];
//    }
}
-(void)endDataMJRefres
{
    
    if (pageno < allpage) {
        [mainTable.mj_footer resetNoMoreData];
    }else{
        [mainTable.mj_footer endRefreshingWithNoMoreData];
    }
}
#pragma mark - network
-(void)onFinish:(NSData *)data url:(NSString *)url
{

}
-(void)onNetError:(ErrorObject *)error
{

}
@end
