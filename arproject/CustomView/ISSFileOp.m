//
//  ISSFileOp.m
//  MideaApp
//
//  Created by 健 王 on 12-6-13.
//  Copyright (c) 2012年 iSoftStone. All rights reserved.
//

#import "ISSFileOp.h"
#import "Def.h"
#import "AppDelegate.h"
#include <sys/stat.h>
#include <dirent.h>
#import "CommonCrypto/CommonDigest.h"
#import "sys/utsname.h"

#import "ISSAsyncImageView.h"



extern AppDelegate * appdelegate;

static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";//设置编码

@implementation ISSFileOp




#pragma mark - get file create date
+(NSString *)getFileCreateDate:(NSString *)fileName
{
    NSString *documentsDirectory = [ISSFileOp ReturnLastUserLibFilePath];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:MAIN_CACHE_PATH];
    
    
    filePath = [filePath stringByAppendingPathComponent:fileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        
        NSDictionary* attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        
        if (attrs != nil) {
            NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *date = (NSDate*)[attrs objectForKey: NSFileCreationDate];
            NSString * dateStr = [formatter stringFromDate:date];
            
            //DEBUG_NSLOG(@"getFileCreateDate  filePath  ====>>>>>   %@  《《《《《《《《《《 %@",filePath,dateStr);
            
            return [ISSFileOp dateTimeToCNTime:dateStr];
        }
        else {
            return nil;
        }
    }
    else
        return nil;
    
}


//获取N天后的数据
+(NSDate *)getAfterDateFromCurrentDateWithDay:(NSInteger)day
{
    
    NSDate *currentDate = [NSDate date];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:day];
    NSCalendar *calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *mDate = [calender dateByAddingComponents:comps toDate:currentDate options:0];
    [comps release];
    [calender release];
    return mDate;
}



//+(NSString *)doFormatTime:(NSString *)oldtime
//{
//
//    NSString *tmpDate = [NSString stringWithFormat:@"%@ GMT+8", [DataParser idToStr:reply key:@"date"]];
//
//
//    NSDate *exprieDate = [ISSFileOp dateFromString:appDelegate.tokenExpireTime];
//    NSDate *currentDate = [NSDate date];
//    NSTimeInterval exprie = [exprieDate timeIntervalSince1970];
//    NSTimeInterval current = [currentDate timeIntervalSince1970];
//
//    if (exprie >= current + 1000) {
//        isNeedRefresh = NO;
//    }
//}



+(NSString*)dateTimeToCNTime:(NSString*)dateTime
{
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate * now = [NSDate date];
    
    NSString * today = [dateFormatter stringFromDate:now];
    
    NSString * yesterday = [dateFormatter stringFromDate:[now dateByAddingTimeInterval:-1*(60*60*24)]];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate * date = [dateFormatter dateFromString:dateTime];
    NSTimeInterval seconds = -1 * [date timeIntervalSinceNow];
    
    
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *finalTimeStr = [dateFormatter stringFromDate:date];
    [dateFormatter release];
    
    
    NSString * result = @"";
    if(seconds < 60)
    {
        result = @"刚刚";
        return result;
    }
    
    if(seconds < 60*60)
    {
        result = [NSString stringWithFormat:@"%d 分钟前",(int)seconds/60];
        return result;
    }
    if(seconds > 48 * 60*60)
    {
        NSArray *tmpAry = [dateTime componentsSeparatedByString:@" "];
        if (tmpAry > 0 )
            return [tmpAry objectAtIndex:0];    //只返回 年月日
        else
            return dateTime;            //出错的情况
    }
    
    
    //替换 年月日  为 今天
    result = [finalTimeStr stringByReplacingOccurrencesOfString:today withString:@"今天"];
    
    //(如果  yesterday  存在) 替换 年月日  为 昨天
    result = [result stringByReplacingOccurrencesOfString:yesterday withString:@"昨天"];
    

    
    NSRange aRange = [result rangeOfString:@"今天" options:NSCaseInsensitiveSearch];
    if (aRange.length > 0) {
        return result;
    }
    
        aRange = [result rangeOfString:@"昨天" options:NSCaseInsensitiveSearch];
        if (aRange.length > 0) {
            return result;
        }

    
        NSArray *aryResult = [result componentsSeparatedByString:@" "];
        if (aryResult.count >= 2) {
            return [aryResult objectAtIndex:0];
        }

    
    
    return result;
}


