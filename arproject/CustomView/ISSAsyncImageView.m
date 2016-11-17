//
//  ISSAsyncImageView.m
//
//
//  Created by  on 2/18/09.


#import "ISSAsyncImageView.h"
#import "Def.h"
#import "AppDelegate.h"
#import "HighlightImageView.h"

#define kTagDefaultImg      4040
#define kTagImage           4050
#define kTagButton          4060

extern AppDelegate * appDelegate;


@implementation ISSAsyncImageView
@synthesize isShowProgress;
@synthesize isAutoSizeToSuper;
@synthesize isAutoSizeToScroll;
@synthesize delegate;
@synthesize isShowShadow;
@synthesize isShowHighlight;
@synthesize defaultImageName;
@synthesize isScaleAspectFill;
@synthesize isUseSuperContentMode;
@synthesize maxHeight;
@synthesize maxWidth;
@synthesize isNeedFadeIn;
@synthesize requestUrl;
@synthesize isOpenLongKey;
@synthesize isFromLocalData;
-(void)initBaseInfo{
    isQQOrSinaImage = NO;
    isFromLocalData = NO;
    isShowProgress = NO;
    isAutoSizeToScroll = NO;
    isAutoSizeToSuper = NO;
    isScaleAspectFill = NO;
    isUseSuperContentMode = NO;
    isShowHighlight = NO;
    isShowShadow = NO;
    
    isNeedFadeIn = YES;
    data = nil;
    button = nil;
    requestUrl = nil;
    waitProgress = nil;
    defaultImageName = @"defaultPerson";
    
    totalLen = 0;
    maxWidth = 1500;
    maxHeight = 1500;
    
    backQueue = dispatch_queue_create("imgback", NULL);
}

-(id)init
{
    if (self = [super init]) {
        self.userInteractionEnabled = YES;//关掉touch事件，不然会拦截下touch事件
        isOpenLongKey = NO;
        [self initBaseInfo];
        
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;          //关掉touch事件，不然会拦截下touch事件
        self.frame = frame;
        isOpenLongKey = NO;
        [self initBaseInfo];
    }
    return self;
}






-(id)initWithoutTouchFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = NO;          //关掉touch事件，不然会拦截下touch事件
        self.frame = frame;
        [self initBaseInfo];
        
    }
    return self;
}

- (void)dealloc {
    
    //    DEBUG_NSLOG(@"%s",__FUNCTION__);
    
    self.delegate = nil;
	[Connection cancel]; //in case the URL is still downloading
    
    FREEOBJECT(Connection);
    FREEOBJECT(data);
    FREEOBJECT(requestUrl);
    FREEOBJECT(waitProgress);
    FREEOBJECT(defaultImageName);
    dispatch_release(backQueue);
    [super dealloc];
}


-(void)layoutSubviews
{
    if(isAutoSizeToSuper)
    {
        //        DEBUG_NSLOG(@" %s  self.frame.size.width  ===>  %.2f,  self.frame.size.height  ===>  %.2f",__FUNCTION__, self.frame.size.width, self.frame.size.height);
        
        //图片模式按照内部图片按照父view大小设定
        for (UIView * imageView in self.subviews) {
            if([imageView isKindOfClass:[HighlightImageView class]])
            {
                imageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
            }
            if ([imageView isKindOfClass:[UIButton class]]) {
                imageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
            }
        }
    }
}


