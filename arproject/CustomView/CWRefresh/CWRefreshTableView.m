//------------------------------------------------------------------------------------------------------
//  CWRefreshTableView.m
//  TableViewPull
//
//  Created by  on 11-11-24.
//  Copyright (c) 2011年 . All rights reserved.
//



#import "CWRefreshTableView.h"
//#import "ChatTool.h"
#import "Def.h"

@interface CWRefreshTableView(Private)



- (void) initControl;
- (void) initPullDownView;
- (void) initPullUpView;
- (void) initPullAllView;
- (void) updatePullViewFrame;



@end



@implementation CWRefreshTableView
@synthesize pullTableView = _pullTableView;
@synthesize delegate = _delegate,isNeedFixIOS7,isAuoLoadMore;
@synthesize lastUpdateText;
@synthesize direction;

- (id) initWithTableView:(UIScrollView *)tView
           pullDirection:(CWRefreshTableViewDirection) cwDirection
{
    
    if ((self = [super init]))
    {
        _pullTableView = tView;
        _direction = cwDirection;
        
        lastUpdateText = nil;
        [self initControl];
    }
    return self;
    
}


- (id) initWithTableView:(UIScrollView *)tView
           pullDirection:(CWRefreshTableViewDirection) cwDirection
              lastUpdateText:(NSString *)_lastUpdateText
{
    
    if ((self = [super init]))
    {
        _pullTableView = tView;
        _direction = cwDirection;

        if (_lastUpdateText) {
            lastUpdateText = _lastUpdateText;
            [lastUpdateText retain];
        }
        

        [self initControl];
    }
    return self;
    
}


-(id)initWithTableView:(UIScrollView *)tView
         pullDirection:(CWRefreshTableViewDirection)cwDirection
                upPull:(NSString *)_upPullText
              upNormal:(NSString *)_upNormalText
                upLoad:(NSString *)_upLoadlText
              downPull:(NSString *)_downPullText
            downNormal:(NSString *)_downNormalText
              downLoad:(NSString *)_downLoadText
{
    if ((self = [super init]))
    {
        upNormalText = [_upNormalText copy];
        upLoadText = [_upLoadlText copy];
        upPullText = [_upPullText copy];
        downNormalText = [_downNormalText copy];
        downLoadText = [_downLoadText copy];
        downPullText = [_downPullText copy];

        _pullTableView = tView;
        _direction = cwDirection;
        lastUpdateText = nil;
        [self initControl];
    }
    return self;
}


-(void)dealloc
{
    _footerView.delegate = nil;
    _headView.delegate = nil;
    FREEOBJECT(upNormalText);
    FREEOBJECT(upLoadText);
    FREEOBJECT(upPullText);
    FREEOBJECT(downNormalText);
    FREEOBJECT(downLoadText);
    FREEOBJECT(downPullText);
    FREEOBJECT(lastUpdateText);
    [super dealloc];
}

#pragma mark - private
- (void) initControl
{
    isNeedFixIOS7 = NO;
    isAuoLoadMore = NO;
    switch (_direction) {
            
        case CWRefreshTableViewDirectionUp:
            [self initPullUpView];
            break;
            
        case CWRefreshTableViewDirectionDown:
            [self initPullDownView];
            break;
            
        case CWRefreshTableViewDirectionAll:
            [self initPullAllView];
            break;
            
    }
    
}


-(void)setIsNeedFixIOS7:(BOOL)isFixIOS7{
    isNeedFixIOS7 = isFixIOS7;
    if (_headView) {
        [_headView setIsNeedFixIOS7:isNeedFixIOS7];
    }
    if (_footerView) {
        [_footerView setIsNeedFixIOS7:isNeedFixIOS7];
    }
}
-(void)setIsAuoLoadMore:(BOOL)isAuoLoadMorePar
{
    isAuoLoadMore = isAuoLoadMorePar;
    if (_headView) {
        [_headView setIsAutoLoadMore:isAuoLoadMore];
    }
    if (_footerView) {
        [_footerView setIsAutoLoadMore:isAuoLoadMore];
    }
}

- (void) initPullDownView
{
    CGFloat fWidth = _pullTableView.frame.size.width;
    CGFloat originY = _pullTableView.contentSize.height;
    
    if (originY < _pullTableView.frame.size.height)
    {
        originY = _pullTableView.frame.size.height;
    }
    
    
    EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -RefreshViewHight, fWidth, RefreshViewHight)
                                                                           byDirection:EGOOPullRefreshDown];
    
    view.delegate = self;
    [_pullTableView addSubview:view];
    view.autoresizingMask = _pullTableView.autoresizingMask;
    view.upNormalText = upNormalText;
    view.upLoadText = upLoadText;
    view.upPullText = upPullText;
    view.downLoadText = downLoadText;
    view.downNormalText = downNormalText;
    view.downPullText = downPullText;
    [view setState:EGOOPullRefreshNormal];

    if (lastUpdateText) {
        [view setCacheDate:lastUpdateText];
    }

    _headView = view;
    [view release];
    [_headView refreshLastUpdatedDate];
    
}