//输入的日期字符串形如：@"2013-11-08 19:46:49 GMT+8"

+(NSDate *)dateFromString:(NSString *)dateString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss zzz"];
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    [destDate retain];
    [dateFormatter release];
    return destDate;
    
}

+(NSString *)stringFromDate:(NSDate *)date{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息 +0000。
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    
    NSString *destDateString = [dateFormatter stringFromDate:date];
    
    [dateFormatter release];
    
    return destDateString;
    
}

#pragma mark -
+(NSString *)ReturnDocumentPath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
    
	return documentsDirectory;
}


+(NSString *)ReturnLibFilePath
{
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	return cachePath;
}

+(BOOL)deleteFileFolderByPath2:(NSString *)pathName
{
	BOOL OK = [[NSFileManager defaultManager]removeItemAtPath:pathName error:nil];
	
	if (OK)
		return YES;
	return NO;
	
}


+(void)CreateFolderWithPath:(NSString *)folderPath //传入新建文件夹名字
{
	if(![[NSFileManager defaultManager] fileExistsAtPath:folderPath])
	{
		////DEBUG_NSLOG(@"%@",folderPath);
#ifdef __IPHONE_2_0
		[[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
#else
		[[NSFileManager defaultManager]  createDirectoryAtPath:folderPath attributes: nil];
#endif
		
	}
}
+(BOOL)FileExist:(NSString *)filePath
{
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}


#pragma mark - NSData with Image
+(NSString *) image2String:(UIImage *)image{
	NSData* pictureData = UIImageJPEGRepresentation(image,0.3);//进行图片压缩从0.0到1.0（0.0表示最大压缩，质量最低);
    
	NSString* pictureDataString = [pictureData base64Encoding];//图片转码成为base64Encoding，
    
	return pictureDataString;
}

+(UIImage *) string2Image:(NSString *)string{
	UIImage *image = [UIImage imageWithData:[self dataWithBase64EncodedString:string]];
	return image;
}



#pragma mark -  DES Base64加密

+(NSString *)base64StringFromText:(NSString *)text
{
    if (text && ![text isEqualToString:LocalStr_None]) {
        //取项目的bundleIdentifier作为KEY
        NSString *key = [[NSBundle mainBundle] bundleIdentifier];
        NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
        //IOS 自带DES加密 Begin
        data = [self DESEncrypt:data WithKey:key];
        //IOS 自带DES加密 End
        return [self base64Encoding:data];          //base64EncodedStringFrom
    }
    else {
        return LocalStr_None;
    }
}

+(NSString *)textFromBase64String:(NSString *)base64
{
    if (base64 && ![base64 isEqualToString:LocalStr_None]) {
        //取项目的bundleIdentifier作为KEY
        NSString *key = [[NSBundle mainBundle] bundleIdentifier];
        NSData *data = [self dataWithBase64EncodedString:base64];
        //IOS 自带DES解密 Begin
        data = [self DESDecrypt:data WithKey:key];
        //IOS 自带DES加密 End
        return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    }
    else {
        return LocalStr_None;
    }
}




+ (NSData *)desData:(NSData *)data key:(NSString *)keyString CCOperation:(CCOperation)op
{
    char buffer [1024] ;
    memset(buffer, 0, sizeof(buffer));
    size_t bufferNumBytes;
    CCCryptorStatus cryptStatus = CCCrypt(op,
                                          kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          [keyString UTF8String],
                                          kCCKeySizeDES,
                                          NULL,
                                          [data bytes],
                                          [data length],
                                          buffer,
                                          1024,
                                          &bufferNumBytes);
    if(cryptStatus == kCCSuccess)
    {
        NSData *returnData =  [NSData dataWithBytes:buffer length:bufferNumBytes];
        return returnData;
        //        NSString *returnString = [[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding]autorelease];
    }
    DEBUG_NSLOG(@"des failed！");
    return nil;
    
}




/******************************************************************************
 函数名称 : + (NSData *)DESEncrypt:(NSData *)data WithKey:(NSString *)key
 函数描述 : 文本数据进行DES加密
 输入参数 : (NSData *)data
 (NSString *)key
 输出参数 : N/A
 返回参数 : (NSData *)
 备注信息 : 此函数不可用于过长文本
 ******************************************************************************/
+ (NSData *)DESEncrypt:(NSData *)data WithKey:(NSString *)key
{
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeDES,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer);
    return nil;
}

/******************************************************************************
 函数名称 : + (NSData *)DESEncrypt:(NSData *)data WithKey:(NSString *)key
 函数描述 : 文本数据进行DES解密
 输入参数 : (NSData *)data
 (NSString *)key
 输出参数 : N/A
 返回参数 : (NSData *)
 备注信息 : 此函数不可用于过长文本
 ******************************************************************************/
+ (NSData *)DESDecrypt:(NSData *)data WithKey:(NSString *)key
{
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeDES,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer);
    return nil;
}