#pragma mark - show function
-(void)showImageDefault
{
    if(![[NSThread currentThread] isMainThread]){
        [self performSelectorOnMainThread:@selector(showImageDefault) withObject:nil waitUntilDone:NO];
        return;
    }
    
    if ([self viewWithTag:kTagImage]) {
        [[self viewWithTag:kTagImage] removeFromSuperview];
    }
    if ([self viewWithTag:kTagButton]) {
        [[self viewWithTag:kTagButton] removeFromSuperview];
    }
    if ([self viewWithTag:kTagDefaultImg]) {
        [[self viewWithTag:kTagDefaultImg] removeFromSuperview];
    }
    
    if (![defaultImageName isEqualToString:@""]) {
        HighlightImageView *defaultImageView = [[[HighlightImageView alloc] initWithImage:[UIImage imageNamed:defaultImageName]] autorelease];
        defaultImageView.tag = kTagDefaultImg;
        
        if (isUseSuperContentMode) {
            defaultImageView.frame = CGRectMake(0,0, self.frame.size.width,self.frame.size.height);
            defaultImageView.contentMode = self.contentMode;
            defaultImageView.autoresizingMask = self.autoresizingMask;
        }
        else if (isScaleAspectFill == YES) {
            defaultImageView.frame = CGRectMake(0,0, self.frame.size.width,self.frame.size.height);
            defaultImageView.contentMode = UIViewContentModeScaleAspectFill;
            defaultImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        }
        else {
            if(self.isShowProgress && [self.superview isKindOfClass:[UIScrollView class]] && isAutoSizeToScroll){
                CGRect applicationFrame = [UIScreen mainScreen].applicationFrame;
                float scale = applicationFrame.size.width/defaultImageView.frame.size.width;//锁定宽度缩放图片
                scale = (scale > 1.0f ? 1.0f:scale);
                [defaultImageView setFrame:CGRectMake(defaultImageView.frame.origin.x,defaultImageView.frame.origin.y,defaultImageView.frame.size.width*scale, defaultImageView.frame.size.height*scale)];
                self.frame = defaultImageView.frame;
            }
            else if (defaultImageView.image.size.width < self.frame.size.width || defaultImageView.image.size.height < self.frame.size.height) {
                defaultImageView.frame = CGRectMake((self.frame.size.width-defaultImageView.image.size.width)/2, (self.frame.size.height-defaultImageView.image.size.height)/2, defaultImageView.image.size.width,defaultImageView.image.size.height);
            }
            else {
                defaultImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
            }
            
            defaultImageView.contentMode = UIViewContentModeScaleAspectFit;
            defaultImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        }
        
        
        if (isShowShadow) {
            [defaultImageView.layer setBorderColor:[UIColor whiteColor].CGColor];
            [defaultImageView.layer setShadowColor:[UIColor blackColor].CGColor];
            [defaultImageView.layer setShadowOffset:CGSizeMake(0.0, 4.0)];
            [defaultImageView.layer setShadowRadius:3.0];
            [defaultImageView.layer setShadowOpacity:0.4];
        }
        
        [self addSubview:defaultImageView];
        
        [self initButton:defaultImageView.frame];
    }
    else
        [self initButton:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
    
    
    
	[self setNeedsDisplay];
    isDefaultImg = YES;
}


-(void)fadeInShowImage:(HighlightImageView *)image{
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options: UIViewAnimationCurveEaseInOut //设置动画类型
                     animations:^{
                         image.alpha = 1.0;
                     }
                     completion:^(BOOL finished){
                         
                     }];
}


-(void)showImage:(id)obj
{
    if(obj == nil)
    {
//        if (delegate && [delegate respondsToSelector:@selector(isFailToLoadImage:)]) {
//            [delegate isFailToLoadImage:self];
//        }

        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ISSASYNCIMAGEVIEW_FAIL
                                                            object:self];
        
        //获取图片失败，服务器返回json
        DEBUG_NSLOG(@"decode image failed");
        return;
    }
    
    if ([self viewWithTag:kTagImage]) {
        [[self viewWithTag:kTagImage] removeFromSuperview];
    }
    
    if ([self viewWithTag:kTagButton]) {
        [[self viewWithTag:kTagButton] removeFromSuperview];
    }
    if ([self viewWithTag:kTagDefaultImg]) {
        [[self viewWithTag:kTagDefaultImg] removeFromSuperview];
    }
    
    HighlightImageView* imageView = [[[HighlightImageView alloc] initWithImage:(UIImage*)obj] autorelease];
    imageView.tag = kTagImage;
    
    if (isNeedFadeIn) {
        imageView.alpha = 0.0;
        [self fadeInShowImage:imageView];
    }
    
    [self addSubview:imageView];

    
    //--------   save cache
    if (isFromLocalData == NO) {
        NSArray *arrayCacheName = [requestUrl componentsSeparatedByString:@"/"];
        NSString *lastCacheName = nil;
        if ([arrayCacheName count] > 1) {
            NSInteger count = arrayCacheName.count;
            lastCacheName = [NSString stringWithFormat:@"%@%@",[arrayCacheName objectAtIndex:count - 2],[arrayCacheName objectAtIndex:count - 1]];
        }
        else {
            lastCacheName = [requestUrl lastPathComponent];
        }
        //        [self saveCache:lastCacheName cacheData:data];
    }
    
    if (isUseSuperContentMode) {
        imageView.frame = CGRectMake(0,0, self.frame.size.width,self.frame.size.height);
        imageView.contentMode = self.contentMode;
        imageView.autoresizingMask = self.autoresizingMask;
    }
    else if (isScaleAspectFill == YES) {
        imageView.frame = CGRectMake(0,0, self.frame.size.width,self.frame.size.height);
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    }
    else {
        if(self.isShowProgress && [self.superview isKindOfClass:[UIScrollView class]] && isAutoSizeToScroll){
            CGRect applicationFrame = [UIScreen mainScreen].applicationFrame;
            float scale = applicationFrame.size.width/imageView.frame.size.width;//锁定宽度缩放图片
            scale = (scale > 1.0f ? 1.0f:scale);
            [imageView setFrame:CGRectMake(imageView.frame.origin.x,imageView.frame.origin.y,imageView.frame.size.width*scale, imageView.frame.size.height*scale)];
            self.frame = imageView.frame;
        }
        else if (imageView.image.size.width < self.frame.size.width || imageView.image.size.height < self.frame.size.height) {
            imageView.frame = CGRectMake((self.frame.size.width-imageView.image.size.width)/2, (self.frame.size.height-imageView.image.size.height)/2, imageView.image.size.width,imageView.image.size.height);
        }
        else {
            imageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        }
        
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    }
    
    
    if (isShowShadow) {
        [imageView.layer setBorderColor:[UIColor whiteColor].CGColor];
        [imageView.layer setShadowColor:[UIColor blackColor].CGColor];
        [imageView.layer setShadowOffset:CGSizeMake(0.0, 4.0)];
        [imageView.layer setShadowRadius:3.0];
        [imageView.layer setShadowOpacity:0.4];
    }
    
    
    //判断上级是不是scrollview,调整自身大小，以适应图片
    if([self.superview isKindOfClass:[UIScrollView class]] && isAutoSizeToScroll)
    {
        UIScrollView * parent = (UIScrollView*)self.superview;
        parent.contentSize = imageView.frame.size;
        
        
        CGPoint sCener = CGPointMake(self.center.x, self.center.y);
        if(self.frame.size.height < parent.frame.size.height)
            sCener.y = parent.frame.size.height/2;
        if(self.frame.size.width < parent.frame.size.width)
            sCener.x = parent.frame.size.width/2;
        self.center = sCener;
    }
    
    
    
    isDefaultImg = NO;
    [self initButton:imageView.frame];
    [self setNeedsDisplay];
    
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ISSASYNCIMAGEVIEW_SHOW
                                                        object:self];
    
    /*
    if (delegate && [delegate respondsToSelector:@selector(isShowImage:dataFromLocal:)]) {
        [delegate isShowImage:self
                dataFromLocal:isFromLocalData];
    }
    */
    
}






