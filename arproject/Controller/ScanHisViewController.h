//
//  ScanHisViewController.h
//  arproject
//
//  Created by 王健 on 16/11/20.
//  Copyright © 2016年 王健. All rights reserved.
//

#import "BaseViewController.h"
#import "CWRefreshTableView.h"

@interface ScanHisViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate,SZMGConnectDelegate,CWRefreshTableViewDelegate>
{
    CWRefreshTableView * refreshHeaderView;
    UITableView * mainTable;
}
@end
