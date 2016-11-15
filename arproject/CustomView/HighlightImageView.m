//
//  HighlightImageView.m
//  Order
//
//  Created by Huang Cheng on 13-10-16.
//
//

#import "HighlightImageView.h"
#import "Def.h"
#import <QuartzCore/QuartzCore.h>
@implementation HighlightImageView


@synthesize imageName,isHighLight;
-(id)initWithFrame:(CGRect)frame imageName:(NSString *)fileName
{
    self = [super initWithFrame:frame];
    if (self) {
        self.image = [UIImage imageNamed:fileName];
        [self setHighlighted:NO];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        maskImageView = nil;
                [self setHighlighted:NO];
    }
    return self;
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if(maskImageView != nil)
    {
        maskImageView.frame = CGRectMake(0, 0,  self.frame.size.width,  self.frame.size.height);
        maskImageView.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);
        float width =  self.image.size.width * self.frame.size.height / self.image.size.height;
        if (width >= self.frame.size.width)
            maskImageView.layer.mask.frame = CGRectMake(0, 0, width,  self.frame.size.height);
        else
            maskImageView.layer.mask.frame = CGRectMake((self.frame.size.width - width) / 2.0, 0, width,  self.frame.size.height);
        maskImageView.layer.mask.contents = (id)self.image.CGImage;
    }
}
-(void)dealloc
{
    [super dealloc];
}


-(void)setHighlighted:(BOOL)highlighted
{
    
    if (self.image) {
        UIImage *mask = self.image;
        
        self.image = mask;
        
        if (maskImageView == nil) {
            maskImageView = [[UIImageView alloc] init];
            maskImageView.frame = CGRectMake(0, 0,  self.frame.size.width,  self.frame.size.height);
            maskImageView.backgroundColor = [UIColor blackColor];
            maskImageView.alpha = 0.4f;

            maskImageView.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);
            
            
            CALayer* maskLayer = [[CALayer layer] retain];
            
            float width =  self.image.size.width * self.frame.size.height / self.image.size.height;

            if (width >= self.frame.size.width) {
                maskLayer.frame = CGRectMake(0, 0, width,  self.frame.size.height);
            }
            else
            {
                maskLayer.frame = CGRectMake((self.frame.size.width - width) / 2.0, 0, width,  self.frame.size.height);
            }
            
            maskLayer.contents = (id)[mask CGImage];
            [maskLayer setMasksToBounds:YES];
            [maskImageView.layer setMask:maskLayer];
            [maskLayer release];
            
            [self addSubview:maskImageView];
            [maskImageView setHidden:NO];
            [maskImageView release];
        }
    }
    if (highlighted) {
        [maskImageView setHidden:NO];
        isHighLight = YES;
    }
    else
    {
        [maskImageView setHidden:YES];
        isHighLight = NO;
    }
    
}

@end
