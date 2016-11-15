//
//  EGORefreshTableHeaderView.m
//  Demo
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "EGORefreshTableHeaderView.h"
#import "Def.h"

#define TEXT_COLOR	 [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define FLIP_ANIMATION_DURATION 0.18f


#define DegreesToRadians(x) ((x) * M_PI / 180.0)




@interface EGORefreshTableHeaderView (Private)
- (void) initControl;
- (void)setState:(EGOPullRefreshState)aState;
@end

@implementation EGORefreshTableHeaderView

@synthesize delegate = _delegate;
@synthesize direction = _direction;

@synthesize upLoadText,upPullText,upNormalText,downPullText,downLoadText,downNormalText,cacheDate;
@synthesize isNeedFixIOS7;
-(void) initControl
{
    upLoadText = @"";
    upPullText = @"";
    upNormalText = @"";
    downPullText = @"";
    downLoadText = @"";
    downNormalText = @"";
    isNeedFixIOS7 = NO;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    //self.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
    
    //    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, self.frame.size.height - 30.0f, self.frame.size.width, 20.0f)];
    //    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    //    label.font = [UIFont systemFontOfSize:12.0f];
    //    label.textColor = TEXT_COLOR;
    //    label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
    //    label.shadowOffset = CGSizeMake(0.0f, 1.0f);
    //    label.backgroundColor = [UIColor clearColor];
    //    label.textAlignment = UITextAlignmentCenter;
    //    [self addSubview:label];
    //    _lastUpdatedLabel=label;
    //    [label release];
    //
    //    label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, self.frame.size.height - 48.0f, self.frame.size.width, 20.0f)];
    //    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    //    label.font = [UIFont boldSystemFontOfSize:13.0f];
    //    label.textColor = TEXT_COLOR;
    //    label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
    //    label.shadowOffset = CGSizeMake(0.0f, 1.0f);
    //    label.backgroundColor = [UIColor clearColor];
    //    label.textAlignment = UITextAlignmentCenter;
    //    [self addSubview:label];
    //    _statusLabel=label;
    //    [label release];
    
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake((self.frame.size.width - 40.0f) /2, 10, 40.0f, 40.0f);
    layer.contentsGravity = kCAGravityResizeAspect;
    layer.contents = (id)[UIImage imageNamed:@"image_loading"].CGImage;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        layer.contentsScale = [[UIScreen mainScreen] scale];
    }
#endif
    
#ifndef ISUSEGIF
    [[self layer] addSublayer:layer];
    _arrowImage = layer;
#else
    //    UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    //    view.frame = CGRectMake(25.0f, self.frame.size.height - 38.0f, 20.0f, 20.0f);
    //    [self addSubview:view];
    //    _activityView = view;
    //    [view release];
    
    NSString * gifPath = [[NSBundle mainBundle] pathForResource:@"image_Loading.gif" ofType:nil];
    _gifArrowImage = [[[SCGIFImageView alloc] initWithGIFFile:gifPath] autorelease];
    _gifArrowImage.frame = CGRectMake((self.frame.size.width - 42) /2, 10, 42, 42);
    [self addSubview:_gifArrowImage];
    [_gifArrowImage stopAnimating];
    [_gifArrowImage setHidden:YES];
#endif
    
    [self setState:EGOOPullRefreshNormal];
}


- (id) initWithFrame:(CGRect)frame byDirection:(EGOPullRefreshDirection)direc
{
    if ((self = [super initWithFrame:frame])) {
        _direction = direc;
        [self initControl];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		
        _direction = EGOOPullRefreshUp; //默认上拉刷新
		[self initControl];
		
    }
	
    return self;
	
}





#pragma mark - Setters

