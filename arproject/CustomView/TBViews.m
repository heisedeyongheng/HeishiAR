//
//  TBViews.m
//  arproject
//
//  Created by 王健 on 16/11/13.
//  Copyright © 2016年 王健. All rights reserved.
//

#import "TBViews.h"
#import "ISSFileOp.h"
#import "Def.h"

@implementation TBViews

@end

@implementation TBButton
-(id)init
{
    self = [super init];
    [self initControls];
    return self;
}
-(void)dealloc
{
    FREEOBJECT(iconView);
    FREEOBJECT(labView);
    [super dealloc];
}
-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self reLayoutSub];
}
-(void)initControls
{
    imgMargin.l = imgMargin.t = imgMargin.r = imgMargin.b = 0.0f;
    iconView = [[UIImageView alloc] init];
    [iconView setContentMode:UIViewContentModeScaleAspectFit];
    [self addSubview:iconView];
    labView = [[UILabel alloc] init];
    [labView setFont:[UIFont systemFontOfSize:12]];
    [labView setTextColor:RGBACOLOR(180, 180, 180, 1)];
    [self addSubview:labView];
    actionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [actionBtn setContentMode:UIViewContentModeScaleAspectFill];
    [actionBtn setBackgroundImage:[ISSFileOp getImgByColor:RGBACOLOR(0, 0, 0, 0.3) size:CGSizeMake(1, 1)] forState:UIControlStateHighlighted];
    [self addSubview:actionBtn];
}
-(void)reLayoutSub
{
    CGFloat w = self.frame.size.width - (imgMargin.l + imgMargin.r);
    CGFloat h = self.frame.size.height - (imgMargin.t + imgMargin.b);
    CGFloat iconW = MIN(w,h);
    [iconView setFrame:CGRectMake(imgMargin.l, imgMargin.t, iconW, iconW)];
    [labView setFrame:CGRectMake(OBJRIGHT(iconView) + imgMargin.r, 0, self.frame.size.width - OBJRIGHT(iconView) - imgMargin.r, self.frame.size.height)];
    [actionBtn setFrame:self.bounds];
    [super setNeedsLayout];
}
-(void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [actionBtn addTarget:target action:action forControlEvents:controlEvents];
}
-(void)setImgMargion:(TBMargin)margin
{
    imgMargin = margin;
    [self reLayoutSub];
}
-(void)setImgAndData:(NSString *)img data:(NSString *)data
{
    [iconView setImage:[UIImage imageNamed:img]];
    [labView setText:data];
}
-(UIImageView*)getIconView
{
    return iconView;
}
-(UILabel*)getLabView
{
    return labView;
}
@end


@implementation TBScrollVIew
@synthesize isCloseKeyboardWhenTouch;
-(id)init
{
    self = [super init];
    isCloseKeyboardWhenTouch = NO;
    return self;
}
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    isCloseKeyboardWhenTouch = NO;
    return self;
}
-(void)relayoutContentSize
{
    for(UIView * sub in self.subviews){
        CGFloat bottom = OBJBOTTOM(sub);
        if(bottom > self.contentSize.height){
            self.contentSize = CGSizeMake(self.frame.size.width, bottom);
        }
    }
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    if(isCloseKeyboardWhenTouch){
        for(UIView * sub in self.subviews){
            [sub resignFirstResponder]; 
        }
    }
}
@end
