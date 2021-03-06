//
//  ScanHisViewController.h
//  arproject
//
//  Created by 王健 on 16/11/20.
//  Copyright © 2016年 王健. All rights reserved.
//

#import "BaseViewController.h"
#import "MJRefresh.h"
#import "ISSAsyncImageView.h"
#import "SZMGConnect.h"

@interface HisCell : UITableViewCell
{
    ISSAsyncImageView * logoImage;
    UILabel * nameLab;
    UILabel * timeLab;
}
-(void)setData:(ScanHisObj*)data;
+(CGFloat)cellH;
@end


@interface ScanHisViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate,SZMGConnectDelegate>
{
    UITableView * mainTable;
    NSMutableArray * dataList;
    NSInteger pageno;
    NSInteger allpage;
}
@end
