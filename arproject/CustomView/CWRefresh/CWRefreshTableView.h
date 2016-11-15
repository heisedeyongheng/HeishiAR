//-------------------------------------------------------------------------------------------------------
//
//  CWRefreshTableView.h
//  TableViewPull
//
//  Created by  on 11-11-24.
//  Copyright (c) 2011年 . All rights reserved.
//


#import <Foundation/Foundation.h>
#import "EGORefreshTableHeaderView.h"


//#define FREEOBJECT(obj)         if(obj != nil){[obj release]; obj = nil;}
//pull direction
typedef enum
{
    CWRefreshTableViewDirectionUp,
    CWRefreshTableViewDirectionDown,
    CWRefreshTableViewDirectionAll,
}CWRefreshTableViewDirection;



//pull type
typedef enum
{
    CWRefreshTableViewPullTypeReload,           //从新加载
    CWRefreshTableViewPullTypeLoadMore,         //加载更多
}CWRefreshTableViewPullType;



@protocol CWRefreshTableViewDelegate;

@interface CWRefreshTableView : NSObject< EGORefreshTableHeaderDelegate , UIScrollViewDelegate >
{
    
    BOOL                        _reloading;
    EGORefreshTableHeaderView  *_headView;
    EGORefreshTableHeaderView  *_footerView;
    CWRefreshTableViewDirection    _direction;
    
    NSString * upNormalText;
    NSString * upPullText;
    NSString * upLoadText;
    NSString * downNormalText;
    NSString * downPullText;
    NSString * downLoadText;
    
}
@property (nonatomic) BOOL isNeedFixIOS7;
@property (readonly) EGOPullRefreshDirection direction;
@property (nonatomic, assign) UIScrollView  *pullTableView;
@property (nonatomic, assign) id<CWRefreshTableViewDelegate> delegate;
@property (nonatomic, retain) NSString *lastUpdateText;

//方向
- (id) initWithTableView:(UIScrollView *) tView
           pullDirection:(CWRefreshTableViewDirection) cwDirection;

- (id) initWithTableView:(UIScrollView *)tView
           pullDirection:(CWRefreshTableViewDirection) cwDirection
          lastUpdateText:(NSString *)_lastUpdateText;

- (id) initWithTableView:(UIScrollView *) tView
           pullDirection:(CWRefreshTableViewDirection) cwDirection
                  upPull:(NSString*)_upPullText
                upNormal:(NSString*)_upNormalText
                  upLoad:(NSString*)_upLoadlText
                downPull:(NSString*)_downPullText
              downNormal:(NSString*)_downNormalText
                downLoad:(NSString*)_downLoadText;

//加载完成调用
- (void) DataSourceDidFinishedLoading;

-(void)setScrollViewDidEndDragging:(UIScrollView *)scrollView;

@end


@protocol CWRefreshTableViewDelegate <NSObject>

//从新加载
- (BOOL) CWRefreshTableViewReloadTableViewDataSource:(CWRefreshTableViewPullType) refreshType;
@end

