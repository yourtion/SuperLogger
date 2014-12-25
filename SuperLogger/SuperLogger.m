//
//  SuperLogger.m
//  LogToFileDemo
//
//  Created by YourtionGuo on 12/23/14.
//  Copyright (c) 2014 GYX. All rights reserved.
//

#import "SuperLogger.h"
#import "SuperLoggerFunctions.h"
#import "SuperLogerListView.h"

@interface SuperLogger()
@property(strong, nonatomic) NSString *logDirectory;
@property(strong, nonatomic) NSString *logFilename;
@end

@implementation SuperLogger
{
    NSString *crash;
}

/**
 *  SuperLogger sharedInstance
 *
 *  @return SuperLogger sharedInstance
 */
+ (SuperLogger *)sharedInstance
{
    static SuperLogger*_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[SuperLogger alloc] init];
    });
    return _sharedInstance;
}

/**
 *  SuperLogger init (set logDirectory)
 *
 *  @return SuperLogger
 */
- (instancetype)init
{
    self = [super init];
    if (self) {
        //将NSlog打印信息保存到Document目录下的Log文件夹下
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        self.logDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Log"];
    }
    return self;
}

/**
 *  Start redirectNSLogToDocumentFolder
 */
-(void)redirectNSLogToDocumentFolder
{
    if(isatty(STDOUT_FILENO)) {
        return;
    }
    
    UIDevice *device = [UIDevice currentDevice];
    if([[device model] hasSuffix:@"Simulator"]){
        return;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![SuperLoggerFunctions isFileExistAtPath:_logDirectory]) {
        [fileManager createDirectoryAtPath:_logDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *dateStr = [SuperLoggerFunctions getDateTimeStringWithFormat:@"yyyy-MM-dd_HH:mm"];
    self.logFilename = [NSString stringWithFormat:@"%@.log",dateStr];
    NSString *logFilePath = [_logDirectory stringByAppendingPathComponent:_logFilename];
    
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
    
    NSSetUncaughtExceptionHandler (&UncaughtExceptionHandler);
}

void UncaughtExceptionHandler(NSException* exception)
{
    NSString *name = [exception name];
    NSString *reason = [exception reason];
    NSArray *symbols = [exception callStackSymbols]; // 异常发生时的调用栈
    NSMutableString *strSymbols = [ [ NSMutableString alloc ] init ]; //将调用栈拼成输出日志的字符串
    for (NSString *item in symbols){
        [strSymbols appendString: item];
        [strSymbols appendString: @"\r\n"];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *logDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Log"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:logDirectory]) {
        [fileManager createDirectoryAtPath:logDirectory  withIntermediateDirectories:YES attributes:nil error:nil];
    }

    NSString *logFilePath = [logDirectory stringByAppendingPathComponent:@"CashLog.log"];
    NSString *dateStr = [SuperLoggerFunctions getDateTimeStringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *crashString = [NSString stringWithFormat:@"<- %@ ->[ Uncaught Exception ]\r\nName: %@, Reason: %@\r\n[ Fe Symbols Start ]\r\n%@[ Fe Symbols End ]\r\n\r\n", dateStr, name, reason, strSymbols];
    
    if (![fileManager fileExistsAtPath:logFilePath]) {
        [crashString writeToFile:logFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }else{
        NSFileHandle *outFile = [NSFileHandle fileHandleForWritingAtPath:logFilePath];
        [outFile seekToEndOfFile];
        [outFile writeData:[crashString dataUsingEncoding:NSUTF8StringEncoding]];
        [outFile closeFile];
    }
}

/**
 *  Get all logfile
 *
 *  @return logfile list Array
 */
-(NSArray *)getLogList
{
    return [SuperLoggerFunctions getFilenamelistOfType:@"log" fromDirPath:_logDirectory];
}

/**
 *  Get SuperLogerListView
 *
 *  @return UITableView logger listview
 */
-(id)getListView
{
    return [[SuperLogerListView alloc]init];
}

/**
 *  Clean all logs
 */
-(void)cleanLogs
{
    NSArray *filename = [SuperLoggerFunctions getFilenamelistOfType:@"log" fromDirPath:_logDirectory];
    NSInteger count = filename.count;
    for (int i = 0; i<count; i++) {
        if (![[filename objectAtIndex:i]  isEqualToString: @"CashLog.log"]
            && ![[filename objectAtIndex:i] isEqualToString: self.logFilename]) {
            [self deleteLogWithFilename:[filename objectAtIndex:i]];
        }
    }
}

/**
 *  Get logfile's NSData with filename
 *
 *  @param filename log filename
 *
 *  @return logfile content data
 */
-(NSData *)getDataWithFilename:(NSString *)filename
{
    NSString *logFilePath = [_logDirectory stringByAppendingPathComponent:filename];
    return [NSData dataWithContentsOfFile:logFilePath];
}

/**
 *  Delete Logfile With Filename
 *
 *  @param filename log filename
 */
-(void)deleteLogWithFilename:(NSString *)filename
{
    NSString *logFilePath = [_logDirectory stringByAppendingPathComponent:filename];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:logFilePath error:NULL];
}

@end