-(void)showWithImage:(UIImage*)image{
    HighlightImageView* imageView = nil;
    
    if ([self viewWithTag:kTagImage]) {
//        [[self viewWithTag:kTagImage] removeFromSuperview];
        imageView = (HighlightImageView *)[self viewWithTag:kTagImage];
    }
    else{
        imageView = [[[HighlightImageView alloc] initWithImage:image] autorelease];
        imageView.tag = kTagImage;
        [self addSubview:imageView];
    }
    
    imageView.image = image;

    if ([self viewWithTag:kTagDefaultImg]) {
        [[self viewWithTag:kTagDefaultImg] removeFromSuperview];
    }
    
    

    
    //--------   save cache
    
    if (isUseSuperContentMode) {
        imageView.frame = CGRectMake(0,0, self.frame.size.width,self.frame.size.height);
        imageView.contentMode = self.contentMode;
        imageView.autoresizingMask = self.autoresizingMask;
    }
    else if (isScaleAspectFill == YES) {
        imageView.frame = CGRectMake(0,0, self.frame.size.width,self.frame.size.height);
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    }
    else {
        if(self.isShowProgress && [self.superview isKindOfClass:[UIScrollView class]] && isAutoSizeToScroll){
            CGRect applicationFrame = [UIScreen mainScreen].applicationFrame;
            float scale = applicationFrame.size.width/imageView.frame.size.width;//锁定宽度缩放图片
            scale = (scale > 1.0f ? 1.0f:scale);
            [imageView setFrame:CGRectMake(imageView.frame.origin.x,imageView.frame.origin.y,imageView.frame.size.width*scale, imageView.frame.size.height*scale)];
            self.frame = imageView.frame;
        }
        else if (imageView.image.size.width < self.frame.size.width || imageView.image.size.height < self.frame.size.height) {
            imageView.frame = CGRectMake((imageView.image.size.width-imageView.image.size.width/2), (imageView.image.size.height-imageView.image.size.height/2), imageView.image.size.width,imageView.image.size.height);
        }
        else {
            imageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        }
        
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    }
    
    
    if (isShowShadow) {
        [imageView.layer setBorderColor:[UIColor whiteColor].CGColor];
        [imageView.layer setShadowColor:[UIColor blackColor].CGColor];
        [imageView.layer setShadowOffset:CGSizeMake(0.0, 4.0)];
        [imageView.layer setShadowRadius:3.0];
        [imageView.layer setShadowOpacity:0.4];
    }
    
    
    //判断上级是不是scrollview,调整自身大小，以适应图片
    if([self.superview isKindOfClass:[UIScrollView class]] && isAutoSizeToScroll)
    {
        UIScrollView * parent = (UIScrollView*)self.superview;
        parent.contentSize = imageView.frame.size;
        
        
        CGPoint sCener = CGPointMake(self.center.x, self.center.y);
        if(self.frame.size.height < parent.frame.size.height)
            sCener.y = parent.frame.size.height/2;
        if(self.frame.size.width < parent.frame.size.width)
            sCener.x = parent.frame.size.width/2;
        self.center = sCener;
    }
    
    
    
    isDefaultImg = NO;
    [self initButton:imageView.frame];
    [self setNeedsDisplay];
    
}