#pragma mark -

/******************************************************************************
 函数名称 : + (NSData *)dataWithBase64EncodedString:(NSString *)string
 函数描述 : base64格式字符串转换为文本数据
 输入参数 : (NSString *)string
 输出参数 : N/A
 返回参数 : (NSData *)
 备注信息 :
 ******************************************************************************/
+ (NSData *)dataWithBase64EncodedString:(NSString *)string
{
	if (string == nil)
		[NSException raise:NSInvalidArgumentException format:nil];
	if ([string length] == 0)
		return [NSData data];
	
	static char *decodingTable = NULL;
	if (decodingTable == NULL)
	{
		decodingTable = malloc(256);
		if (decodingTable == NULL)
			return nil;
		memset(decodingTable, CHAR_MAX, 256);
		NSUInteger i;
		for (i = 0; i < 64; i++)
			decodingTable[(short)encodingTable[i]] = i;
	}
	
	const char *characters = [string cStringUsingEncoding:NSASCIIStringEncoding];
	if (characters == NULL)     //  Not an ASCII string!
		return nil;
	char *bytes = malloc((([string length] + 3) / 4) * 3);
	if (bytes == NULL)
		return nil;
	NSUInteger length = 0;
	
	NSUInteger i = 0;
	while (YES)
	{
		char buffer[4];
		short bufferLength;
		for (bufferLength = 0; bufferLength < 4; i++)
		{
			if (characters[i] == '\0')
				break;
			if (isspace(characters[i]) || characters[i] == '=')
				continue;
			buffer[bufferLength] = decodingTable[(short)characters[i]];
			if (buffer[bufferLength++] == CHAR_MAX)      //  Illegal character!
			{
				free(bytes);
				return nil;
			}
		}
		
		if (bufferLength == 0)
			break;
		if (bufferLength == 1)      //  At least two characters are needed to produce one byte!
		{
			free(bytes);
			return nil;
		}
		
		//  Decode the characters in the buffer to bytes.
		bytes[length++] = (buffer[0] << 2) | (buffer[1] >> 4);
		if (bufferLength > 2)
			bytes[length++] = (buffer[1] << 4) | (buffer[2] >> 2);
		if (bufferLength > 3)
			bytes[length++] = (buffer[2] << 6) | buffer[3];
	}
	
	bytes = realloc(bytes, length);
	return [NSData dataWithBytesNoCopy:bytes length:length];
}