- (void)refreshLastUpdatedDate {
	
	if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceLastUpdated:)]) {
        switch (_direction)
        {
                
            case EGOOPullRefreshUp:
                //                DEBUG_NSLOG(@"%s  >>>>>>>>>>>>>>>>>>>    EGOOPull Refresh  Up  ",__FUNCTION__);
                //                _lastUpdatedLabel.text = nil;
                break;
                
            case EGOOPullRefreshDown:
            {
                //                _lastUpdatedLabel.text = nil;
                
                //                DEBUG_NSLOG(@"%s  >>>>>>>>>>>>>>>>>>>    EGOOPull Refresh  Down  ",__FUNCTION__);
                
                //                if(downPullText.length == 0 && downLoadText.length == 0 && downNormalText.length == 0)
                //                {
                //
                //                    //NSString *tmpDate = [[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:@"%@%@",[[NSBundle mainBundle] bundleIdentifier],cacheDate]];
                //
                //                    if (cacheDate && cacheDate.length > 1) {
                //                        _lastUpdatedLabel.text = [NSString stringWithFormat:@"上次刷新: %@", cacheDate];
                //                    }
                //                    else
                //                    {
                //                        NSDate *date = [_delegate egoRefreshTableHeaderDataSourceLastUpdated:self];
                //                        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                //                        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                //
                //                        NSString *tmpDate = [ISSFileOp dateTimeToCNTime:[formatter stringFromDate:date]];
                //                        _lastUpdatedLabel.text = [NSString stringWithFormat:@"上次刷新: %@", tmpDate];
                //                        [formatter release];
                //                    }
                //                }
            }
                break;
                
            case EGOOPullRefreshNone:
                break;
        }
	} else {
        //		_lastUpdatedLabel.text = nil;
	}
    
}


#pragma mark - 转圈动画

- (void)rotateAnimationRun{
#ifndef ISUSEGIF
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    animation.duration = 0.4;
    animation.fromValue = [NSNumber numberWithFloat:0];
    animation.repeatCount = 100000;
    animation.cumulative = YES;
    animation.toValue = [NSNumber numberWithFloat:M_PI ];
    [_arrowImage addAnimation:animation forKey:@"refresh"];
#else
    [_gifArrowImage startAnimating];
#endif
}

- (void)rotateAnimationStop{
#ifndef ISUSEGIF
    [_arrowImage removeAnimationForKey:@"refresh"];
    _arrowImage.transform = CATransform3DIdentity;
#else
    [_gifArrowImage stopAnimating];
#endif
}