-(void)initButton:(CGRect)frame
{
    
    
    if ([self viewWithTag:kTagButton]) {
//        [[self viewWithTag:kTagButton] removeFromSuperview];
        button = (UIButton *) [self viewWithTag:kTagButton];
    }
    else{
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = kTagButton;
        [self addSubview:button];
    }
    

    button.frame = frame;

    
    
    if (isOpenLongKey) {
        //        [button addTarget:self action:@selector(buttonTouchBegin:) forControlEvents:UIControlEventTouchDown];
        //        [button addTarget:self action:@selector(buttonTouchEnd:) forControlEvents:UIControlEventTouchUpInside];
        //        [button addTarget:self action:@selector(buttonTouchEnd:) forControlEvents:UIControlEventTouchUpOutside];
        
        //button点击事件
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(buttonLongKey:)];
        longPress.minimumPressDuration = 1.0; //定义按的时间
        [button addGestureRecognizer:longPress];
        
        
    }
    else{
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(buttonDown:) forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:@selector(buttonCancel:) forControlEvents:UIControlEventTouchCancel];
        [button addTarget:self action:@selector(buttonCancel:) forControlEvents:UIControlEventTouchUpOutside];
    }
    
}

#pragma mark - key action
-(void)buttonTouchBegin:(UIButton *)sender{
    DEBUG_NSLOG(@"=============>>>>>   %s  <<<<=============",__FUNCTION__);
    
    
}


-(void)buttonTouchEnd:(UIButton *)sender{
    DEBUG_NSLOG(@"=============>>>>>   %s  <<<<=============",__FUNCTION__);
}



-(void)buttonLongKey:(UIButton *)sender{
    DEBUG_NSLOG(@"=============>>>>>   %s  <<<<=============",__FUNCTION__);
    
    
    if (delegate && [delegate respondsToSelector:@selector(buttonLongKey:)]) {
        [delegate buttonLongKey:self];
    }
    
}



#pragma mark - load function
//首先加载缓存，缓存不存在则联网获取，
-(void)loadImageFromUrl:(NSString *)urlName
{
    if([urlName rangeOfString:@"http://"].location == NSNotFound)
    {
        if(urlName.length > 0){
            
            //开始尝试base64
            NSData * imgData = [ISSFileOp base64Decodeding:urlName];
            UIImage * tmpImg = nil;
            if(imgData != nil)
                tmpImg = [UIImage imageWithData:imgData];
            if(tmpImg == nil)
                tmpImg = [UIImage imageWithContentsOfFile:urlName];
            if(tmpImg == nil)
                tmpImg = [UIImage imageNamed:urlName];
            
            if(tmpImg != nil){
                tmpImg = [self getScaleImage:tmpImg];
                [self showImage:tmpImg];
            }
            else
                [self showImageDefault];
        }
        else{
            [self showImageDefault];
        }
        return;
    }
    isQQOrSinaImage = NO;
    NSRange tmpQQImageRange = [urlName rangeOfString:@"http://q.qlogo.cn/" options:NSCaseInsensitiveSearch];
    
    if (tmpQQImageRange.length <= 0) {
        tmpQQImageRange = [urlName rangeOfString:@"sinaimg.cn/" options:NSCaseInsensitiveSearch];
    }
    
    
    if([urlName isEqualToString:requestUrl] && !isDefaultImg)
        return;//图片没有变化并且不是默认图就不再重新加载
    
    [self showImageDefault];
    //移除上一次图片
    if(self.isShowProgress && [self.superview isKindOfClass:[UIScrollView class]])
        self.frame = self.superview.frame;//判读类型，是否在scrollview中
    
    FREEOBJECT(requestUrl);
    requestUrl = [urlName copy];
    
    NSArray *arrayCacheName = [urlName componentsSeparatedByString:@"/"];
    NSString *lastCacheName = nil;
    if ([arrayCacheName count] > 1) {
        
        /******
         QQ的头像要加多一个字段   如地址： http:// q.qlogo.cn/qqapp/101022969/6CE74A6BEE91D4BD07F18EEC27D417AD/100
         最后的路径是固定的，分了区分必须加前面的序列号
         *******/
        if (tmpQQImageRange.length > 0) {
            isQQOrSinaImage = YES;
            NSInteger count = [arrayCacheName count];
            if (count >= 2) {
                NSString* bottomSecondStr = [arrayCacheName objectAtIndex:count - 2];
                
                lastCacheName = [NSString stringWithFormat:@"%@%@", bottomSecondStr,[arrayCacheName lastObject]];
                
            }
            
        }
        else{
            NSInteger count = arrayCacheName.count;
            lastCacheName = [NSString stringWithFormat:@"%@%@",[arrayCacheName objectAtIndex:count - 2],[arrayCacheName objectAtIndex:count - 1]];
        }
    }
    else {
        lastCacheName = [urlName lastPathComponent];
    }
    
//    DEBUG_NSLOG(@"%s  lastCacheName  ====>>>   %@",__FUNCTION__,lastCacheName);

    NSDictionary * dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:STRNULL(urlName),STRNULL(lastCacheName), nil] forKeys:[NSArray arrayWithObjects:@"cacheName",@"lastCacheName", nil]];
