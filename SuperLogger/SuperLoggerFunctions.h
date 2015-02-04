//
//  SuperLoggerFunctions.h
//  LogToFileDemo
//
//  Created by YourtionGuo on 12/23/14.
//  Copyright (c) 2014 GYX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SuperLoggerFunctions : NSObject

/**
 *  getDateTimeStringWithFormat
 *
 *  @param format like "yyyy-MM-dd HH:mm:ss"
 *
 *  @return NSString like 2014-12-02 12:59:30
 */
+(NSString *)getDateTimeStringWithFormat:(NSString *)format;

/**
 *  getDateTimeFromString
 *
 *  @param string like "2015-01-12 12:16:11"
 *  @param format like "yyyy-MM-dd HH:mm:ss"
 *
 *  @return NSDate from string
 */
+(NSDate *)getDateTimeFromString:(NSString *)string withFormat:(NSString *)format;

/**
 *  getFilenamelistOfType
 *
 *  @param type    fileTile like @"log"
 *  @param dirPath filePath
 *
 *  @return filename array
 */
+(NSArray *)getFilenamelistOfType:(NSString *)type fromDirPath:(NSString *)dirPath;

/**
 *  isFileExistAtPath
 *
 *  @param fileFullPath fileFullPath
 *
 *  @return is File Exist
 */
+(BOOL)isFileExistAtPath:(NSString*)fileFullPath;
@end
