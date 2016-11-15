//
//  AsyncImageView.m
//  Order
//
//  Created by 王健 on 13-12-12.
//
//

#import "AsyncImageView.h"
#import "ISSFileOp.h"
#import "Def.h"

@implementation AsyncImageView
@synthesize maxHeight,maxWidth, isShowProgress,isAdjustToFitScroll,defaultImageName,delegate;
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        [self initControls];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initControls];
    }
    return self;
}
-(void)dealloc
{
    DEBUG_NSLOG(@"%s",__FUNCTION__);
    [Connection cancel]; //in case the URL is still downloading
    [Connection release];
    FREEOBJECT(data);
    [requestUrl release];
    if(waitProgress){[waitProgress release];waitProgress =nil;}
    if(defaultImageName){[defaultImageName release];defaultImageName = nil;}
    [super dealloc];
}
-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [btn setFrame:self.bounds];
}
-(void)initControls
{
    self.userInteractionEnabled = YES;//关掉touch事件，不然会拦截下touch事件
    data = nil;
    isShowProgress = NO;
    isDefaultImg = NO;
    isAdjustToFitScroll = NO;
    waitProgress = nil;
    delegate = nil;
    totalLen = 0;
    maxWidth = 1500;
    maxHeight = 1500;
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    CGFloat sizeScale = MIN(screenHeight/480,screenWidth/320);
    if(sizeScale > 1.0)
    {//>iphone6
        maxWidth = 1600;
        maxHeight = 3200;
    }
    defaultImageName = @"defaultPerson";
    [self setContentMode:UIViewContentModeScaleAspectFit];
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [btn setFrame:self.bounds];
    [self addSubview:btn];
}
#pragma mark - button clicked
-(void)buttonClicked:(UIButton*)sender
{
    if (delegate && [delegate respondsToSelector:@selector(buttonClicked:)]) {
        [delegate buttonClicked:self];
    }
}
-(void)showImageDefault
{
    if(self.image != nil)return;
    isDefaultImg = YES;
    [self setImage:[UIImage imageNamed:defaultImageName]];
}
-(void)showImage:(id)image
{
    if(image == nil || ![image isKindOfClass:[UIImage class]])
    {//获取图片失败，服务器返回json
        DEBUG_NSLOG(@"decode image failed");
        [self showImageDefault];
        return;
    }
    [self setImage:(UIImage*)image];
    
    //    [btn setImage:self.image forState:UIControlStateNormal];
    [self bringSubviewToFront:btn];
    if(isAdjustToFitScroll)
        [self adjustImageToFitScroll];
}
-(void)showImage
{
    UIImage * compressImg = nil;
    UIImage *  oriImg = [UIImage imageWithData:data];
    CGFloat whScale = oriImg.size.height/oriImg.size.width;
    if((oriImg.size.width * oriImg.size.height) > maxWidth*maxHeight && whScale < 4)
    {//判断图片尺寸是否过大如果过大直接缩小
        float scaleW = (float)oriImg.size.width/(float)maxWidth;
        float scaleH = (float)oriImg.size.height/(float)maxHeight;
        float scale = MAX(scaleW, scaleH);
        compressImg = [self imageWithImageSimple:oriImg scaledToSize:CGSizeMake(oriImg.size.width/scale, oriImg.size.height/scale)];
        oriImg = nil;
    }
    else
        compressImg = oriImg;
    
    
    DEBUG_NSLOG(@"[requestUrl lastPathComponent] = %@",[requestUrl lastPathComponent]);
    NSArray * arrayCacheName = [requestUrl componentsSeparatedByString:@"/"];
    NSString * lastCacheName = nil;
    if ([arrayCacheName count] > 1){
        NSInteger count = arrayCacheName.count;
        lastCacheName = [NSString stringWithFormat:@"%@%@",[arrayCacheName objectAtIndex:count - 2],[arrayCacheName objectAtIndex:count - 1]];
    }
    else
        lastCacheName = [requestUrl lastPathComponent];
    if(compressImg != nil)
    {
        UIImage * decodedImg = [self decodedImageWithImage:compressImg];//return autorelease
        [self performSelectorOnMainThread:@selector(showImage:) withObject:decodedImg waitUntilDone:NO];
        if(!isCacheData)
        {
            [self saveCache:lastCacheName cacheData:data];
        }
    }
    else
        [self delCache:lastCacheName];
}
-(void)adjustImageToFitScroll
{
    if([self.superview isKindOfClass:[UIScrollView class]])
    {
        UIScrollView * superScroll = (UIScrollView*)self.superview;
        CGFloat scrollW = CGRectGetWidth(superScroll.frame);
        CGFloat scrollH = CGRectGetHeight(superScroll.frame);
        CGFloat centerX = 0;
        CGFloat centerY = 0;
        CGFloat tarW = 0;
        CGFloat tarH = 0;
        if(scrollH > scrollW)
        {
            tarW = CGRectGetWidth(superScroll.frame);
            tarH = (tarW*self.image.size.height)/self.image.size.width;
            imgShowSize = CGSizeMake(tarW, tarH);
            tarH = MAX(tarH, scrollH);
            [self setFrame:CGRectMake(0, 0, tarW, tarH)];
        }
        else
        {
            tarH = CGRectGetHeight(superScroll.frame);
            tarW = (tarH*self.image.size.width)/self.image.size.height;
            imgShowSize = CGSizeMake(tarW, tarH);
            tarW = MAX(tarW, scrollW);
            [self setFrame:CGRectMake(0, 0, tarW, tarH)];
        }
        centerX = tarW/2;
        centerY = tarH/2;
        if(tarW <= scrollW)centerX = scrollW/2;
        if(tarH <= scrollH)centerY = scrollH/2;
        [self setCenter:CGPointMake(centerX,centerY)];
        [superScroll setContentSize:CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        [self setNeedsLayout];
    }
}
- (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    // Tell the old image to draw in this newcontext, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    // End the context
    UIGraphicsEndImageContext();
    // Return the new image.
    return newImage;
}
-(UIImage *)decodedImageWithImage:(UIImage *)image
{
    CGImageRef imageRef = image.CGImage;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 CGImageGetWidth(imageRef),
                                                 CGImageGetHeight(imageRef),
                                                 8,
                                                 // Just always return width * 4 will be enough
                                                 CGImageGetWidth(imageRef) * 4,
                                                 // System only supports RGB, set explicitly
                                                 colorSpace,
                                                 // Makes system don't need to do extra conversion when displayed.
                                                 kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little);
    CGColorSpaceRelease(colorSpace);
    if (!context) return nil;
    
    CGRect rect = (CGRect){CGPointZero,{CGImageGetWidth(imageRef), CGImageGetHeight(imageRef)}};
    CGContextDrawImage(context, rect, imageRef);
    CGImageRef decompressedImageRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    UIImage *decompressedImage = [[UIImage alloc] initWithCGImage:decompressedImageRef scale:image.scale orientation:UIImageOrientationUp];
    CGImageRelease(decompressedImageRef);
    return [decompressedImage autorelease];
}
#pragma mark load function
//首先加载缓存，缓存不存在则联网获取，
-(void)loadImageFromCache:(NSString *)cacheName
{
    if([cacheName isEqualToString:requestUrl] && !isDefaultImg)
        return;//图片没有变化并且不是默认图就不再重新加载
    //移除上一次图片
    if(requestUrl != nil)
    {
        [requestUrl release];
        requestUrl = nil;
    }
    requestUrl = [cacheName copy];
    
    NSArray *arrayCacheName = [cacheName componentsSeparatedByString:@"/"];
    NSString *lastCacheName = nil;
    if ([arrayCacheName count] > 1) {
        NSInteger count = arrayCacheName.count;
        lastCacheName = [NSString stringWithFormat:@"%@%@",[arrayCacheName objectAtIndex:count - 2],[arrayCacheName objectAtIndex:count - 1]];
    }
    else {
        lastCacheName = [cacheName lastPathComponent];
    }
    
    NSData * cacheData = [self getCache:lastCacheName];
    if(cacheData != nil)
    {//网络连接失败先尝试取缓存数据，如果缓存不存在则显示默认图
        FREEOBJECT(data);
        data = [[NSMutableData alloc] initWithData:cacheData];
        isCacheData = YES;
        [self performSelectorInBackground:@selector(showImage) withObject:nil];
        [cacheData release];
    }
    else
    {
        DEBUG_NSLOG(@"no cache so use net img");
        [self loadImageFromNet:cacheName];
    }
    
}
//加载图片，是否取消正在加载中的图片任务
-(void)loadImageFromCache:(NSString *)cacheName isCancelLast:(BOOL)isCancel
{
    if(isCancel)
    {
        if (Connection!=nil)
        {
            [Connection cancel];
            [Connection release];
            Connection = nil;
        }
    }
    [self loadImageFromCache:cacheName];
}


