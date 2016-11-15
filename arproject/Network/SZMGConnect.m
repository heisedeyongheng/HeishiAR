//
//  SZMGConnect.m
//  Ubunta
//
//  Created by 王健 on 13-8-13.
//  Copyright (c) 2013年 wj. All rights reserved.
//

#import "SZMGConnect.h"
#import "NSString+SBJSON.h"
#import "Def.h"

@implementation SZMGConnect
@synthesize datadelegate;
-(id)init
{
    if( (self = [super init]) )
    {
        netData = nil;
        waitProcess = nil;
        processBar = nil;
    }
    return self;
}
-(id)initWithProcessBar:(UIView*)parentView
{
    if( (self = [self init]) )
    {
        netData = nil;
        if(parentView != nil)
        {
            processBar = [[ProcessImageView alloc] initWithFrame:CGRectMake(0, 0, parentView.frame.size.width, 2)];
            [processBar setIsHorizontally:YES];
            [processBar setImage:[UIImage imageNamed:@"img_barComplete"] unComplete:[UIImage imageNamed:@"img_barUnComplete"]];
            [processBar setBackgroundColor:[UIColor clearColor]];
            [parentView addSubview:processBar];
        }
    }
    return self;
}
-(id)initWithIndicator:(UIView *)parentView
{
    if((self = [self init]))
    {
        if(parentView != nil)
        [self initIndicator:parentView];
    }
    return self;
}
-(void)initIndicator:(UIView *)parentView
{
    waitProcess = [[MBProgressHUD alloc] initWithView:parentView];
    [waitProcess setBackgroundColor:[UIColor clearColor]];
    [parentView addSubview:waitProcess];
    [parentView bringSubviewToFront:waitProcess];
    
    UIView * customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    customView.backgroundColor = [UIColor clearColor];
    UIActivityIndicatorView * indicator = [[[UIActivityIndicatorView alloc]
                                            initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
    [indicator setCenter:CGPointMake(20, 20)];
    [customView addSubview:indicator];
    [indicator startAnimating];
    
    waitProcess.customView = customView;
    waitProcess.margin = 5;
    waitProcess.dimBackground = NO;
    waitProcess.mode = MBProgressHUDModeCustomView;
    
    [customView release];
}
-(id)initWithHUD:(UIView *)parentView hudTitle:(NSString *)title
{
    if((self = [self init]))
    {
        if(parentView != nil)
            [self initHUD:parentView hudTitle:title];
    }
    return self;
}
-(void)initHUD:(UIView *)parentView hudTitle:(NSString *)title
{
    waitProcess = [[MBProgressHUD alloc] initWithView:parentView];
    [parentView addSubview:waitProcess];
    [parentView bringSubviewToFront:waitProcess];
    
    UIView * customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 170, 40)];
    customView.backgroundColor = [UIColor clearColor];
    UIActivityIndicatorView * indicator = [[[UIActivityIndicatorView alloc]
                                            initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
    [indicator setCenter:CGPointMake(20, 20)];
    [customView addSubview:indicator];
    [indicator startAnimating];
    //label
    UILabel * textLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 90, 40)];
    [textLabel setText:[NSString stringWithFormat:@"%@",(title == nil ? @"加载中..." : title)]];
    [textLabel setBackgroundColor:[UIColor clearColor]];
    [textLabel setFont:[UIFont systemFontOfSize:15]];
    [textLabel setTextColor:[UIColor whiteColor]];
    [textLabel setTextAlignment:NSTextAlignmentLeft];
    [customView addSubview:textLabel];
    [textLabel release];
    //split img
    UIImageView * split = [[UIImageView alloc] initWithFrame:CGRectMake(customView.frame.size.width-30, -5, 1, 50)];
    [split setImage:[UIImage imageNamed:@"Image_Space"]];
    [customView addSubview:split];
    [split release];
    //cancelbtn
    cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setImage:[UIImage imageNamed:@"image_Cancel"] forState:UIControlStateNormal];
    [cancelBtn setFrame:CGRectMake(customView.frame.size.width-25, 7.5, 25, 25)];
    [cancelBtn addTarget:self action:@selector(onCancelBtn:) forControlEvents:UIControlEventTouchUpInside];
    [customView addSubview:cancelBtn];
    
    waitProcess.customView = customView;
    waitProcess.margin = 5;
    waitProcess.dimBackground = NO;
    waitProcess.mode = MBProgressHUDModeCancel;
    
    [customView release];
}
-(void)dealloc
{
    DEBUG_NSLOG(@"%s",__FUNCTION__);
    [netConnection cancel];
    [netConnection release];
    netConnection = nil;
    
    if(nil != postStr)
    {
        [postStr release];
        postStr = nil;
    }
    if(nil != connectionUrl)
    {
        [connectionUrl release];
        connectionUrl = nil;
    }
    if(nil != netData)
    {
        [netData release];
        netData = nil;
    }
    FREEOBJECT(datadelegate);
    if(waitProcess.superview != nil)
        [waitProcess removeFromSuperview];
    FREEOBJECT(waitProcess);
    if(processBar.superview != nil)
        [processBar removeFromSuperview];
    FREEOBJECT(processBar);
    [super dealloc];
}