//
//
+(NSData*)base64Decodeding:(NSString *)string
{
    
	if (string == nil)
		[NSException raise:NSInvalidArgumentException format:@""];
	if ([string length] == 0)
		return [NSData data];

	static char *decodingTable = NULL;
	if (decodingTable == NULL)
	{
		decodingTable = malloc(256);
		if (decodingTable == NULL)
			return nil;
		memset(decodingTable, CHAR_MAX, 256);
		NSUInteger i;
		for (i = 0; i < 64; i++)
			decodingTable[(short)encodingTable[i]] = i;
	}
	const char *characters = [string cStringUsingEncoding:NSASCIIStringEncoding];
	if (characters == NULL)     //  Not an ASCII string!

		return nil;
	char *bytes = malloc((([string length] + 3) / 4) * 3);
	if (bytes == NULL)
		return nil;
	NSUInteger length = 0;
    memset(bytes, 0x0, (([string length] + 3) / 4) * 3);//
	NSUInteger i = 0;
	while (YES)
	{
		char buffer[4];
		short bufferLength;
		for (bufferLength = 0; bufferLength < 4; i++)
		{
			if (characters[i] == '\0')
				break;
			if (isspace(characters[i]) || characters[i] == '=')
				continue;
			buffer[bufferLength] = decodingTable[(short)characters[i]];
			if (buffer[bufferLength++] == CHAR_MAX)      //  Illegal character!
			{
				free(bytes);
				return nil;
			}
		}

		if (bufferLength == 0)
			break;
		if (bufferLength == 1)      //  At least two characters are needed to produce one byte!
		{
			free(bytes);
			return nil;
		}

		//  Decode the characters in the buffer to bytes.
		bytes[length++] = (buffer[0] << 2) | (buffer[1] >> 4);
		if (bufferLength > 2)
			bytes[length++] = (buffer[1] << 4) | (buffer[2] >> 2);
		if (bufferLength > 3)
			bytes[length++] = (buffer[2] << 6) | buffer[3];
	}
    
	bytes = realloc(bytes, length);
    return [NSData dataWithBytesNoCopy:bytes length:length];
}
+(NSString*)base64DecodedingToStr:(NSString *)string
{
    NSData * tmpData = [ISSFileOp base64Decodeding:string];
    NSString * tmpStr = [[NSString alloc] initWithData:tmpData encoding:NSUTF8StringEncoding];
    NSString * result = [NSString stringWithFormat:@"%@",tmpStr];
    [tmpStr release];
    return result;
}



/******************************************************************************
 函数名称 : + (NSString *)base64EncodedStringFrom:(NSData *)data
 函数描述 : 文本数据转换为base64格式字符串
 输入参数 : (NSData *)data
 输出参数 : N/A
 返回参数 : (NSString *)
 备注信息 :
 ******************************************************************************/
//+ (NSString *)base64EncodedStringFrom:(NSData *)data
//{
//	if ([data length] == 0)
//		return @"";
//
//    char *characters = malloc((([data length] + 2) / 3) * 4);
//	if (characters == NULL)
//		return nil;
//	NSUInteger length = 0;
//
//	NSUInteger i = 0;
//	while (i < [data length])
//	{
//		char buffer[3] = {0,0,0};
//		short bufferLength = 0;
//		while (bufferLength < 3 && i < [data length])
//			buffer[bufferLength++] = ((char *)[data bytes])[i++];
//
//		//  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
//		characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
//		characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
//		if (bufferLength > 1)
//			characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
//		else characters[length++] = '=';
//		if (bufferLength > 2)
//			characters[length++] = encodingTable[buffer[2] & 0x3F];
//		else characters[length++] = '=';
//	}
//
//	return [[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES];
//}


+(NSString *)base64Encoding:(NSData*)_data
{//调用base64的方法
	
	if ([_data length] == 0)
		return @"";
	
    char *characters = malloc((([_data length] + 2) / 3) * 4);
	
	if (characters == NULL)
		return nil;
	NSUInteger length = 0;
	
	NSUInteger i = 0;
	while (i < [_data length])
	{
		char buffer[3] = {0,0,0};
		short bufferLength = 0;
		while (bufferLength < 3 && i < [_data length])
			buffer[bufferLength++] = ((char *)[_data bytes])[i++];
		//  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
		characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
		characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
		if (bufferLength > 1)
			characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
		else characters[length++] = '=';
		if (bufferLength > 2)
			characters[length++] = encodingTable[buffer[2] & 0x3F];
		else characters[length++] = '=';
	}
	
	return [[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES] ;
}



#pragma mark - MD5
+(NSString *) makeMD5: (NSString *) inPutText
{
    const char *cStr = [inPutText UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, strlen(cStr), result);
    
    return [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] lowercaseString];
}


