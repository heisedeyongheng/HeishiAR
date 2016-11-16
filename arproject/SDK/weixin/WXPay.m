//
//  WXPay.m
//  Order
//
//  Created by ToothBond on 15/2/25.
//
//

#import "WXPay.h"
#import "WXApi.h"
#import "Def.h"


#import <CommonCrypto/CommonDigest.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

NSString *AccessTokenKey = @"access_token";
NSString *PrePayIdKey = @"prepayid";
NSString *errcodeKey = @"errcode";
NSString *errmsgKey = @"errmsg";
NSString *expiresInKey = @"expires_in";

static WXPay * instance = NULL;
@implementation WXPay
+(WXPay*)defaultInstance
{
    if(instance == NULL)
        instance = [[WXPay alloc] init];
    return instance;
}
+(void)destory
{
    FREEOBJECT(instance);
}
-(id)init
{
    self = [super init];
    return self;
}
-(void)dealloc
{
    [super dealloc];
    FREEOBJECT(timeStamp);
    FREEOBJECT(traceNo);
    FREEOBJECT(productName);
    FREEOBJECT(totalPrice);
}
-(void)payOrder:(NSString*)proName totalPrice:(NSString*)_totalPrice traceNo:(NSString*)_traceNo
{
    FREEOBJECT(timeStamp);
    FREEOBJECT(traceNo);
    FREEOBJECT(productName);
    FREEOBJECT(totalPrice);
    timeStamp = [NSString stringWithFormat:@"%lld",(long long)[[NSDate date] timeIntervalSince1970]];
    traceNo = [_traceNo copy];
    productName = [proName copy];
    totalPrice = [_totalPrice copy];
}
-(void)getAccessToken
{
//    NSString *getAccessTokenUrl = [NSString stringWithFormat:@"https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=%@&secret=%@", WeiXinChatAppID, WeiXinChatAppKey];
//    
//    NSLog(@"--- GetAccessTokenUrl: %@", getAccessTokenUrl);
//    
//    ASIHTTPRequest * request = [[ASIHTTPRequest requestWithURL:[NSURL URLWithString:getAccessTokenUrl]] autorelease];
//    
//    [request setCompletionBlock:^{
//        NSError *error = nil;
//        NSDictionary *dict = [[NSJSONSerialization JSONObjectWithData:[request responseData]
//                                                             options:kNilOptions
//                                                               error:&error] autorelease];
//        if (error) {
//            DEBUG_NSLOG(@"错误,获取 AccessToken 失败");
//            return;
//        } else {
//            NSLog(@"--- %@", [request responseString]);
//        }
//        
//        NSString *accessToken = dict[AccessTokenKey];
//        if (accessToken) {
//            DEBUG_NSLOG(@"--- AccessToken: %@", accessToken);
//            
//            //            [strongSelf getPrepayId:accessToken];
//        } else {
//            NSString *strMsg = [NSString stringWithFormat:@"errcode: %@, errmsg:%@", dict[errcodeKey], dict[errmsgKey]];
//            DEBUG_NSLOG(@"error %@",strMsg);
//        }
//    }];
//    
//    [request setFailedBlock:^{
//        DEBUG_NSLOG(@"错误,获取 AccessToken 失败");
//    }];
//    [request startAsynchronous];
}
-(void)getPrepayId:(NSString *)accessToken
{
//    NSString *getPrepayIdUrl = [NSString stringWithFormat:@"https://api.weixin.qq.com/pay/genprepay?access_token=%@", accessToken];
//    
//    NSLog(@"--- GetPrepayIdUrl: %@", getPrepayIdUrl);
//    
//    NSMutableData *postData = [self getProductArgs];
//    
//    // 文档: 详细的订单数据放在 PostData 中,格式为 json
//    ASIHTTPRequest * request = [[ASIHTTPRequest requestWithURL:[NSURL URLWithString:getPrepayIdUrl]] autorelease];
//    [request addRequestHeader:@"Content-Type" value:@"application/json"];
//    [request addRequestHeader:@"Accept" value:@"application/json"];
//    [request setRequestMethod:@"POST"];
//    [request setPostBody:postData];
//    
//    [request setCompletionBlock:^{
//        NSError *error = nil;
//        NSDictionary *dict = [[NSJSONSerialization JSONObjectWithData:[request responseData]
//                                                             options:kNilOptions
//                                                               error:&error] autorelease];
//        
//        if (error) {
//            DEBUG_NSLOG(@"错误,获取 PrePayId 失败");
//            return;
//        } else {
//            DEBUG_NSLOG(@"--- %@", [request responseString]);
//        }
//        
//        NSString *prePayId = dict[PrePayIdKey];
//        if (prePayId) {
//            DEBUG_NSLOG(@"--- PrePayId: %@", prePayId);
//            
//            // 调起微信支付
//            PayReq * wxreq   = [[[PayReq alloc] init] autorelease];
//            wxreq.partnerId = WeiXinPartnerId;
//            wxreq.prepayId  = prePayId;
//            wxreq.package   = @"Sign=WXPay";      // 文档为 `Request.package = _package;` , 但如果填写上面生成的 `package` 将不能支付成功
//            wxreq.nonceStr  = traceNo;
//            wxreq.timeStamp = [[NSDate date] timeIntervalSince1970];
//            
//            // 构造参数列表
//            NSMutableDictionary *params = [NSMutableDictionary dictionary];
//            [params setObject:WeiXinChatAppID forKey:@"appid"];
//            [params setObject:WeiXinChatAppKey forKey:@"appkey"];
//            [params setObject:wxreq.nonceStr forKey:@"noncestr"];
//            [params setObject:wxreq.package forKey:@"package"];
//            [params setObject:wxreq.partnerId forKey:@"partnerid"];
//            [params setObject:wxreq.prepayId forKey:@"prepayid"];
//            [params setObject:wxreq.timeStamp forKey:@"timestamp"];
//            wxreq.sign = [self genSign:params];
//            
//            // 在支付之前，如果应用没有注册到微信，应该先调用 [WXApi registerApp:appId] 将应用注册到微信
//            [WXApi sendReq:wxreq];
//        } else {
//            NSString *strMsg = [NSString stringWithFormat:@"errcode: %@, errmsg:%@", dict[errcodeKey], dict[errmsgKey]];
//            DEBUG_NSLOG(@"error %@",strMsg);
//        }
//    }];
//    [request setFailedBlock:^{
//        DEBUG_NSLOG(@"错误,获取 PrePayId 失败");
//    }];
//    [request startAsynchronous];
}
//- (NSMutableData *)getProductArgs
//{
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    [params setObject:WeiXinChatAppID forKey:@"appid"];
//    [params setObject:WeiXinChatAppKey forKey:@"appkey"];
//    [params setObject:traceNo forKey:@"noncestr"];
//    [params setObject:timeStamp forKey:@"timestamp"];
//    [params setObject:traceNo forKey:@"traceid"];
//    [params setObject:[self genPackage] forKey:@"package"];
//    [params setObject:[self genSign:params] forKey:@"app_signature"];
//    [params setObject:@"sha1" forKey:@"sign_method"];
//    
//    NSError *error = nil;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error: &error];
//    DEBUG_NSLOG(@"--- ProductArgs: %@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
//    return [NSMutableData dataWithData:jsonData];
//}
//- (NSString *)genPackage
//{
//    // 构造参数列表
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    [params setObject:@"WX" forKey:@"bank_type"];
//    [params setObject:@"千足金箍棒" forKey:@"body"];
//    [params setObject:@"1" forKey:@"fee_type"];
//    [params setObject:@"UTF-8" forKey:@"input_charset"];
//    [params setObject:@"http://weixin.qq.com" forKey:@"notify_url"];
//    [params setObject:traceNo forKey:@"out_trade_no"];
//    [params setObject:WeiXinPartnerId forKey:@"partner"];
//    [params setObject:[self getIPAddress:YES] forKey:@"spbill_create_ip"];
//    [params setObject:@"1" forKey:@"total_fee"];    // 1 =＝ ¥0.01
//    
//    NSArray *keys = [params allKeys];
//    NSArray *sortedKeys = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//        return [obj1 compare:obj2 options:NSNumericSearch];
//    }];
//    
//    // 生成 packageSign
//    NSMutableString *package = [NSMutableString string];
//    for (NSString *key in sortedKeys) {
//        [package appendString:key];
//        [package appendString:@"="];
//        [package appendString:[params objectForKey:key]];
//        [package appendString:@"&"];
//    }
//    
//    [package appendString:@"key="];
//    [package appendString:WeiXinPartnerId]; // 注意:不能hardcode在客户端,建议genPackage这个过程都由服务器端完成
//    
//    // 进行md5摘要前,params内容为原始内容,未经过url encode处理
//    NSString *packageSign = [[self md5:[package copy]] uppercaseString];
//    package = nil;
//    
//    // 生成 packageParamsString
//    NSString *value = nil;
//    package = [NSMutableString string];
//    for (NSString *key in sortedKeys) {
//        [package appendString:key];
//        [package appendString:@"="];
//        value = [params objectForKey:key];
//        
//        // 对所有键值对中的 value 进行 urlencode 转码
//        value = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)value, nil, (CFStringRef)@"!*'&=();:@+$,/?%#[]", kCFStringEncodingUTF8));
//        
//        [package appendString:value];
//        [package appendString:@"&"];
//    }
//    NSString *packageParamsString = [package substringWithRange:NSMakeRange(0, package.length - 1)];
//    
//    NSString *result = [NSString stringWithFormat:@"%@&sign=%@", packageParamsString, packageSign];
//    
//    NSLog(@"--- Package: %@", result);
//    
//    return result;
//}

