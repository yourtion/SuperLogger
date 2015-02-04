//
//  SuperLoggerFunctions.m
//  LogToFileDemo
//
//  Created by YourtionGuo on 12/23/14.
//  Copyright (c) 2014 GYX. All rights reserved.
//

#import "SuperLoggerFunctions.h"

@implementation SuperLoggerFunctions
/**
 *  getDateTimeStringWithFormat
 */
+(NSString *)getDateTimeStringWithFormat:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:[NSLocale currentLocale ].localeIdentifier]];
    [formatter setDateFormat:format];
    return [formatter stringFromDate:[NSDate date]];
}

/**
 *  getDateTimeFromString
 */
+(NSDate *)getDateTimeFromString:(NSString *)string withFormat:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:[NSLocale currentLocale ].localeIdentifier]];
    [formatter setDateFormat:format];
    NSDate *date = [[NSDate alloc] init];
    date = [formatter dateFromString:string];
    return date;
}

/**
 *  getFilenamelistOfType
 */
+(NSArray *)getFilenamelistOfType:(NSString *)type fromDirPath:(NSString *)dirPath
{
    NSMutableArray *filenamelist = [NSMutableArray arrayWithCapacity:10];
    NSArray *tmplist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:nil];
    
    for (NSString *filename in tmplist) {
        NSString *fullpath = [dirPath stringByAppendingPathComponent:filename];
        if ([SuperLoggerFunctions isFileExistAtPath:fullpath]) {
            if ([[filename pathExtension] isEqualToString:type]) {
                [filenamelist  addObject:filename];
            }
        }
    }
    NSArray *sortedList = [filenamelist sortedArrayUsingComparator:^NSComparisonResult(NSString *str1, NSString *str2) {
        NSString *fileName1 = [str1 lastPathComponent];
        NSString *fileName2 = [str2 lastPathComponent];
        NSStringCompareOptions options = NSCaseInsensitiveSearch | NSNumericSearch;
        return [fileName2 compare:fileName1 options:options];
    }];
    return sortedList;
}

/**
 *  isFileExistAtPath
 */
+(BOOL)isFileExistAtPath:(NSString*)fileFullPath
{
    return [[NSFileManager defaultManager] fileExistsAtPath:fileFullPath];
}
@end