//    [self performSelectorInBackground:@selector(loadCacheInBackground:) withObject:dict];
    dispatch_async(backQueue, ^(){
        [self loadCacheInBackground:dict];
    });
}
-(void)loadImageFromCache:(NSString *)cacheName
{
    [self loadImageFromCache:cacheName isCancelLast:YES];
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
    [self loadImageFromUrl:cacheName];
}

-(void)loadCacheInBackground:(id)dict
{
    if(![dict isKindOfClass:[NSDictionary class]])return;
    NSDictionary * pars = (NSDictionary*)dict;
    NSString * cacheName = [pars objectForKey:@"cacheName"];
    NSString * lastCacheName = [pars objectForKey:@"lastCacheName"];
    if (lastCacheName != nil && lastCacheName.length > 0) {
        NSData * cacheData = nil;
        if (isQQOrSinaImage)
            cacheData = [self getCache:lastCacheName timeOut:20];
        else
            cacheData = [self getCache:lastCacheName timeOut:20];
        
        @synchronized(data){
            if(cacheData != nil)
            {//网络连接失败先尝试取缓存数据，如果缓存不存在则显示默认图
                FREEOBJECT(data);
    //            DEBUG_NSLOG(@"%s  , 取缓存",__FUNCTION__);
                data = [[NSMutableData alloc] initWithData:cacheData];
                isCacheData = YES;
                [self showImage];
                [cacheData release];
            }
            else
            {
    //            DEBUG_NSLOG(@"%s  , 无缓存",__FUNCTION__);
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [self loadImageFromNet:cacheName];
                });
            }
        }
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self showImageDefault];
        });
    }
}
-(NSData*)getCacheData:(NSString*)cacheUrl{
    NSRange tmpQQImageRange = [cacheUrl rangeOfString:@"http://q.qlogo.cn/" options:NSCaseInsensitiveSearch];
    
    if (tmpQQImageRange.length <= 0) {
        tmpQQImageRange = [cacheUrl rangeOfString:@"sinaimg.cn/" options:NSCaseInsensitiveSearch];
    }
    
    NSArray *arrayCacheName = [cacheUrl componentsSeparatedByString:@"/"];
    NSString * lastCacheName = nil;
    
    if ([arrayCacheName count] > 1) {
        if (tmpQQImageRange.length > 0) {
            NSInteger count = [arrayCacheName count];
            if (count >= 2) {
                NSString* bottomSecondStr = [arrayCacheName objectAtIndex:count - 2];
                
                lastCacheName = [NSString stringWithFormat:@"%@%@", bottomSecondStr,[arrayCacheName lastObject]];
                
            }
        }
        else{
            NSInteger count = arrayCacheName.count;
            lastCacheName = [NSString stringWithFormat:@"%@%@",[arrayCacheName objectAtIndex:count - 2],[arrayCacheName objectAtIndex:count - 1]];
        }
    }
    else {
        lastCacheName = [cacheUrl lastPathComponent];
    }

    return [self getCache:lastCacheName];
}





-(void)loadImageFromNet:(NSString*)url
{
    @synchronized(data){
        //直接从网络获取
        if (Connection!=nil)return;//net work isbusy for getimage
        FREEOBJECT(requestUrl);
        [self showImageDefault];
        requestUrl = [url copy];
        if (data!=nil) { [data release]; data = nil;}
    }
    
    isFromLocalData = NO;
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    
    
    //注意
    [request setHTTPMethod:@"GET"];
    Connection = [[NSURLConnection alloc] initWithRequest:request delegate:self]; //notice how delegate set to self object
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    if(waitProgress == nil)
    {
        waitProgress = [[MBProgressHUD alloc] initWithView:self];
        waitProgress.mode = MBProgressHUDModeDeterminate;
        [self addSubview:waitProgress];
    }
    if(isShowProgress)
    {
        //DEBUG_NSLOG(@"showprogress");
        [self addSubview:waitProgress];
        waitProgress.labelText = @" ";
        waitProgress.progress = 0.0f;
        [waitProgress show:YES];
    }
    [request release];
    
}


