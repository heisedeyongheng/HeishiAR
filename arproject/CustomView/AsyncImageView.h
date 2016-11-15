//
//  AsyncImageView.h
//  Order
//
//  Created by 王健 on 13-12-12.
//
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@class AsyncImageView;

@protocol AsyncImageViewDelegate <NSObject>
@optional
-(void)buttonClicked:(AsyncImageView*)sender;
-(void)buttonDown:(AsyncImageView*)sender;
@end

@interface AsyncImageView : UIImageView
{
    UIButton * btn;
    MBProgressHUD * waitProgress;
    long totalLen;
    BOOL isDefaultImg;
    
    NSURLConnection* Connection; //keep a reference to the connection so we can cancel download in dealloc
    NSMutableData* data; //keep reference to the data so we can collect it as it downloads
    //but where is the UIImage reference? We keep it in self.subviews - no need to re-code what we have in the parent class
    NSString * requestUrl;
    BOOL isCacheData;
    CGSize imgShowSize;//only isAdjustToFitScroll is YES
}
@property int maxWidth;//图片最大size，针对高压缩率图
@property int maxHeight;//图片最大size
@property BOOL isShowProgress;
@property BOOL isAdjustToFitScroll;
@property(nonatomic,copy)NSString * defaultImageName;
@property (nonatomic,assign)id<AsyncImageViewDelegate> delegate;
-(void)loadImageFromNet:(NSString*)url;
-(void)loadImageFromCache:(NSString*)cacheName;
-(void)loadImageFromCache:(NSString *)cacheName isCancelLast:(BOOL)isCancel;
+(void)deleteAllCache;
+(float)getCacheSize;
-(CGSize)imgShowSize;
@end
