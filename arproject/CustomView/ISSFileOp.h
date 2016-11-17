//
//  ISSFileOp.h
//  MideaApp
//
//  Created by 健 王 on 12-6-13.
//  Copyright (c) 2012年 iSoftStone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>

#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

//空字符串
#define     LocalStr_None           @""

@interface ISSFileOp : NSObject
{

}
+(NSString *)ReturnDocumentPath;
+(NSString *)ReturnLibFilePath;
+(BOOL)deleteFileFolderByPath2:(NSString *)pathName;
+(void)CreateFolderWithPath:(NSString *)folderPath;
+(BOOL)FileExist:(NSString*)filePath;
+(NSData *)desData:(NSData *)data key:(NSString *)keyString CCOperation:(CCOperation)op;//des

+(void)writePlistFile:(NSString *)plistFileName setKey:(NSMutableArray *)keyName setValue:(NSMutableArray *)valueData;
+ (long long) folderSizeAtPathC:(NSString*) folderPath;
+(NSString *)stringFromDate:(NSDate *)date;
+(NSDate *)dateFromString:(NSString *)dateString;
+(NSDate *)getAfterDateFromCurrentDateWithDay:(NSInteger)day;
+(BOOL)isBaseInfoOK;
+(NSString *)getLastUserId;
+(NSString *)getAutoUserId;
+(NSString *)ReturnLastUserSendBoxPath;
+(NSString *)ReturnLastUserUploadBoxPath;

+(void)writeBaseInfoLastUserType:(NSInteger)userType writeValue:(NSString*)value;
/******************************************************************************
 格式化时间格式
  ******************************************************************************/
+(NSString*)dateTimeToCNTime:(NSString*)dateTime;


+(NSString *)base64Encoding:(NSData*)_data;//base64 encode
+(NSData*)base64Decodeding:(NSString *)string;//base64 decode
+(NSString*)base64DecodedingToStr:(NSString*)string;

/******************************************************************************
 函数名称 : + (NSString *)base64StringFromText:(NSString *)text
 函数描述 : 将文本转换为base64格式字符串 , 带DES
 输入参数 : (NSString *)text    文本
 输出参数 : N/A
 返回参数 : (NSString *)    base64格式字符串
 备注信息 :
 ******************************************************************************/
+ (NSString *)base64StringFromText:(NSString *)text;

/******************************************************************************
 函数名称 : + (NSString *)textFromBase64String:(NSString *)base64
 函数描述 : 将base64格式字符串转换为文本 , 带DES
 输入参数 : (NSString *)base64  base64格式字符串
 输出参数 : N/A
 返回参数 : (NSString *)    文本
 备注信息 :
 ******************************************************************************/
+ (NSString *)textFromBase64String:(NSString *)base64;
+(NSString *)getFileCreateDate:(NSString *)fileName;

+(NSString *) makeMD5: (NSString *) inPutText;
+(void)preLoadSound:(NSString*)fileName;
+(void)playSound:(NSString*)fileName;
+(void)playSound:(NSString*)fileName vol:(CGFloat)vol;

+(NSString *) image2String:(UIImage *)image;
+(UIImage *) string2Image:(NSString *)string;
/*
 return = -1   有错
 return = 0    aString > compareString
 return = 1    相同
 return = 2    aString < compareString
 */
+(int)compareVersionNumber:(NSString*)aString compareWith:(NSString*)compareString;
+(NSString*)checkStrForMax:(NSString*)str max:(NSInteger)max;
+(NSString*)iDeviceString;
+(NSString *)filterHTML:(NSString *)html;
+(UIImage*)getImgByColor:(UIColor*)color size:(CGSize)size;


/*********************************
 get content size
*********************************/
+(CGSize)getContentSizeWithString:(NSString *)text
                maxSize:(CGSize)aMaxSize
                             font:(UIFont *)font;

+(CGSize)getContentSizeWithString:(NSString *)text
                          maxSize:(CGSize)aMaxSize
                             font:(UIFont *)font
                         lineMode:(NSLineBreakMode*)lineMode;

/**
 *	@brief	设置label行间距
 */
+(void)setLineSpace:(CGFloat)lineSpace label:(UILabel*)label;

+(void)addUnderLine:(UILabel*)label;

/**
 *	@brief	检查url中是否包含http，如果不包含用defaultstr补充
 */
+(NSString*)checkHttpWith:(NSString*)oriSrc defaultStr:(NSString*)defaultStr;
/**
 *	@brief	将float转换为str，小数点后边是0的不显示，如 23.0返回23 23.1返回23.1 negstr:当num<0时显示的字符串
 */
+(NSString*)getFloatStrSubZero:(CGFloat)num formatStr:(NSString*)formatStr negStr:(NSString*)negStr;


/**
 *	@brief	图片压缩和翻转
 *
 *	@param 	aImage 	原图片数据
 *
 *	@return	压缩和翻转后的数据
 */
+(UIImage *)fixOrientation:(UIImage *)aImage;


/**
 *	@brief	图片裁切成正方形
 *
 *	@param 	image 	原图片数据
 *	@param 	newSize 	裁切的大小
 *
 *	@return	裁切后的数据
 */
+(UIImage *)squareImageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;



/**
 *	@brief	图片裁切成指定大小
 *
 *	@param 	image 	原图片数据
 *	@param 	newSize 	裁切的大小
 *
 *	@return	裁切后的数据
 */
+(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;

+(UIImage*)getImageFromViewController:(UIViewController *)controller;
+(UIImage*)getImageFromView:(UIView *)view;
+(UIImage*)getImageFromView:(UIView *)view tarView:(UIView*)tarView;
+(NSString *)URLEncodedString:(NSString*)src;
+(NSString*)URLDecodedString:(NSString*)src;
@end

@interface ISSFileOp(Private)
+ (long long) fileSizeAtPath2:(NSString*) filePath;
+ (long long) _folderSizeAtPath: (const char*)folderPath;
@end