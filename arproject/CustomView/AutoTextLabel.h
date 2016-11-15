//
//  AuoTextLabel.h
//  Ubunta
//
//  Created by 王健 on 13-9-7.
//  Copyright (c) 2013年 wj. All rights reserved.
//

#import <UIKit/UIKit.h>

enum AutoTextAnchor{
    LEFTTOP = 1,
    CENTER,
    RIGHTBOTTOM
};

@interface AutoTextLabel : UILabel
@property int anchor;
-(void)setTextWithMaxSize:(NSString *)text maxSize:(CGSize)maxSize;
@end