-(void)loadImageFromNet:(NSString*)url
{//直接从网络获取
    if (Connection!=nil)return;//net work isbusy for getimage
    if([url rangeOfString:@"http://"].location == NSNotFound)
    {
        if(url.length > 0){
            
            //开始尝试base64
            NSData * imgData = [ISSFileOp base64Decodeding:url];
            UIImage * tmpImg = nil;
            if(imgData != nil)
                tmpImg = [UIImage imageWithData:imgData];
            if(tmpImg == nil)
                tmpImg = [UIImage imageWithContentsOfFile:url];
            if(tmpImg == nil)
                tmpImg = [UIImage imageNamed:url];
            
            if(tmpImg != nil){
                tmpImg = [self getScaleImage:tmpImg];
                [self performSelector:@selector(setImage:) withObject:tmpImg afterDelay:0.2];
            }
            else
                [self showImageDefault];
        }
        else{
            [self showImageDefault];
        }
        return;
    }
    
    if(requestUrl != nil)
    {
        [requestUrl release];
        requestUrl = nil;
    }
    
    [self showImageDefault];
    
    requestUrl = [url copy];
    if (data!=nil) { [data release]; data = nil;}
    
    
    DEBUG_NSLOG(@"load image from url:%@",url);
    
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    
    
    //注意
    [request setHTTPMethod:@"GET"];
    Connection = [[NSURLConnection alloc] initWithRequest:request delegate:self]; //notice how delegate set to self object
    //TODO error handling, what if connection is nil?
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    if(waitProgress == nil)
    {
        waitProgress = [[MBProgressHUD alloc] initWithView:self];
        waitProgress.mode = MBProgressHUDModeDeterminate;
        CGRect frame = waitProgress.frame;
        frame.origin.y = 0;
        [waitProgress setFrame:frame];
        [self addSubview:waitProgress];
    }
    if(isShowProgress)
    {
        DEBUG_NSLOG(@"showprogress");
        [self addSubview:waitProgress];
        waitProgress.labelText = @"加载中...";
        waitProgress.progress = 0.0f;
        [waitProgress show:YES];
    }
    [request release];
    
}
#pragma mark - Network delege
//the URL connection calls this repeatedly as data arrives
- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData {
    if (data==nil) { data = [[NSMutableData alloc] initWithCapacity:0]; }
    [data appendData:incrementalData];
    
    if(waitProgress !=nil && isShowProgress)
    {
        waitProgress.progress = (data.length)/(float)totalLen;
        [self setNeedsLayout];
        DEBUG_NSLOG(@"progress:%f",waitProgress.progress);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [data setLength:0];
    totalLen = [response expectedContentLength];
    if(totalLen > 120*1024 && !self.isShowProgress && ![self.superview isKindOfClass:[UIScrollView class]])
    {
        DEBUG_NSLOG(@"image %@ is more than 120kb. it size:%ld",requestUrl,totalLen);
        [Connection cancel];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        //no end;
    }
}
- (void)connection:(NSURLConnection*)theConnection didFailWithError:(NSError*)error
{
    //DEBUG_NSLOG(@"======================== network Fail ========================");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if(Connection != nil)
    {
        [Connection release];
        Connection=nil;
    }
    
    [self showImageDefault];
    if(waitProgress != nil)
        [waitProgress hide:YES];
    
}


//the URL connection calls this once all the data has downloaded
- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
    //so self data now has the complete image
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    isCacheData = NO;
    [self performSelectorInBackground:@selector(showImage) withObject:nil];
    
    if(waitProgress != nil)
        [waitProgress hide:YES];
    
    if(Connection != nil)
    {
        [Connection release];
        Connection=nil;
    }
}
-(CGSize)imgShowSize
{
    return imgShowSize;
}
-(UIImage*)getScaleImage:(UIImage*)compressImg
{
    UIImage * result = compressImg;
    if((compressImg.size.width * compressImg.size.height) > maxWidth*maxHeight)
    {//判断图片尺寸是否过大如果过大直接缩小
        CGFloat retinaScale = [[UIScreen mainScreen] scale];
        float scaleW = (float)compressImg.size.width/(float)(maxWidth*retinaScale);
        float scaleH = (float)compressImg.size.height/(float)(maxHeight*retinaScale);
        float scale = MAX(scaleW, scaleH);
        result = [self imageWithImageSimple:compressImg scaledToSize:CGSizeMake(compressImg.size.width/scale, compressImg.size.height/scale)];
    }
    return result;
}
//for cache
-(void)delCache:(NSString*)_cacheName
{
    NSString *documentsDirectory = [ISSFileOp ReturnLastUserLibFilePath];
    NSString *tmpFolder = [documentsDirectory stringByAppendingPathComponent:AsyncImgFILE_FOLDER];
    tmpFolder = [tmpFolder stringByAppendingPathComponent:_cacheName];
    if([[NSFileManager defaultManager] fileExistsAtPath:tmpFolder])
        [[NSFileManager defaultManager] removeItemAtPath:tmpFolder error:nil];
}
-(void)saveCache:(NSString*)_cacheName cacheData:(NSData*)_cacheData
{
    NSString *documentsDirectory = [ISSFileOp ReturnLastUserLibFilePath];
    NSString *tmpFolder = [documentsDirectory stringByAppendingPathComponent:AsyncImgFILE_FOLDER];
    
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:tmpFolder])
    {
        //临时文件夹不存在，则新建
        if(![[NSFileManager defaultManager] fileExistsAtPath:tmpFolder])
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:tmpFolder withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    NSData * copyDataSource = [[[NSData alloc] initWithData:_cacheData] autorelease];
    tmpFolder = [tmpFolder stringByAppendingPathComponent:_cacheName];
    [copyDataSource writeToFile:tmpFolder atomically:YES];
}

