//
//  CacheManager.m
//  Order
//
//  Created by 健 王 on 12-12-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CacheManager.h"
#import "ISSFileOp.h"
#import "Def.h"

@implementation CacheManager
//key应该是文件名，如果包含路径则自动创建该路径
+(void)saveCache:(NSString *)fileName data:(NSData *)data
{
    
    NSString *documentsDirectory = [ISSFileOp ReturnLastUserLibFilePath];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:MAIN_CACHE_PATH];
    NSString * tmpCityFolder = [documentsDirectory stringByAppendingPathComponent:[fileName stringByDeletingLastPathComponent]];
        [ISSFileOp CreateFolderWithPath:tmpCityFolder];
    
    NSData *copyDataSource = [[NSData alloc] initWithData:data];
    NSString * targetFile = [documentsDirectory stringByAppendingPathComponent:fileName];
    BOOL isSuccess = [copyDataSource writeToFile:targetFile atomically:YES];
    DEBUG_NSLOG(@"write file %d",isSuccess);
    [copyDataSource release];
}


+(NSData*)getCache:(NSString *)fileName
{
    NSString *documentsDirectory = [ISSFileOp ReturnLastUserLibFilePath];
    NSString *tmpCityFolder = [documentsDirectory stringByAppendingPathComponent:MAIN_CACHE_PATH];

    DEBUG_NSLOG(@" tmpCityFolder  ====>>>>>   %@",tmpCityFolder);
    tmpCityFolder = [tmpCityFolder stringByAppendingPathComponent:fileName];
    
    NSData	*datasource = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:tmpCityFolder]) 
        datasource = [[NSData alloc] initWithContentsOfFile:tmpCityFolder];
    return datasource;
}



+(BOOL)isCache:(NSString *)fileName timeOut:(long)minute
{
    NSString *documentsDirectory = [ISSFileOp ReturnLastUserLibFilePath];
    NSString *tmpCityFolder = [documentsDirectory stringByAppendingPathComponent:MAIN_CACHE_PATH];
    tmpCityFolder = [tmpCityFolder stringByAppendingPathComponent:fileName];
    
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:tmpCityFolder error:nil];
    if (fileAttributes != nil)
    {//获取的gmt时间和北京时间相差8小时，只是计算时间差无所谓转换
        NSDate * createDate = (NSDate*)[fileAttributes objectForKey:NSFileCreationDate];
        NSTimeInterval secondsBetweenDates =[createDate timeIntervalSinceNow];
        if((-1)*secondsBetweenDates >= minute * 60)
        {
            DEBUG_NSLOG(@"cache is timeout");
            return YES;
        }
        else
            return NO;
    }
    else{
        return YES;
    }
        
}


+(NSData*)getCache:(NSString *)fileName timeOut:(long)minute
{
    
    //DEBUG_NSLOG(@" cache  key  ====>>>>>   %@",fileName);
    
    NSString *documentsDirectory = [ISSFileOp ReturnLastUserLibFilePath];
    NSString *tmpCityFolder = [documentsDirectory stringByAppendingPathComponent:MAIN_CACHE_PATH];
    tmpCityFolder = [tmpCityFolder stringByAppendingPathComponent:fileName];
    
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:tmpCityFolder error:nil];
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
    if ([[NSFileManager defaultManager] fileExistsAtPath:tmpCityFolder]) 
        datasource = [[NSData alloc] initWithContentsOfFile:tmpCityFolder];
    return datasource;
}

+(NSString*)getCachePathWithSubPath:(NSString *)subPath
{
    NSString *documentsDirectory = [ISSFileOp ReturnLastUserLibFilePath];
    NSString *tmpCityFolder = [documentsDirectory stringByAppendingPathComponent:MAIN_CACHE_PATH];
    tmpCityFolder = [tmpCityFolder stringByAppendingPathComponent:subPath];
    [ISSFileOp CreateFolderWithPath:tmpCityFolder];
    return tmpCityFolder;
}

+(void)deleteCache:(NSString *)fileName
{
    NSString *documentsDirectory = [ISSFileOp ReturnLastUserLibFilePath];
    NSString *tmpCityFolder = [documentsDirectory stringByAppendingPathComponent:MAIN_CACHE_PATH];
    tmpCityFolder = [tmpCityFolder stringByAppendingPathComponent:fileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:tmpCityFolder])
        [ISSFileOp deleteFileFolderByPath2:tmpCityFolder];
}


+(void)deleteAllCache
{
    NSString *documentsDirectory = [ISSFileOp ReturnLastUserLibFilePath];
    NSString *tmpCityFolder = [documentsDirectory stringByAppendingPathComponent:MAIN_CACHE_PATH];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:tmpCityFolder])
        [ISSFileOp deleteFileFolderByPath2:tmpCityFolder];
}


+(float)getCacheSize
{
    float cacheSize = 0.0;
    NSString *documentsDirectory = [ISSFileOp ReturnLastUserLibFilePath];
    NSString *tmpCityFolder = [documentsDirectory stringByAppendingPathComponent:MAIN_CACHE_PATH];
    if([[NSFileManager defaultManager] fileExistsAtPath:tmpCityFolder])
    {
        double fileSize = [ISSFileOp folderSizeAtPathC:tmpCityFolder];
        cacheSize = fileSize/(1024*1024);
    }
    return cacheSize;
}
@end
