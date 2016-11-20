//
//  ScanHisViewController.h
//  arproject
//
//  Created by 王健 on 16/11/20.
//  Copyright © 2016年 王健. All rights reserved.
//

#import "BaseViewController.h"
#import "MJRefresh.h"

@interface HisCell : UITableViewCell

@end


@interface ScanHisViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate,SZMGConnectDelegate>
{
    UITableView * mainTable;
    NSInteger pageno;
    NSInteger allpage;
}
@end
