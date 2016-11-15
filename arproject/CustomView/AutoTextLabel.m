//
//  AuoTextLabel.m
//  Ubunta
//
//  Created by 王健 on 13-9-7.
//  Copyright (c) 2013年 wj. All rights reserved.
//
#import "ISSFileOp.h"
#import "AutoTextLabel.h"

@implementation AutoTextLabel
@synthesize anchor;
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        [self setLineBreakMode:NSLineBreakByCharWrapping];
        [self setNumberOfLines:0];
        anchor = LEFTTOP;
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setLineBreakMode:NSLineBreakByCharWrapping];
        [self setNumberOfLines:0];
        anchor = LEFTTOP;
    }
    return self;
}
-(void)dealloc
{
    [super dealloc];
}

-(void)setText:(NSString *)text
{
    [self setTextWithMaxSize:text maxSize:CGSizeMake(1000, 1000)];
}


-(void)setTextWithMaxSize:(NSString *)text maxSize:(CGSize)maxSize
{
    if(text == nil || text.length == 0)
        return;
    int x = self.frame.origin.x;
    int y = self.frame.origin.y;
    [super setText:text];
    
    CGSize contentSize = [ISSFileOp getContentSizeWithString:text
                                                     maxSize:maxSize
                                                        font:self.font];
    
    
    //    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
    //
    //        NSMutableParagraphStyle *paragraphStyle = [[[NSMutableParagraphStyle alloc]init] autorelease];
    //        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    //        NSDictionary *attributes = @{NSFontAttributeName:self.font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    //
    //        contentSize = [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    //
    //    }
    //    else{
    //         contentSize = [text sizeWithFont:self.font constrainedToSize:maxSize lineBreakMode:NSLineBreakByCharWrapping];
    //    }
    
    
    if(anchor == LEFTTOP)
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, contentSize.width, contentSize.height)];
    else if(anchor == CENTER)
    {
        if(self.frame.size.width > contentSize.width)
            x = self.center.x - contentSize.width/2;
        if(self.frame.size.height > contentSize.height)
            y = self.center.y - contentSize.height/2;
        [self setFrame:CGRectMake(x, y,contentSize.width, contentSize.height)];
    }
    
}
@end