//加载图片数据
-(void)loadImageFromData:(NSData *)imageData
{
    
    if(imageData != nil)
    {
        isFromLocalData = YES;
        FREEOBJECT(data);
        data = [[NSMutableData alloc] initWithData:imageData];
        UIImage * compressImg = [UIImage imageWithData:data];
        if(compressImg != nil)
            [self showImage:compressImg];
        else
            [self showImageDefault];
    }
    
}


-(void)loadImageFromFile:(NSString*)filePath{
    
    FREEOBJECT(requestUrl);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        FREEOBJECT(data);
        isFromLocalData = YES;
        data = [[NSMutableData alloc] initWithContentsOfFile:filePath];
        UIImage * compressImg = [UIImage imageWithData:data];
        if(compressImg != nil)
            [self showImage:compressImg];
        else
            [self showImageDefault];
    }
    else
    {
        [self showImageDefault];
    }
}


#pragma mark -

-(void)setHighlight:(BOOL)isHighlight
{
    if (isShowHighlight) {
        
        if ([self viewWithTag:kTagImage]) {
            HighlightImageView *tmpImage = (HighlightImageView *)[self viewWithTag:kTagImage];
            [tmpImage setHighlighted:isHighlight];
        }
    }
}


#pragma mark - button clicked
-(void)buttonClicked:(UIButton*)sender
{
    DEBUG_NSLOG(@"=============>>>>>   %s  <<<<=============",__FUNCTION__);
    
    if (isShowHighlight) {
        
        if ([self viewWithTag:kTagImage]) {
            HighlightImageView *tmpImage = (HighlightImageView *)[self viewWithTag:kTagImage];
            [tmpImage setHighlighted:NO];
        }
        else if ([self viewWithTag:kTagDefaultImg]) {
            HighlightImageView *tmpImage = (HighlightImageView *)[self viewWithTag:kTagDefaultImg];
            [tmpImage setHighlighted:NO];
        }
        
        
    }
    
    if (delegate && [delegate respondsToSelector:@selector(buttonClicked:)]) {
        [delegate buttonClicked:self];
    }
}


-(void)buttonDown:(UIButton*)sender
{
    if (isShowHighlight) {
        
        if ([self viewWithTag:kTagImage]) {
            HighlightImageView *tmpImage = (HighlightImageView *)[self viewWithTag:kTagImage];
            [tmpImage setHighlighted:YES];
        }
        else if ([self viewWithTag:kTagDefaultImg]) {
            HighlightImageView *tmpImage = (HighlightImageView *)[self viewWithTag:kTagDefaultImg];
            [tmpImage setHighlighted:YES];
        }
        
        
    }
    
    if (delegate && [delegate respondsToSelector:@selector(buttonDown:)]) {
        [delegate buttonDown:self];
    }
}
-(void)buttonCancel:(UIButton*)sender
{
    if (isShowHighlight) {
        if ([self viewWithTag:kTagImage]) {
            HighlightImageView *tmpImage = (HighlightImageView *)[self viewWithTag:kTagImage];
            [tmpImage setHighlighted:NO];
        }
        else if ([self viewWithTag:kTagDefaultImg]) {
            HighlightImageView *tmpImage = (HighlightImageView *)[self viewWithTag:kTagDefaultImg];
            [tmpImage setHighlighted:NO];
        }
    }
    if (delegate && [delegate respondsToSelector:@selector(buttonCancel:)]) {
        [delegate buttonCancel:self];
    }
}



