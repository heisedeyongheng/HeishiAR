//
//  TBViews.h
//  arproject
//
//  Created by 王健 on 16/11/13.
//  Copyright © 2016年 王健. All rights reserved.
//

#import <UIKit/UIKit.h>


#ifndef TBMargion_h
#define TBMargion_h
struct TBMargin {
    CGFloat l;
    CGFloat t;
    CGFloat r;
    CGFloat b;
};
typedef struct TBMargin TBMargin;
CG_INLINE TBMargin TBMargionMake(CGFloat l, CGFloat t, CGFloat r, CGFloat b)
{
    TBMargin margin;
    margin.l = l;
    margin.t = t;
    margin.r = r;
    margin.b = b;
    return margin;
}
#endif


@interface TBViews : UIView

@end

@interface TBButton : UIView
{
    UIImageView * iconView;
    UILabel * labView;
    UIButton * actionBtn;
    TBMargin imgMargin;
}
-(void)addTarget:(nullable id)target action:(SEL __nullable)action forControlEvents:(UIControlEvents)controlEvents;
-(void)setImgMargion:(TBMargin)margin;
-(void)setImgAndData:(NSString * __nullable)img data:(NSString * __nullable)data;
-(UIImageView * __nullable)getIconView;
-(UILabel * __nullable)getLabView;
@end


@interface TBScrollVIew : UIScrollView
{

}
@property BOOL isCloseKeyboardWhenTouch;
-(void)relayoutContentSize;
@end