#pragma mark - 写 plist

//自动新增新的字典
+(void)writePlistFile:(NSString *)plistFileName setKey:(NSMutableArray *)keyName setValue:(NSMutableArray *)valueData
{
	NSString *ValueStr;
	NSString *KeyStr;
	NSMutableDictionary  *dictionary;
	NSString *documentsDirectory=plistFileName;
	
	if([[NSFileManager defaultManager] enumeratorAtPath:documentsDirectory])
		dictionary=[[NSMutableDictionary alloc]initWithContentsOfFile:documentsDirectory];
	else
		dictionary=[[NSMutableDictionary alloc]init];
	
	for (int i = 0; i<[keyName count]; i++)
	{
		ValueStr = [[NSString alloc] initWithFormat:@"%@",[valueData objectAtIndex:i]];
		KeyStr = [[NSString alloc] initWithFormat:@"%@",[keyName objectAtIndex:i]];
		
		[dictionary setValue:ValueStr forKey:KeyStr];
		
		[ValueStr release];
		[KeyStr release];
	}
	
	[dictionary writeToFile:documentsDirectory atomically:YES];
	[dictionary release];
	dictionary = nil;
	
	
	
}

// 方法3：完全使用unix c函数
+ (long long) folderSizeAtPathC:(NSString*) folderPath
{
    return [self _folderSizeAtPath:[folderPath cStringUsingEncoding:NSUTF8StringEncoding]];
}

#pragma mark - get Content Size
+(CGSize)getContentSizeWithString:(NSString *)text
                maxSize:(CGSize)aMaxSize
                   font:(UIFont *)font{
    CGSize contentSize = CGSizeZero;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        
        NSMutableParagraphStyle *paragraphStyle = [[[NSMutableParagraphStyle alloc]init] autorelease];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
        
        contentSize = [text boundingRectWithSize:aMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
        
    }
    else{
        contentSize = [text sizeWithFont:font constrainedToSize:aMaxSize lineBreakMode:NSLineBreakByCharWrapping];
    }
    return contentSize;
}
+(CGSize)getContentSizeWithString:(NSString *)text
                          maxSize:(CGSize)aMaxSize
                             font:(UIFont *)font
                         lineMode:(NSLineBreakMode*)lineMode
{
    CGSize contentSize = CGSizeZero;
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
//        
//        NSMutableParagraphStyle *paragraphStyle = [[[NSMutableParagraphStyle alloc]init] autorelease];
//        paragraphStyle.lineBreakMode = lineMode;
//        NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
//        NSStringDrawingOptions options =  NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
//        
//        contentSize = [text boundingRectWithSize:aMaxSize options:options attributes:attributes context:nil].size;
//        
//    }
//    else{
        contentSize = [text sizeWithFont:font constrainedToSize:aMaxSize lineBreakMode:lineMode];
//    }
    contentSize.width = MIN(aMaxSize.width, contentSize.width);
    contentSize.height = MIN(aMaxSize.height, contentSize.height);
    return contentSize;
}
+(void)setLineSpace:(CGFloat)lineSpace label:(UILabel*)label
{
    NSMutableAttributedString *attributedString = [[[NSMutableAttributedString alloc] initWithString:label.text] autorelease];
    NSMutableParagraphStyle *paragraphStyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
    [paragraphStyle setLineSpacing:lineSpace];//调整行间距
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [label.text length])];
    label.attributedText = attributedString;
}
+(void)addUnderLine:(UILabel*)label
{
    NSMutableAttributedString * attStrOld = [[[NSMutableAttributedString alloc] initWithString:label.text] autorelease];
    [attStrOld addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(0, label.text.length)];
    [attStrOld addAttribute:NSStrokeColorAttributeName value:GRAY_FONT_COLOR range:NSMakeRange(0, label.text.length)];
    [attStrOld addAttribute:NSForegroundColorAttributeName value:GRAY_FONT_COLOR range:NSMakeRange(0, label.text.length)];
    [label setAttributedText:attStrOld];
}
+(NSString*)checkHttpWith:(NSString*)oriSrc defaultStr:(NSString*)defaultStr
{
    if([oriSrc rangeOfString:@"http://"].location == NSNotFound)
        return [NSString stringWithFormat:@"%@/%@",defaultStr,oriSrc];
    else
        return oriSrc;
}
+(NSString*)getFloatStrSubZero:(CGFloat)num formatStr:(NSString*)formatStr negStr:(NSString *)negStr
{
    if(num < 0)return negStr;
    int tmp = (int)num;
    if(num > tmp)
        return [NSString stringWithFormat:formatStr,num];
    else
        return [NSString stringWithFormat:@"%.0f",num];
}

