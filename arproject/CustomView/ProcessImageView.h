//
//  ProcessImageView.h
//  Ubunta
//
//  Created by 王健 on 13-9-22.
//  Copyright (c) 2013年 wj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProcessImageView : UIView
{
    UIImage * completeImg;
    UIImage * unCompleteImg;
    float percent;
}
@property BOOL isHorizontally;
-(void)setProcess:(float)process;
-(void)setImage:(UIImage*)complete unComplete:(UIImage*)unComplete;
@end
