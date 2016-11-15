//
//  CacheManager.h
//  Order
//
//  Created by 健 王 on 12-12-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CacheManager : NSObject
+(void)saveCache:(NSString*)fileName data:(NSData*)data;
+(NSData*)getCache:(NSString*)fileName;
+(BOOL)isCache:(NSString *)fileName timeOut:(long)minute;
+(NSData*)getCache:(NSString*)fileName timeOut:(long)minute;
+(NSString*)getCachePathWithSubPath:(NSString*)subPath;
+(void)deleteCache:(NSString*)fileName;
+(void)deleteAllCache;
+(float)getCacheSize;
@end