#pragma mark - play sound
+(void)preLoadSound:(NSString*)fileName
{
    [ISSFileOp playSound:fileName vol:0.0f];
}
+(void)playSound:(NSString*)fileName
{
    [ISSFileOp playSound:fileName vol:0.6f];
}
+(void)playSound:(NSString*)fileName vol:(CGFloat)vol
{
    if(fileName != nil)
    {
        UInt32 allowMixWithOthers =true;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers,sizeof(allowMixWithOthers), &allowMixWithOthers);
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        
        NSString * soundFilePath = [[NSBundle mainBundle] pathForResource:[fileName stringByDeletingPathExtension] ofType:[fileName pathExtension]];
        if(soundFilePath == nil)
            return;
        NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
        AVAudioPlayer * player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error: nil];
        [player setVolume:vol];
        [player prepareToPlay];
        [player play];
        [fileURL release];
    }
}
+(UIImage*)getImgByColor:(UIColor*)color size:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, 0, [UIScreen mainScreen].scale);
    [color set];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}


#pragma mark - check iDevice detail madel
+ (NSString*)iDeviceString
{
    
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    if ([deviceString isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([deviceString isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([deviceString isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5(GSM)";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5(GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5c(GSM)";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5c(GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5s(GSM)";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5s(GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"Verizon iPhone 4";
    if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceString isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"iPad2,5"])      return @"iPad Mini";
    if ([deviceString isEqualToString:@"iPad3,1"])      return @"iPad 3";
    if ([deviceString isEqualToString:@"iPad3,4"])      return @"iPad 4";
    if ([deviceString isEqualToString:@"iPad4,1"])      return @"iPad Air (Wifi)";
    if ([deviceString isEqualToString:@"iPad4,2"])      return @"iPad Air (GSM)";
    if ([deviceString isEqualToString:@"iPad4,4"])      return @"iPad Mini 2 (Wifi)";
    if ([deviceString isEqualToString:@"iPad4,5"])      return @"iPad Mini 2 (GSM)";
    if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";
    DEBUG_NSLOG(@"NOTE: Unknown device type: %@", deviceString);
    return deviceString;
}



#pragma mark - check Ver
/*
 return = -1   有错
 return = 0    aString > compareString
 return = 1    相同
 return = 2    aString < compareString
 */
+(int)compareVersionNumber:(NSString*)aString compareWith:(NSString*)compareString;
{
    int aStringVer[3] = {0,0,0};
    int cmpStringVer[3] = {0,0,0};
    
    NSArray *aStringAry = [aString componentsSeparatedByString:@"."];
    NSArray *cmpStringAry = [compareString componentsSeparatedByString:@"."];
    
    if (aStringAry.count >= 3 && cmpStringAry.count >= 3) {
        for (int i = 0 ; i < 3; i++) {
            aStringVer[i] = [[aStringAry objectAtIndex:i] intValue];
            cmpStringVer[i] = [[cmpStringAry objectAtIndex:i] intValue];
        }
        
        if (aStringVer[0] > cmpStringVer[0]) {
            return 0;
        }
        else if (aStringVer[0] < cmpStringVer[0]) {
            return 2;
        }
        else{
            if (aStringVer[1] > cmpStringVer[1]) {
                return 0;
            }
            else if (aStringVer[1] < cmpStringVer[1]) {
                return 2;
            }
            else{
                if (aStringVer[2] > cmpStringVer[2]) {
                    return 0;
                }
                else if (aStringVer[2] < cmpStringVer[2]) {
                    return 2;
                }
                else
                    return 1;
            }
        }
        
    }
    else if (cmpStringAry.count > aStringAry.count && aStringAry.count >= 2) {
            for (int i = 0 ; i < aStringAry.count; i++) {
                aStringVer[i] = [[aStringAry objectAtIndex:i] intValue];
                cmpStringVer[i] = [[cmpStringAry objectAtIndex:i] intValue];
            }
            
            if (aStringVer[0] > cmpStringVer[0]) {
                return 0;
            }
            else if (aStringVer[0] < cmpStringVer[0]) {
                return 2;
            }
            else{
                if (aStringVer[1] > cmpStringVer[1])
                    return 0;
                else if (aStringVer[1] < cmpStringVer[1])
                    return 2;
                else
                    return 1;
            }
        }
    else if (cmpStringAry.count < aStringAry.count && cmpStringAry.count >= 2){
        for (int i = 0 ; i < cmpStringAry.count; i++) {
            aStringVer[i] = [[aStringAry objectAtIndex:i] intValue];
            cmpStringVer[i] = [[cmpStringAry objectAtIndex:i] intValue];
        }
        
        if (aStringVer[0] > cmpStringVer[0]) {
            return 0;
        }
        else if (aStringVer[0] < cmpStringVer[0]) {
            return 2;
        }
        else{
            if (aStringVer[1] > cmpStringVer[1])
                return 0;
            else if (aStringVer[1] < cmpStringVer[1])
                return 2;
            else
                return 1;
        }
    }
    
    return -1;
}

+(NSString*)checkStrForMax:(NSString*)str max:(NSInteger)max
{
    if(str == nil){
        return @"";
    }
    if(str.length <= max)return str;
    NSInteger textLen = str.length;
    NSInteger emojiCount = 0;
    for(int i=0;i<textLen;i++){
        NSString * tmp = [str substringWithRange:NSMakeRange(i, 1)];
        NSInteger result = [tmp lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        if(result == 0){
            emojiCount++;
            if(emojiCount%2 == 0 && i >= max){
                return [str substringWithRange:NSMakeRange(0, i+1)];
            }
        }
    }
    return [str substringWithRange:NSMakeRange(0, max)];
}


+(NSString *)filterHTML:(NSString *)html
{
    NSScanner * scanner = [NSScanner scannerWithString:html];
    NSString * text = nil;
    while([scanner isAtEnd]==NO)
    {
        //找到标签的起始位置
        [scanner scanUpToString:@"<" intoString:nil];
        //找到标签的结束位置
        [scanner scanUpToString:@">" intoString:&text];
        //替换字符
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
    }
    return html;
}




#pragma mark - 图片修正与压缩

+(UIImage *)fixOrientation:(UIImage *)aImage {
    return [ISSAsyncImageView fixOrientation:aImage];
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}




+(UIImage *)squareImageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    double ratio;
    double delta;
    CGPoint offset;
    
    //make a new square size, that is the resized imaged width
    CGSize sz = CGSizeMake(newSize.width, newSize.width);
    
    //figure out if the picture is landscape or portrait, then
    //calculate scale factor and offset
    if (image.size.width > image.size.height) {
        ratio = newSize.width / image.size.width;
        delta = (ratio*image.size.width - ratio*image.size.height);
        offset = CGPointMake(delta/2, 0);
    } else {
        ratio = newSize.width / image.size.height;
        delta = (ratio*image.size.height - ratio*image.size.width);
        offset = CGPointMake(0, delta/2);
    }
    
    //make the final clipping rect based on the calculated values
    CGRect clipRect = CGRectMake(-offset.x, -offset.y,
                                 (ratio * image.size.width) + delta,
                                 (ratio * image.size.height) + delta);
    
    
    //start a new context, with scale factor 0.0 so retina displays get
    //high quality image
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(sz, YES, 0.0);
    } else {
        UIGraphicsBeginImageContext(sz);
    }
    UIRectClip(clipRect);
    [image drawInRect:clipRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}



+(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

+(UIImage*)getImageFromViewController:(UIViewController *)controller
{
    UIImage * result = nil;
    if(UIGraphicsBeginImageContextWithOptions != NULL)
        UIGraphicsBeginImageContextWithOptions( controller.view.frame.size, NO, 0.0);
    else
        UIGraphicsBeginImageContext( controller.view.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //获取图像
    [controller.view.layer renderInContext:context];
    result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}
+(UIImage*)getImageFromView:(UIView *)view
{
    UIImage * result = nil;
    if(UIGraphicsBeginImageContextWithOptions != NULL)
        UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 0.0);
    else
        UIGraphicsBeginImageContext(view.frame.size);
    
    //获取图像
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}
+(UIImage*)getImageFromView:(UIView *)view tarView:(UIView*)tarView
{
    CGRect  tarRect = [tarView convertRect:tarView.bounds toView:view];
    CGFloat scale = [UIScreen mainScreen].scale;
    tarRect.origin.x *= scale;
    tarRect.origin.y *= scale;
    tarRect.size.width *= scale;
    tarRect.size.height *= scale;
    
    UIImage * result = nil;
    if(UIGraphicsBeginImageContextWithOptions != NULL)
        UIGraphicsBeginImageContextWithOptions(tarRect.size, NO, 0.0);
    else
        UIGraphicsBeginImageContext(tarRect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, -1*tarRect.origin.x, -1*tarRect.origin.y);
    //获取图像
    [view.layer renderInContext:context];
    CGContextTranslateCTM(context, tarRect.origin.x, tarRect.origin.x);
    result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}
+(NSString *)URLEncodedString:(NSString*)src{
    NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                           (CFStringRef)src,
                                                                           NULL,
                                                                           CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                           kCFStringEncodingUTF8);
    [result autorelease];
    return result;
}
+(NSString*)URLDecodedString:(NSString*)src{
    NSString *result = (NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                           (CFStringRef)src,
                                                                                           CFSTR(""),
                                                                                           kCFStringEncodingUTF8);
    [result autorelease];
    return result;
}


@end


#pragma mark -
@implementation ISSFileOp(Private)
+(long long) _folderSizeAtPath:(const char*)folderPath
{
    long long folderSize = 0;
    DIR* dir = opendir(folderPath);
    if (dir == NULL) return 0;
    struct dirent* child;
    while ((child = readdir(dir))!=NULL) {
        if (child->d_type == DT_DIR && (
                                        (child->d_name[0] == '.' && child->d_name[1] == 0) || // 忽略目录 .
                                        (child->d_name[0] == '.' && child->d_name[1] == '.' && child->d_name[2] == 0) // 忽略目录 ..
                                        )) continue;
        
        int folderPathLength = strlen(folderPath);
        char childPath[1024]; // 子文件的路径地址
        stpcpy(childPath, folderPath);
        if (folderPath[folderPathLength-1] != '/'){
            childPath[folderPathLength] = '/';
            folderPathLength++;
        }
        stpcpy(childPath+folderPathLength, child->d_name);
        childPath[folderPathLength + child->d_namlen] = 0;
        if (child->d_type == DT_DIR){ // directory
            folderSize += [self _folderSizeAtPath:childPath]; // 递归调用子目录
            // 把目录本身所占的空间也加上
            struct stat st;
            if(lstat(childPath, &st) == 0) folderSize += st.st_size;
        }else if (child->d_type == DT_REG || child->d_type == DT_LNK){ // file or link
            struct stat st;
            if(lstat(childPath, &st) == 0) folderSize += st.st_size;
        }
    }
    return folderSize;
}

// 方法1：使用unix c函数来实现获取文件大小
+ (long long) fileSizeAtPath2:(NSString*) filePath{
    struct stat st;
    if(lstat([filePath cStringUsingEncoding:NSUTF8StringEncoding], &st) == 0){
        return st.st_size;
    }
    return 0;
}


@end

