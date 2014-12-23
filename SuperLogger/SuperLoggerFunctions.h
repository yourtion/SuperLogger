//
//  SuperLoggerFunctions.h
//  LogToFileDemo
//
//  Created by YourtionGuo on 12/23/14.
//  Copyright (c) 2014 GYX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SuperLoggerFunctions : NSObject
+(NSString *)getDateTimeStringWithFormat:(NSString *)format;
+(NSArray *)getFilenamelistOfType:(NSString *)type fromDirPath:(NSString *)dirPath;
+(BOOL)isFileExistAtPath:(NSString*)fileFullPath;
@end
