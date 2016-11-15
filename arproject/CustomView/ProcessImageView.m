//
//  ProcessImageView.m
//  Ubunta
//
//  Created by 王健 on 13-9-22.
//  Copyright (c) 2013年 wj. All rights reserved.
//

#import "ProcessImageView.h"
#import "Def.h"

@implementation ProcessImageView
@synthesize isHorizontally;
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        isHorizontally = NO;
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        isHorizontally = NO;
    }
    return self;
}
-(void)dealloc
{
    FREEOBJECT(completeImg);
    FREEOBJECT(unCompleteImg);
    [super dealloc];
}
-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    //填充透明
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    
    CGContextTranslateCTM(context, 0, self.frame.size.height);//变化坐标系
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSaveGState(context);
    CGPathRef completePath = [self getCompletePath];
    CGContextAddPath(context, completePath);
    CGContextClip(context);
    CGPathRelease(completePath);
    CGContextDrawImage(context, [self getImgRect:completeImg], completeImg.CGImage);
//    CGContextDrawTiledImage(context, [self getImgRect:completeImg], completeImg.CGImage);
    CGContextRestoreGState(context);
    
    CGContextSaveGState(context);
    CGPathRef unCompletePath = [self getUncompletePath];
    CGContextAddPath(context, unCompletePath);
    CGContextClip(context);
    CGPathRelease(unCompletePath);
    CGContextDrawImage(context, [self getImgRect:unCompleteImg], unCompleteImg.CGImage);
//    CGContextDrawTiledImage(context, [self getImgRect:unCompleteImg], unCompleteImg.CGImage);
    CGContextRestoreGState(context);
}
-(void)setImage:(UIImage *)complete unComplete:(UIImage *)unComplete
{
    FREEOBJECT(completeImg);
    FREEOBJECT(unCompleteImg);
    completeImg = complete;
    [completeImg retain];
    unCompleteImg = unComplete;
    [unCompleteImg retain];
}
-(CGPathRef)getUncompletePath
{
    CGRect rect = [self getImgRect:unCompleteImg];
    float width = isHorizontally ? (rect.size.width * (1.0-percent)) : rect.size.width;
    float height = isHorizontally ? rect.size.height : (rect.size.height * (1.0-percent));
    float x = rect.origin.x + (isHorizontally ? rect.size.width - width : 0);
    float y = rect.origin.y + (isHorizontally ? 0 : rect.size.height - height);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, x, y);
    CGPathAddLineToPoint(path, NULL, x + width, y);
    CGPathAddLineToPoint(path, NULL, x + width, height + y);
    CGPathAddLineToPoint(path, NULL, x, height + y);
    CGPathCloseSubpath(path);
    return path;
}
-(CGPathRef)getCompletePath
{
    CGRect rect = [self getImgRect:completeImg];
    float width = isHorizontally ? (rect.size.width * percent) : rect.size.width;
    float height = isHorizontally ? rect.size.height : (rect.size.height * percent);
    float x = rect.origin.x;
    float y = rect.origin.y;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, x, y);
    CGPathAddLineToPoint(path, NULL, x + width, y);
    CGPathAddLineToPoint(path, NULL, x + width, y + height);
    CGPathAddLineToPoint(path, NULL, x, y + height);
    CGPathCloseSubpath(path);
    return path;
}
-(CGRect)getImgRect:(UIImage*)img
{
    CGRect rect;
    float srcW = img.size.width;
    float srcH = img.size.height;
    float targetW = self.frame.size.width;
    float targetH = self.frame.size.height;
    float scale = 1.0;
    if(srcW > targetW)
        scale = targetW/srcW;
    else if(srcH > targetH)
        scale = targetH/srcH;
    float dstW = srcW*scale;
    float dstH = srcH*scale;
    rect.origin.x = (targetW - dstW)/2;
    rect.origin.y = (targetH - dstH)/2;
    rect.size.width = dstW;
    rect.size.height = dstH;
    return rect;
}
-(void)setProcess:(float)process
{
    percent = process;
    if(![NSThread isMainThread])
        [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
    else
        [self setNeedsDisplay];
}
@end