- (void) initPullUpView
{
    CGFloat fWidth = _pullTableView.frame.size.width;
    
    if ([_pullTableView isMemberOfClass:[UITableView class]])
    {
        UITableView *tabview = (UITableView *)_pullTableView;
        if (tabview.style == UITableViewStyleGrouped) {
            
            //        fWidth = fWidth - 40;
            
        }
    }
    
    CGFloat originY = _pullTableView.contentSize.height;
    CGFloat originX = _pullTableView.contentOffset.x;
    
    if (originY < _pullTableView.frame.size.height) {
        originY = _pullTableView.frame.size.height;
    }
    
    EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(originX, originY, fWidth, RefreshViewHight)
                                                                           byDirection:EGOOPullRefreshUp];

    view.delegate = self;
    [_pullTableView addSubview:view];
    
    view.autoresizingMask = _pullTableView.autoresizingMask;
    view.upNormalText = upNormalText;
    view.upLoadText = upLoadText;
    view.upPullText = upPullText;
    view.downLoadText = downLoadText;
    view.downNormalText = downNormalText;
    view.downPullText = downPullText;
    [view setState:EGOOPullRefreshNormal];
    _footerView = view;
    
    [view release];
    [_footerView refreshLastUpdatedDate];
    
}

- (void) initPullAllView
{
    [self initPullUpView];
    [self initPullDownView];
}

- (void) updatePullViewFrame
{
    
    if (_headView != nil) {
        
    }
    
    if (_footerView != nil) {
        
        CGFloat fWidth = _pullTableView.frame.size.width;
        CGFloat originY = _pullTableView.contentSize.height;
        CGFloat originX = _pullTableView.contentOffset.x;
        
        if (originY < _pullTableView.frame.size.height) {
            originY = _pullTableView.frame.size.height;
        }
        if (!CGRectEqualToRect(_footerView.frame, CGRectMake(originX, originY, fWidth, RefreshViewHight))) {
            _footerView.frame = CGRectMake(originX, originY, fWidth, RefreshViewHight);
        }
        
    }
    
}


-(void)setScrollViewDidEndDragging:(UIScrollView *)scrollView
{
    [_headView egoRefreshScrollViewDidEndDragging:scrollView];
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    
    direction = EGOOPullRefreshNone;
    
    if (scrollView.contentOffset.y < (-RefreshViewHight)) {
        [_headView egoRefreshScrollViewDidScroll:scrollView];
        direction = EGOOPullRefreshDown;
    }
    else if (scrollView.contentOffset.y >  RefreshViewHight)
    {
        [_footerView egoRefreshScrollViewDidScroll:scrollView];
        direction = EGOOPullRefreshUp;
    }
    
    [self updatePullViewFrame];
    
}



- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    if (scrollView.contentOffset.y < -RefreshViewHight) {
        [_headView egoRefreshScrollViewDidEndDragging:scrollView];
    }
    else if (scrollView.contentOffset.y > RefreshViewHight)
    {
        [_footerView egoRefreshScrollViewDidEndDragging:scrollView];
    }
    
}

-(void)setLastUpdateText:(NSString *)_lastUpdateText
{
    [_headView setCacheDate:_lastUpdateText];
}


#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void) DataSourceDidFinishedLoading
{
    _reloading = NO;
    [_headView egoRefreshScrollViewDataSourceDidFinishedLoading:_pullTableView];
    [_footerView egoRefreshScrollViewDataSourceDidFinishedLoading:_pullTableView];
    [self updatePullViewFrame];
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
                                     direction:(EGOPullRefreshDirection)direc
{
    if (_delegate != nil && [_delegate respondsToSelector:@selector(CWRefreshTableViewReloadTableViewDataSource:)]) {
        
        if (direc == EGOOPullRefreshUp) {
            _reloading = [_delegate CWRefreshTableViewReloadTableViewDataSource:CWRefreshTableViewPullTypeLoadMore];
        }
        else if (direc == EGOOPullRefreshDown)
        {
            _reloading = [_delegate CWRefreshTableViewReloadTableViewDataSource:CWRefreshTableViewPullTypeReload];
        }
        
    }
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
    return _reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
    return [NSDate date]; // should return date data source was last changed
}

@end