- (NSString *)genSign:(NSDictionary *)signParams
{
    // 排序
    NSArray *keys = [signParams allKeys];
    NSArray *sortedKeys = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    
    // 生成
    NSMutableString *sign = [NSMutableString string];
    for (NSString *key in sortedKeys) {
        [sign appendString:key];
        [sign appendString:@"="];
        [sign appendString:[signParams objectForKey:key]];
        [sign appendString:@"&"];
    }
    NSString *signString = [[sign copy] substringWithRange:NSMakeRange(0, sign.length - 1)];
    
    NSString *result = [self sha1:signString];
    NSLog(@"--- Gen sign: %@", result);
    return result;
}

#pragma mark common util
-(NSString *)md5:(NSString *)input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

-(NSString *)sha1:(NSString *)input
{
    const char *ptr = [input UTF8String];
    
    int i =0;
    int len = strlen(ptr);
    Byte byteArray[len];
    while (i!=len)
    {
        unsigned eachChar = *(ptr + i);
        unsigned low8Bits = eachChar & 0xFF;
        
        byteArray[i] = low8Bits;
        i++;
    }
    
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(byteArray, len, digest);
    
    NSMutableString *hex = [NSMutableString string];
    for (int i=0; i<20; i++)
        [hex appendFormat:@"%02x", digest[i]];
    
    NSString *immutableHex = [NSString stringWithString:hex];
    
    return immutableHex;
}

-(NSString *)getIPAddress:(BOOL)preferIPv4
{
    NSArray *searchArray = preferIPv4 ?
    @[ IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
    //NSLog(@"addresses: %@", addresses);
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         address = addresses[key];
         if(address) *stop = YES;
     } ];
    return address ? address : @"0.0.0.0";
}

-(NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) || (interface->ifa_flags & IFF_LOOPBACK)) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                char addrBuf[INET6_ADDRSTRLEN];
                if(inet_ntop(addr->sin_family, &addr->sin_addr, addrBuf, sizeof(addrBuf))) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, addr->sin_family == AF_INET ? IP_ADDR_IPv4 : IP_ADDR_IPv6];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    
    // The dictionary keys have the form "interface" "/" "ipv4 or ipv6"
    return [addresses count] ? addresses : nil;
}
@end
