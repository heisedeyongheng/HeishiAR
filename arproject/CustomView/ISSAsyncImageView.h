//
//  AsyncImageView.h
//  Postcard
//
//  Created by markj on 2/18/09.
//  Copyright 2009 Mark Johnson. You have permission to copy parts of this code into your own projects for any use.
//  www.markj.net
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "Def.h"
#import "ISSFileOp.h"//统计文件夹大小使用,整体模块替换

@class ISSAsyncImageView;

//NotificationName
#define NOTIFICATION_ISSASYNCIMAGEVIEW_SHOW         @"ISSAsyncImageViewShow"
#define NOTIFICATION_ISSASYNCIMAGEVIEW_FAIL         @"ISSAsyncImageViewDownFail"


@protocol ISSAsyncImageViewDelegate <NSObject>
@optional
-(void)buttonClicked:(ISSAsyncImageView*)sender;
-(void)buttonLongKey:(ISSAsyncImageView*)sender;
-(void)buttonDown:(ISSAsyncImageView*)sender;
-(void)buttonCancel:(ISSAsyncImageView*)sender;

@end

@interface ISSAsyncImageView : UIView {
	//could instead be a subclass of UIImageView instead of UIView, depending on what other features you want to
	// to build into this class?
    
    UIButton   *button;
	NSURLConnection* Connection; //keep a reference to the connection so we can cancel download in dealloc
	NSMutableData* data; //keep reference to the data so we can collect it as it downloads
	//but where is the UIImage reference? We keep it in self.subviews - no need to re-code what we have in the parent class

	NSString * requestUrl;
    NSString * defaultImageName;
    
    BOOL isShowProgress;
    BOOL isAutoSizeToScroll;//是否自适应scrollview
    BOOL isDefaultImg;
    BOOL isAutoSizeToSuper;
    BOOL isShowShadow;

    
    long totalLen;
    MBProgressHUD *waitProgress;
    BOOL isCacheData;
    BOOL isQQOrSinaImage;
    
    dispatch_queue_t backQueue;
}
@property (nonatomic,readonly)    BOOL isFromLocalData;
@property int maxWidth;//图片最大size，针对高压缩率图
@property int maxHeight;//图片最大size
@property BOOL isShowHighlight;
@property BOOL isShowProgress;
@property BOOL isAutoSizeToSuper;
@property BOOL isAutoSizeToScroll;
@property BOOL isUseSuperContentMode;
@property BOOL isScaleAspectFill;
@property BOOL isShowShadow;
@property (nonatomic,copy)NSString * defaultImageName;
@property (nonatomic,copy)NSString * requestUrl;
@property (nonatomic,assign)id<ISSAsyncImageViewDelegate> delegate;
@property BOOL isNeedFadeIn;
@property BOOL isOpenLongKey;
-(id)initWithFrame:(CGRect)frame;
-(id)initWithoutTouchFrame:(CGRect)frame;


-(void)loadImageFromNet:(NSString*)url;
-(void)loadImageFromFile:(NSString*)filePath;
-(void)loadImageFromCache:(NSString*)cacheName;
-(void)loadImageFromCache:(NSString *)cacheName isCancelLast:(BOOL)isCancel;
-(void)loadImageFromData:(NSData *)imageData;
-(void)showImage;
-(void)showWithImage:(UIImage*)image;
-(void)showImageDefault;
-(void)setImage:(UIImage*)image;
+(void)deleteAllCache;
+(float)getCacheSize;
-(void)setHighlight:(BOOL)isHighlight;
-(UIImage*)image;
-(NSData*)getCacheData:(NSString*)cacheUrl;
+(UIImage *)fixOrientation:(UIImage *)aImage;
@end