#pragma mark -
- (void)setState:(EGOPullRefreshState)aState{
	
	switch (aState) {
		case EGOOPullRefreshPulling:
			
            switch (_direction)
        {
                
            case EGOOPullRefreshUp:                                 //释放即刷新
                //                _statusLabel.text = upPullText.length > 0? upPullText : NSLocalizedString(@"放开 1 2 3 Go ...", @"Release to get more info");
                break;
                
            case EGOOPullRefreshDown:                               //释放即刷新
                //                _statusLabel.text = downPullText.length > 0? downPullText : NSLocalizedString(@"放开 1 2 3 Go ...", @"Release to refresh status");
                
                break;
                
        }
            //            DEBUG_NSLOG(@"EGOOPullRefreshPulling");
            //			[CATransaction begin];
            //			[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
            //			_arrowImage.transform = CATransform3DRotate(_arrowImage.transform,DegreesToRadians(180) , 0.0f, 0.0f, 1.0f);
            //			[CATransaction commit];
            
            
			_state = aState;
			break;
            
		case EGOOPullRefreshNormal:
            //            DEBUG_NSLOG(@"EGOOPullRefreshNormal");
            
            [self rotateAnimationStop];
#ifndef ISUSEGIF
			if (_state == EGOOPullRefreshPulling) {
				[CATransaction begin];
				[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
				_arrowImage.transform = CATransform3DIdentity;
				[CATransaction commit];
			}
#endif
            switch (_direction)
        {
                
            case EGOOPullRefreshUp:                    //上拉显示更多
                //                _statusLabel.text = upNormalText.length > 0? upNormalText : NSLocalizedString(@"使劲...", @"Pull up to get more info");
                break;
                
            case EGOOPullRefreshDown:                  //下拉刷新
                //                _statusLabel.text = downNormalText.length > 0? downNormalText : NSLocalizedString(@"使劲...", @"Pull down to refresh status");
                break;
                
            case EGOOPullRefreshNone:
                break;
                
        }
            
            //			[_activityView stopAnimating];
            
            
            _arrowImage.hidden = NO;
            
            //            [CATransaction begin];
            //			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            //			_arrowImage.hidden = NO;
            //			_arrowImage.transform = CATransform3DIdentity;
            //			[CATransaction commit];
			
            
			
            [self refreshLastUpdatedDate];
			_state = aState;
			break;
            
		case EGOOPullRefreshLoading:
            
            //            DEBUG_NSLOG(@"EGOOPullRefreshLoading");
            switch (_direction)
        {
                
            case EGOOPullRefreshUp:
                //                _statusLabel.text = upLoadText.length > 0? upLoadText : NSLocalizedString(LABEL_WARNING_LOADING, @"Loading Status");
                break;
                
            case EGOOPullRefreshDown:
                //                _statusLabel.text = downLoadText.length > 0? downLoadText : NSLocalizedString(LABEL_WARNING_LOADING, @"Loading Status");
                _state = aState;
                break;
                
            case EGOOPullRefreshNone:
                break;
                
        }
			
            //			[_activityView startAnimating];
            
            
            //            [CATransaction begin];
            //			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            //			_arrowImage.hidden = YES;
            //			[CATransaction commit];
			
            [self rotateAnimationRun];
            
            
			break;
            
		default:
            
            _state = aState;
			break;
	}
	
}


#pragma mark -
#pragma mark ScrollView Methods
//手指屏幕上不断拖动调用此方法
- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (_state == EGOOPullRefreshLoading) {
        
        
        CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
        
        offset = MIN(offset, 60);
        
        switch (_direction) {
            case EGOOPullRefreshUp:
                scrollView.contentInset = UIEdgeInsetsMake(-60.0, 0.0f, 0.0f, 0.0f);
                break;
                
            case EGOOPullRefreshDown:
                scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
                break;
                
            case EGOOPullRefreshNone:
                break;
        }
    }
    else if (scrollView.isDragging)
    {
        
        
        BOOL _loading = NO;
        
        if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
            _loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
            
        }
        
        
        switch (_direction) {
                
            case EGOOPullRefreshUp:
                //                DEBUG_NSLOG(@"上拉   ScrollView Did Scroll");
                if (_state == EGOOPullRefreshPulling && scrollView.contentOffset.y + (scrollView.frame.size.height) < scrollView.contentSize.height + RefreshViewHight && scrollView.contentOffset.y > 0.0f && !_loading) {
                    [self setState:EGOOPullRefreshNormal];
                } else if (_state == EGOOPullRefreshNormal && scrollView.contentOffset.y + (scrollView.frame.size.height) > scrollView.contentSize.height + RefreshViewHight  && !_loading) {
                    [self setState:EGOOPullRefreshPulling];
                    
                }
                
                break;
                
                
                
            case EGOOPullRefreshDown:
                
                if(!_loading)
                {
                    //                    DEBUG_NSLOG(@"下拉   ScrollView Did Scroll");
                    
                    //加转屏动画
                    
                    
                    
                    
                    //if (_state == EGOOPullRefreshPulling && scrollView.contentOffset.y > -(RefreshViewHight + 10) && scrollView.contentOffset.y < 0.0f )
                    if (scrollView.contentOffset.y > -(RefreshViewHight + 10) && scrollView.contentOffset.y < 0.0f )
                    {
                        //                        DEBUG_NSLOG(@"下拉   正常");
                        [self setState:EGOOPullRefreshNormal];
                    }
                    else if (_state == EGOOPullRefreshNormal && scrollView.contentOffset.y < -RefreshViewHight)
                    {
                        //                        DEBUG_NSLOG(@"下拉   显示释放");
                        [self setState:EGOOPullRefreshPulling];
                        
                    }
                }
                
                break;
            case EGOOPullRefreshNone:
                break;
        }
        if (scrollView.contentInset.bottom != 0) {
            scrollView.contentInset = UIEdgeInsetsZero;
            
        }
    }
    
    
}




- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
    
	BOOL _loading = NO;
	if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
		_loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
	}
    
    switch (_direction) {
            
        case EGOOPullRefreshUp:
            
            //            DEBUG_NSLOG(@"上拉   ScrollView Did End Dragging");
            if (scrollView.contentOffset.y + (scrollView.frame.size.height) > scrollView.contentSize.height + RefreshViewHight && !_loading)
            {
                if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDidTriggerRefresh:direction:)])
                {
                    [_delegate egoRefreshTableHeaderDidTriggerRefresh:self direction:_direction];
                }
                [self setState:EGOOPullRefreshLoading];
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.2];
                scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, RefreshViewHight, 0.0f);
                [UIView commitAnimations];
            }
            break;
            
        case EGOOPullRefreshDown:
            
            //            DEBUG_NSLOG(@"下拉   ScrollView Did End Dragging   scrollView.contentOffset.y = %.2f",scrollView.contentOffset.y);
            if (scrollView.contentOffset.y <= (-RefreshViewHight) && !_loading)
            {
                if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDidTriggerRefresh:direction:)]) {
                    [_delegate egoRefreshTableHeaderDidTriggerRefresh:self direction:_direction];
                }
                
                [self setState:EGOOPullRefreshLoading];
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.2];
                scrollView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
                [UIView commitAnimations];
            }
            
            break;
            
    }
    
    
    
	
}

- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {
    
    //if(scrollView.contentInset.bottom-scrollView.contentInset.top != RefreshViewHight)
    {
        
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        _arrowImage.hidden = YES;
        [CATransaction commit];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.3];
        //        DEBUG_NSLOG(@"scrollView.contentInset.top = %.2f  , scrollView.frame.origin.y == %.2f",scrollView.contentInset.top,scrollView.frame.origin.y);
        
        
        DEBUG_NSLOG(@"[[[UIDevice currentDevice] systemVersion] floatValue]  ===> %.2f   ,  isNeedFixIOS7  ==== >>>> %d  ，  scrollView.frame.origin.y ==== 》 %.2f",[[[UIDevice currentDevice] systemVersion] floatValue],isNeedFixIOS7,scrollView.frame.origin.y);
        
        
        
        
        
        if (scrollView.frame.origin.y <= 100.0f) {//modify by wj
//        if (scrollView.frame.origin.y <= 1.0f) {
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
                
                if ([scrollView.delegate isKindOfClass:[UITableViewController class]] == YES)
                {
                    if (isNeedFixIOS7 == NO) {
                        DEBUG_NSLOG(@"\n\n-----------------------  \n%s \n\n[UITableViewController class] == YES isNeedFixIOS7  == NO  ====> %@ \n\n----------------- \n",__FUNCTION__, NSStringFromCGRect(CGRectMake(0, 0, 0, 0)));
                        [scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
                    }
                    else if (isNeedFixIOS7) {
                        DEBUG_NSLOG(@"\n\n-----------------------  \n%s \n\n[UITableViewController class] == YES isNeedFixIOS7  == YES  ====> %@ \n\n----------------- \n",__FUNCTION__, NSStringFromCGRect(CGRectMake(64, 0, 0, 0)));
                        [scrollView setContentInset:UIEdgeInsetsMake(64.0f, 0.0f, 0.0f, 0.0f)];
                    }
                    
                }
                else if ([scrollView.delegate isKindOfClass:[UIViewController class]] == YES)
                {
                    [scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];                    
                }
                else if (isNeedFixIOS7 == NO) {
                    DEBUG_NSLOG(@"\n\n-----------------------  \n%s \n\n isNeedFixIOS7  ====> %@ \n\n----------------- \n",__FUNCTION__, NSStringFromCGRect(CGRectMake(0, 0, 0, 0)));
                    [scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
                }
                else if (isNeedFixIOS7) {
                    DEBUG_NSLOG(@"\n\n-----------------------  \n%s \n\n isNeedFixIOS7  ====> %@ \n\n----------------- \n",__FUNCTION__, NSStringFromCGRect(CGRectMake(64, 0, 0, 0)));
                    [scrollView setContentInset:UIEdgeInsetsMake(64.0f, 0.0f, 0.0f, 0.0f)];
                }
                
            }
            else{
                [scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
            }
            
        }
        else{
//            DEBUG_NSLOG(@"-----------------------  %s  ----------------- \n\n < iOS7  ====> %@",__FUNCTION__, NSStringFromCGRect(CGRectMake(0, 0, 0, 0)));
            [scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
        }
        
        
        
        
        [UIView commitAnimations];
    }
    [self setState:EGOOPullRefreshNormal];
}




#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	
	_delegate = nil;
	_arrowImage = nil;
    //	_activityView = nil;
    //	_statusLabel = nil;
    //	_lastUpdatedLabel = nil;
    [super dealloc];
}


@end