#pragma mark -
#pragma network delegate
-(void)startRequest
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    netData = [[NSMutableData alloc] init];
    
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:connectionUrl]];
    
    long postLength = 0;
    if(isPost)
    {
        NSMutableString * jsonData = [self postStrToJson:postStr];
        NSData * data = [jsonData  dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:data];
        [request setHTTPMethod:@"POST"];
        postLength = data.length;
        DEBUG_NSLOG(@"\n\n====================    network Request   start\n url : %@\n POST Data:%@\n ====================    network Request   end\n",connectionUrl,postStr);
    }
    else
    {
        [request setHTTPMethod:@"GET"];
        DEBUG_NSLOG(@"\n\n====================    network Request \n  start\n\n url : %@\n  GET\n\n====================    network Request   end\n\n",connectionUrl);
    }
//    [request setCachePolicy:NSURLCacheStorageNotAllowed];
//    [request setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
//    [request setValue:[NSString stringWithFormat:@"%ld",postLength] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setTimeoutInterval:NETTIME];
    netConnection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] retain];
    
    [request release];
    [netConnection release];
    
    if(waitProcess != nil)
        [waitProcess show:YES];
}

-(void)onCancelBtn:(UIButton*)btn
{
    if(btn == nil)
    {
        DEBUG_NSLOG(@"now release");
        [self release];
    }
    else
    {
        DEBUG_NSLOG(@"btn");
        if(waitProcess != nil && !waitProcess.hidden)
            [waitProcess hide:YES];
        if(datadelegate && [datadelegate respondsToSelector:@selector(onCancel)])
            [datadelegate performSelector:@selector(onCancel)];
        if(netConnection != nil)
            [netConnection cancel];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    DEBUG_NSLOG(@"==============================  net error with url : %@  ==============================  \n\n error message:   %@ ============================== ",connectionUrl , error);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if([datadelegate respondsToSelector:@selector(onNetError:)])//给出网络失败提示
    {
        ErrorObject * EO = [[ErrorObject alloc] init];
        EO.ErrorMsg = nil;
        [datadelegate onNetError:EO];
        [EO release];
    }
    else
    {
        // [appDelegate showMsg:NSLocalizedString(@"NetFail",nil) hiddenTime:2];
//        [appDelegate showMsg:NETERROR hiddenTime:2];
        DEBUG_NSLOG(@"didFailWithError but the class have no delege --onError");
    }
    if(waitProcess != nil)
        [waitProcess hide:YES];
    [cancelBtn setEnabled:NO];
    
    [self retain];
    [self performSelector:@selector(onCancelBtn:) withObject:nil afterDelay:1];//延后执行析构函数,防止cancelbtn和这个析构冲突
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [netData appendData:data];
    if(processBar != nil)
    {
        float percent = (data.length)/(float)totalLen;
        [processBar setProcess:percent];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
#if DEBUG
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    NSInteger responseStatusCode = [httpResponse statusCode];
    DEBUG_NSLOG(@"status code:%d",(int)responseStatusCode);
#endif
    [netData setLength:0];
    totalLen = [response expectedContentLength];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
#if DEBUG
    NSString *result = [[[NSString alloc] initWithData:netData encoding:NSUTF8StringEncoding] autorelease];
    DEBUG_NSLOG(@"\n\n====================    network response   start  \n\n net url:%@ \n\nnetdata:\n\n%@\n\n====================    network response   end  \n\n",connectionUrl,result);
#endif
    if([datadelegate respondsToSelector:@selector(onFinish:url:)])
        [datadelegate onFinish:netData url:connectionUrl];
    
    if(waitProcess != nil)
        [waitProcess hide:YES];
    [cancelBtn setEnabled:NO];
    
    [self retain];
    [self performSelector:@selector(onCancelBtn:) withObject:nil afterDelay:1.5];
    //延后执行析构函数,防止此时cancelbtn异步执行click事件和这个析构冲突,下一次换一种联网方式，不采用网络完毕立即释放内存的方式，否则对close支持不完美
}


// write by wj
#pragma mark op function
-(BOOL)isJSON:(NSString*)str
{
    id obj = [str JSONValueNoLog];
    return obj != nil ? YES : NO;
}
-(NSMutableString*)postStrToJson:(NSString*)str
{
    //kAPIVersion
    NSMutableString * result = [[[NSMutableString alloc] init] autorelease];
    NSArray * parList = [str componentsSeparatedByString:@"&"];
    [result appendString:@"{"];
    if(str.length == 0)
    {//异常处理
        [result appendString:@"}"];
        return result;
    }
    BOOL isFindVerKey = NO;
    for(int i=0;i<parList.count;i++)
    {
        NSInteger index = [[parList objectAtIndex:i] rangeOfString:@"="].location;
        NSInteger len = [[parList objectAtIndex:i] length];
        [result appendString:@"\""];
        NSString * key = [[parList objectAtIndex:i] substringWithRange:NSMakeRange(0, index)];
        [result appendString:key];
        NSString * value = [[parList objectAtIndex:i] substringWithRange:NSMakeRange(index+1, len-index-1)];
        if(![self isJSON:value])
        {
            [result appendString:@"\":\""];
            [result appendString:([key isEqualToString:@"version"] ? kAPIVersion : value)];
            [result appendString:(i == parList.count - 1 ? @"\"" : @"\",")];
        }
        else
        {
            [result appendString:@"\":"];
            [result appendString:([key isEqualToString:@"version"] ? kAPIVersion : value)];
            [result appendString:(i == parList.count - 1 ? @"" : @",")];
        }
        if([key isEqualToString:@"version"])
            isFindVerKey = YES;
    }
    if(isFindVerKey == NO)
    {
        [result appendFormat:@",\"version\":\"%@\"",kAPIVersion];
    }
    [result appendString:@"}"];
    return result;
}

-(void)httpLogin:(NSString *)username pwd:(NSString *)pwd weixinid:(NSString *)weixinid
{
    NSString * url = [[NSString alloc] initWithFormat:@"%@%@",KServerURL,KLoginApi];
    //NSParameterAssert( url );
    connectionUrl = [url copy];
    [url release];
    
    NSString * postdata = [NSString stringWithFormat:@"username=%@&password=%@&weixin=%@",username,pwd,weixinid];//pass base64
    
    postStr = [[NSString alloc] initWithString:postdata];
    isPost = YES;
    if(![[NSThread currentThread] isMainThread])
        [self performSelectorOnMainThread:@selector(startRequest) withObject:nil waitUntilDone:NO];
    else
        [self startRequest];
}
-(void)httpRegist:(NSString *)username pwd:(NSString *)pwd
{
    NSString * url = [[NSString alloc] initWithFormat:@"%@%@",KServerURL,KRegistAPI];
    //NSParameterAssert( url );
    connectionUrl = [url copy];
    [url release];
    
    NSString * postdata = [NSString stringWithFormat:@"username=%@&password=%@",username,pwd];
    postStr = [[NSString alloc] initWithString:postdata];
    isPost = YES;
    if(![[NSThread currentThread] isMainThread])
        [self performSelectorOnMainThread:@selector(startRequest) withObject:nil waitUntilDone:NO];
    else
        [self startRequest];
}
@end



@implementation MF_Base64Codec
+(NSData *)dataFromBase64String:(NSString *)encoding
{
    NSData *data = nil;
    unsigned char *decodedBytes = NULL;
    @try {
#define __ 255
        static char decodingTable[256] = {
            __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0x00 - 0x0F
            __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0x10 - 0x1F
            __,__,__,__, __,__,__,__, __,__,__,62, __,__,__,63,  // 0x20 - 0x2F
            52,53,54,55, 56,57,58,59, 60,61,__,__, __, 0,__,__,  // 0x30 - 0x3F
            __, 0, 1, 2,  3, 4, 5, 6,  7, 8, 9,10, 11,12,13,14,  // 0x40 - 0x4F
            15,16,17,18, 19,20,21,22, 23,24,25,__, __,__,__,__,  // 0x50 - 0x5F
            __,26,27,28, 29,30,31,32, 33,34,35,36, 37,38,39,40,  // 0x60 - 0x6F
            41,42,43,44, 45,46,47,48, 49,50,51,__, __,__,__,__,  // 0x70 - 0x7F
            __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0x80 - 0x8F
            __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0x90 - 0x9F
            __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0xA0 - 0xAF
            __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0xB0 - 0xBF
            __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0xC0 - 0xCF
            __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0xD0 - 0xDF
            __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0xE0 - 0xEF
            __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0xF0 - 0xFF
        };
        encoding = [encoding stringByReplacingOccurrencesOfString:@"=" withString:@""];
        NSData *encodedData = [encoding dataUsingEncoding:NSASCIIStringEncoding];
        unsigned char *encodedBytes = (unsigned char *)[encodedData bytes];
        
        NSUInteger encodedLength = [encodedData length];
        NSUInteger encodedBlocks = (encodedLength+3) >> 2;
        NSUInteger expectedDataLength = encodedBlocks * 3;
        
        unsigned char decodingBlock[4];
        
        decodedBytes = malloc(expectedDataLength);
        if( decodedBytes != NULL ) {
            
            NSUInteger i = 0;
            NSUInteger j = 0;
            NSUInteger k = 0;
            unsigned char c;
            while( i < encodedLength ) {
                c = decodingTable[encodedBytes[i]];
                i++;
                if( c != __ ) {
                    decodingBlock[j] = c;
                    j++;
                    if( j == 4 ) {
                        decodedBytes[k] = (decodingBlock[0] << 2) | (decodingBlock[1] >> 4);
                        decodedBytes[k+1] = (decodingBlock[1] << 4) | (decodingBlock[2] >> 2);
                        decodedBytes[k+2] = (decodingBlock[2] << 6) | (decodingBlock[3]);
                        j = 0;
                        k += 3;
                    }
                }
            }
            
            // Process left over bytes, if any
            if( j == 3 ) {
                decodedBytes[k] = (decodingBlock[0] << 2) | (decodingBlock[1] >> 4);
                decodedBytes[k+1] = (decodingBlock[1] << 4) | (decodingBlock[2] >> 2);
                k += 2;
            } else if( j == 2 ) {
                decodedBytes[k] = (decodingBlock[0] << 2) | (decodingBlock[1] >> 4);
                k += 1;
            }
            data = [[NSData alloc] initWithBytes:decodedBytes length:k];
        }
    }
    @catch (NSException *exception) {
        data = nil;
        NSLog(@"WARNING: error occured while decoding base 32 string: %@", exception);
    }
    @finally {
        if( decodedBytes != NULL ) {
            free( decodedBytes );
        }
    }
    return data;
}
+(NSString *)base64StringFromData:(NSData *)data
{
    NSString *encoding = nil;
    unsigned char *encodingBytes = NULL;
    @try {
        static char encodingTable[64] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        static NSUInteger paddingTable[] = {0,2,1};
        //                 Table 1: The Base 64 Alphabet
        //
        //    Value Encoding  Value Encoding  Value Encoding  Value Encoding
        //        0 A            17 R            34 i            51 z
        //        1 B            18 S            35 j            52 0
        //        2 C            19 T            36 k            53 1
        //        3 D            20 U            37 l            54 2
        //        4 E            21 V            38 m            55 3
        //        5 F            22 W            39 n            56 4
        //        6 G            23 X            40 o            57 5
        //        7 H            24 Y            41 p            58 6
        //        8 I            25 Z            42 q            59 7
        //        9 J            26 a            43 r            60 8
        //       10 K            27 b            44 s            61 9
        //       11 L            28 c            45 t            62 +
        //       12 M            29 d            46 u            63 /
        //       13 N            30 e            47 v
        //       14 O            31 f            48 w         (pad) =
        //       15 P            32 g            49 x
        //       16 Q            33 h            50 y
        
        NSUInteger dataLength = [data length];
        NSUInteger encodedBlocks = (dataLength * 8) / 24;
        NSUInteger padding = paddingTable[dataLength % 3];
        if( padding > 0 ) encodedBlocks++;
        NSUInteger encodedLength = encodedBlocks * 4;
        
        encodingBytes = malloc(encodedLength);
        if( encodingBytes != NULL ) {
            NSUInteger rawBytesToProcess = dataLength;
            NSUInteger rawBaseIndex = 0;
            NSUInteger encodingBaseIndex = 0;
            unsigned char *rawBytes = (unsigned char *)[data bytes];
            unsigned char rawByte1, rawByte2, rawByte3;
            while( rawBytesToProcess >= 3 ) {
                rawByte1 = rawBytes[rawBaseIndex];
                rawByte2 = rawBytes[rawBaseIndex+1];
                rawByte3 = rawBytes[rawBaseIndex+2];
                encodingBytes[encodingBaseIndex] = encodingTable[((rawByte1 >> 2) & 0x3F)];
                encodingBytes[encodingBaseIndex+1] = encodingTable[((rawByte1 << 4) & 0x30) | ((rawByte2 >> 4) & 0x0F) ];
                encodingBytes[encodingBaseIndex+2] = encodingTable[((rawByte2 << 2) & 0x3C) | ((rawByte3 >> 6) & 0x03) ];
                encodingBytes[encodingBaseIndex+3] = encodingTable[(rawByte3 & 0x3F)];
                
                rawBaseIndex += 3;
                encodingBaseIndex += 4;
                rawBytesToProcess -= 3;
            }
            rawByte2 = 0;
            switch (dataLength-rawBaseIndex) {
                case 2:
                    rawByte2 = rawBytes[rawBaseIndex+1];
                case 1:
                    rawByte1 = rawBytes[rawBaseIndex];
                    encodingBytes[encodingBaseIndex] = encodingTable[((rawByte1 >> 2) & 0x3F)];
                    encodingBytes[encodingBaseIndex+1] = encodingTable[((rawByte1 << 4) & 0x30) | ((rawByte2 >> 4) & 0x0F) ];
                    encodingBytes[encodingBaseIndex+2] = encodingTable[((rawByte2 << 2) & 0x3C) ];
                    // we can skip rawByte3 since we have a partial block it would always be 0
                    break;
            }
            // compute location from where to begin inserting padding, it may overwrite some bytes from the partial block encoding
            // if their value was 0 (cases 1-2).
            encodingBaseIndex = encodedLength - padding;
            while( padding-- > 0 ) {
                encodingBytes[encodingBaseIndex++] = '=';
            }
            encoding = [[NSString alloc] initWithBytes:encodingBytes length:encodedLength encoding:NSASCIIStringEncoding];
        }
    }
    @catch (NSException *exception) {
        encoding = nil;
        NSLog(@"WARNING: error occured while tring to encode base 32 data: %@", exception);
    }
    @finally {
        if( encodingBytes != NULL ) {
            free( encodingBytes );
        }
    }
    return encoding;
}

@end

@implementation NSString (Base64Addition)
-(NSString *)base64String
{
    NSData *utf8encoding = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [MF_Base64Codec base64StringFromData:utf8encoding];
}

-(NSString *)md5String
{
    const char *cStr = [self UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}
+(NSString *)stringFromBase64String:(NSString *)base64String
{
    NSData *utf8encoding = [MF_Base64Codec dataFromBase64String:base64String];
    return [[NSString alloc] initWithData:utf8encoding encoding:NSUTF8StringEncoding];
}
@end

@implementation NSData (Base64Addition)
+(NSData *)dataWithBase64String:(NSString *)base64String
{
    return [MF_Base64Codec dataFromBase64String:base64String];
}
-(NSString *)base64String
{
    return [MF_Base64Codec base64StringFromData:self];
}
@end