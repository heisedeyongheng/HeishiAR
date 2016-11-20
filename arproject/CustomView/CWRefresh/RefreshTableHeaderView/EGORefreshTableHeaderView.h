//
//  EGORefreshTableHeaderView.h
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

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "SCGIFImageView.h"
#define  RefreshViewHight       65.0f

//#define ISUSEGIF

typedef enum{
	EGOOPullRefreshPulling = 0,
	EGOOPullRefreshNormal,
	EGOOPullRefreshLoading,	
} EGOPullRefreshState;


typedef enum {
    EGOOPullRefreshUp = 0,
    EGOOPullRefreshDown,
    EGOOPullRefreshNone,
}EGOPullRefreshDirection;


@protocol EGORefreshTableHeaderDelegate;
@interface EGORefreshTableHeaderView : UIView {
	
	id _delegate;
	EGOPullRefreshState _state;
    EGOPullRefreshDirection _direction;
    
	UILabel *_lastUpdatedLabel;
	UILabel *_statusLabel;
	CALayer *_arrowImage;
    SCGIFImageView * _gifArrowImage;
//	UIActivityIndicatorView *_activityView;
	
    NSString * upNormalText;
    NSString * upPullText;
    NSString * upLoadText;
    NSString * downNormalText;
    NSString * downPullText;
    NSString * downLoadText;
    NSTimer * rotateAnimationTimer;
//    BOOL    isRunningAnimation;
    float degrees;
    CGFloat RefreshViewBottomHight;
}

@property(nonatomic,assign) EGOPullRefreshDirection direction;
@property(nonatomic,assign) id <EGORefreshTableHeaderDelegate> delegate;
@property BOOL isNeedFixIOS7;
@property BOOL isAutoLoadMore;;
@property(nonatomic,copy) NSString * upNormalText;
@property(nonatomic,copy) NSString * upPullText;
@property(nonatomic,copy) NSString * upLoadText;
@property(nonatomic,copy) NSString * downNormalText;
@property(nonatomic,copy) NSString * downPullText;
@property(nonatomic,copy) NSString * downLoadText;
@property(nonatomic,copy) NSString * cacheDate;

- (void)refreshLastUpdatedDate;
- (void)setState:(EGOPullRefreshState)aState;
- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;
- (id) initWithFrame:(CGRect)frame byDirection:(EGOPullRefreshDirection) direc;


@end



@protocol EGORefreshTableHeaderDelegate
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view direction:(EGOPullRefreshDirection)direction;
- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view;
@optional
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view;
@end