-(NSData*)getCache:(NSString*)_cacheName
{
    NSString *documentsDirectory = [ISSFileOp ReturnLastUserLibFilePath];
    
    
    
    NSString *tmpFolder = [documentsDirectory stringByAppendingPathComponent:AsyncImgFILE_FOLDER];
    tmpFolder = [tmpFolder stringByAppendingPathComponent:_cacheName];
    NSData	*datasource = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:tmpFolder])
    {
        datasource = [[NSData alloc] initWithContentsOfFile:tmpFolder];
    }
    return datasource;
    
}

+(void)deleteAllCache
{
    NSString *documentsDirectory = [ISSFileOp ReturnLastUserLibFilePath];
    NSString *tmpFolder = [documentsDirectory stringByAppendingPathComponent:AsyncImgFILE_FOLDER];
    if ([[NSFileManager defaultManager] fileExistsAtPath:tmpFolder])
        [[NSFileManager defaultManager] removeItemAtPath:tmpFolder error:nil];
}

+(float)getCacheSize
{
    float cacheSize = 0.0;
    NSString *documentsDirectory = [ISSFileOp ReturnLastUserLibFilePath];
    NSString *tmpFolder = [documentsDirectory stringByAppendingPathComponent:AsyncImgFILE_FOLDER];
    if([[NSFileManager defaultManager] fileExistsAtPath:tmpFolder])
    {
        double fileSize = [ISSFileOp folderSizeAtPathC:tmpFolder];
        cacheSize = fileSize/(1024*1024);
    }
    return cacheSize;
}
@end
