//
//  HighlightImageView.h
//  Order
//
//  Created by Huang Cheng on 13-10-16.
//
//

#import <UIKit/UIKit.h>


@interface HighlightImageView : UIImageView
{
    NSString *imageName;
    UIImageView * maskImageView;
    BOOL isHighLight;
}
@property (nonatomic ,retain) NSString *imageName;
@property (readonly) BOOL isHighLight;
-(id)initWithFrame:(CGRect)frame imageName:(NSString *)fileName;
-(void)setHighlighted:(BOOL)highlighted;
@end