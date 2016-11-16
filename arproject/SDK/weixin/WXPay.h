//
//  WXPay.h
//  Order
//
//  Created by ToothBond on 15/2/25.
//
//

#import <Foundation/Foundation.h>

@interface WXPay : NSObject
{
    NSString * timeStamp;
    NSString * traceNo;
    NSString * productName;
    NSString * totalPrice;
}
+(WXPay*)defaultInstance;
+(void)destory;
-(void)payOrder:(NSString*)proName totalPrice:(NSString*)_totalPrice traceNo:(NSString*)_traceNo;
@end