#pragma mark - Network delege
//TODO:  图片下载有异常
- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData {
    
    @try {
        if (data == nil){
            data = [[NSMutableData alloc] initWithCapacity:0];
        }
        if (incrementalData.length > 0) {
            [data appendData:incrementalData];
        }
        
        
        
        if(waitProgress !=nil && isShowProgress)
        {
            waitProgress.progress = (data.length)/(float)totalLen;
            [self setNeedsLayout];
        }
    }
    @catch (NSException *exception) {
        DEBUG_NSLOG(@"exception  === >%@",exception);
    }
    @finally {
        
    }
    
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [data setLength:0];
    totalLen = [response expectedContentLength];
//    if(totalLen > 400*1024 && !self.isShowProgress && ![self.superview isKindOfClass:[UIScrollView class]])
//    {
//        DEBUG_NSLOG(@"image %@ is more than 200kb. it size:%ld",requestUrl,totalLen);
//        [Connection cancel];
//        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//        //no end;
//    }
}
- (void)connection:(NSURLConnection*)theConnection didFailWithError:(NSError*)error
{
	//DEBUG_NSLOG(@"======================== network Fail ========================");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if(Connection != nil)
    {
        [Connection release];
        Connection = nil;
    }
    
//    if (delegate &&  [delegate respondsToSelector:@selector(isFailToLoadImage:)]) {
//        [delegate isFailToLoadImage:self];
//    }

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ISSASYNCIMAGEVIEW_FAIL
                                                        object:self];
    
    
    
    [self showImageDefault];
    
    
    if(waitProgress != nil)
        [waitProgress hide:YES];
    
}






//the URL connection calls this once all the data has downloaded
- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
	//so self data now has the complete image
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
    //	[NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(showImage) userInfo:nil repeats:NO];
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



-(void)showImage
{
    @try {
        [self showImageDefault];
        UIImage * compressImg = nil;
        NSString * lastCacheName = nil;
        @synchronized(data){
            
            if(!isCacheData && data != nil)
            {
                
                NSRange tmpQQImageRange = [requestUrl rangeOfString:@"http://q.qlogo.cn/" options:NSCaseInsensitiveSearch];
                
                if (tmpQQImageRange.length <= 0) {
                    tmpQQImageRange = [requestUrl rangeOfString:@"sinaimg.cn/" options:NSCaseInsensitiveSearch];
                }
                
                
                NSArray *arrayCacheName = [requestUrl componentsSeparatedByString:@"/"];
                
                if ([arrayCacheName count] > 1) {
                    
                    /******
                     QQ的头像要加多一个字段   如地址： http:// q.qlogo.cn/qqapp/101022969/6CE74A6BEE91D4BD07F18EEC27D417AD/100
                     最后的路径是固定的，分了区分必须加前面的序列号
                     *******/
                    if (tmpQQImageRange.length > 0) {
                        NSInteger count = [arrayCacheName count];
                        if (count >= 2) {
                            NSString* bottomSecondStr = [arrayCacheName objectAtIndex:count - 2];
                            
                            lastCacheName = [NSString stringWithFormat:@"%@%@", bottomSecondStr,[arrayCacheName lastObject]];
                            
                        }
                        
                    }
                    else{
                        NSInteger count = arrayCacheName.count;
                        lastCacheName = [NSString stringWithFormat:@"%@%@",[arrayCacheName objectAtIndex:count - 2],[arrayCacheName objectAtIndex:count - 1]];
                    }
                }
                else {
                    lastCacheName = [requestUrl lastPathComponent];
                }
                
                
                DEBUG_NSLOG(@"lastCacheName = %@",lastCacheName);
                
                
                
                NSMutableData * tmpData = [[[NSMutableData alloc] initWithData:data] autorelease];
                [self saveCache:lastCacheName cacheData:tmpData];
                
            }
            
            compressImg = [UIImage imageWithData:data];
            compressImg = [self getScaleImage:compressImg];//判断图片尺寸是否过大如果过大直接缩小
            if(compressImg != nil)
            {
                UIImage * decodedImg = [self decodedImageWithImage:compressImg];//need to release
                [self performSelectorOnMainThread:@selector(showImage:) withObject:decodedImg waitUntilDone:NO];
                [decodedImg release];
            }
            else
                [self delCache:lastCacheName];
            
        }
        
    }
    @catch (NSException *exception) {
        DEBUG_NSLOG(@"%s---错误:%@",__FUNCTION__,exception);
//        NSString * errMsg = [NSString stringWithFormat:@"发生异常，测试人员请将此信息反馈给开发人员:%@",exception.description];
//        [appDelegate showAlertOKWithMessage:errMsg];
//        DEBUGTAG
    }
    @finally {
        
    }
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
    return decompressedImage;
}


//just in case you want to get the image directly, here it is in subviews
- (UIImage*) image {
    @try {
        HighlightImageView* iv = nil;
        for(int i=0;i<[[self subviews] count];i++)
        {
            UIView * temp = [[self subviews] objectAtIndex:i];
            if([temp isKindOfClass:[HighlightImageView class]])
                iv = (HighlightImageView*)temp;
        }
        return [iv image];
    }
    @catch (NSException *exception) {
        DEBUG_NSLOG(@"%s---错误：%@",__FUNCTION__,exception);
        return nil;
    }
    @finally {
        
    }
}


-(void)setImage:(UIImage*)image
{
    HighlightImageView * iv = (HighlightImageView*)[self viewWithTag:kTagImage];
    if(iv != nil){
        [iv setImage:image];
        [self bringSubviewToFront:iv];
        [self setNeedsDisplay];
    }
    else
        [self showImage:image];
    FREEOBJECT(requestUrl);
}

#pragma mark - cache action
//for cache
-(void)saveCache:(NSString*)_cacheName cacheData:(NSData*)_cacheData
{
//    DEBUG_NSLOG(@"%s  , file name %@ , _cacheData.length ==>>> %d bytes",__FUNCTION__,_cacheName,_cacheData.length);
    
    if (_cacheData.length > 0) {
        NSString *documentsDirectory = [ISSFileOp ReturnLibFilePath];
        NSString *tmpFolder = [documentsDirectory stringByAppendingPathComponent:AsyncImgFILE_FOLDER];
        
        
        if(![[NSFileManager defaultManager] fileExistsAtPath:tmpFolder])
        {
            //临时文件夹不存在，则新建
            if(![[NSFileManager defaultManager] fileExistsAtPath:tmpFolder])
            {
                
                [[NSFileManager defaultManager] createDirectoryAtPath:tmpFolder withIntermediateDirectories:YES attributes:nil error:nil];
                
                
            }
        }
        //        NSData * copyDataSource = [[[NSData alloc] initWithData:_cacheData] autorelease];
        tmpFolder = [tmpFolder stringByAppendingPathComponent:_cacheName];
        [_cacheData writeToFile:tmpFolder atomically:YES];
    }
}
-(void)delCache:(NSString*)_cacheName
{
    NSString *documentsDirectory = [ISSFileOp ReturnLibFilePath];
    NSString *tmpFolder = [documentsDirectory stringByAppendingPathComponent:AsyncImgFILE_FOLDER];
    tmpFolder = [tmpFolder stringByAppendingPathComponent:_cacheName];
	if([[NSFileManager defaultManager] fileExistsAtPath:tmpFolder])
        [[NSFileManager defaultManager] removeItemAtPath:tmpFolder error:nil];
}



-(NSData*)getCache:(NSString *)fileName timeOut:(long)minute
{
    
    
    NSString *documentsDirectory = [ISSFileOp ReturnLibFilePath];
    NSString *tmpFolder = [documentsDirectory stringByAppendingPathComponent:AsyncImgFILE_FOLDER];
    tmpFolder = [tmpFolder stringByAppendingPathComponent:fileName];
    
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:tmpFolder error:nil];
    if (fileAttributes != nil)
    {//获取的gmt时间和北京时间相差8小时，只是计算时间差无所谓转换
        NSDate * createDate = (NSDate*)[fileAttributes objectForKey:NSFileCreationDate];
        NSTimeInterval secondsBetweenDates =[createDate timeIntervalSinceNow];
        if((-1)*secondsBetweenDates >= minute * 60)
        {
            DEBUG_NSLOG(@"getcache but timeout");
            return nil;
        }
    }
    
    NSData	*datasource = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:tmpFolder])
        datasource = [[NSData alloc] initWithContentsOfFile:tmpFolder];
    return datasource;
}




-(NSData*)getCache:(NSString*)_cacheName
{
    
    
    NSString *documentsDirectory = [ISSFileOp ReturnLibFilePath];
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
    NSString *documentsDirectory = [ISSFileOp ReturnLibFilePath];
    NSString *tmpFolder = [documentsDirectory stringByAppendingPathComponent:AsyncImgFILE_FOLDER];
    if ([[NSFileManager defaultManager] fileExistsAtPath:tmpFolder])
        [[NSFileManager defaultManager]removeItemAtPath:tmpFolder error:nil];
}

+(float)getCacheSize
{
    float cacheSize = 0.0;
    NSString *documentsDirectory = [ISSFileOp ReturnLibFilePath];
    NSString *tmpFolder = [documentsDirectory stringByAppendingPathComponent:AsyncImgFILE_FOLDER];
    if([[NSFileManager defaultManager] fileExistsAtPath:tmpFolder])
    {
        double fileSize = [ISSFileOp folderSizeAtPathC:tmpFolder];
        cacheSize = fileSize/(1024*1024);
    }
    return cacheSize;
}


+(UIImage *)fixOrientation:(UIImage *)aImage
{
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    //    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    UIImage * result = nil;
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            result = [UIImage imageWithCGImage:aImage.CGImage scale:1.0 orientation:UIImageOrientationDown];
            break;
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            result = [UIImage imageWithCGImage:aImage.CGImage scale:1.0 orientation:UIImageOrientationRight];
            break;
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            result = [UIImage imageWithCGImage:aImage.CGImage scale:1.0 orientation:UIImageOrientationLeft];
            break;
        default:break;
    }
    //    [pool drain];
    return result;
}
@end
