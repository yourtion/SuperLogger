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
@end

@implementation SuperLogger

+ (SuperLogger *)sharedInstance
{
    static SuperLogger*_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[SuperLogger alloc] init];
    });
    return _sharedInstance;
}

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

-(void)redirectNSLogToDocumentFolder
{
    //如果已经连接Xcode调试则不输出到文件
    if(isatty(STDOUT_FILENO)) {
        return;
    }
    
    UIDevice *device = [UIDevice currentDevice];
    if([[device model] hasSuffix:@"Simulator"]){ //在模拟器不保存到文件中
        return;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if (![SuperLoggerFunctions isFileExistAtPath:_logDirectory]) {
        [fileManager createDirectoryAtPath:_logDirectory  withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    //每次启动后都保存一个新的日志文件中
    NSString *dateStr = [SuperLoggerFunctions getDateTimeStringWithFormat:@"yyyy-MM-dd_HH:mm"];
    NSString *logFilePath = [_logDirectory stringByAppendingFormat:@"/%@.log",dateStr];
    
    // 将log输入到文件
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
    
    //未捕获的Objective-C异常日志
    NSSetUncaughtExceptionHandler (&UncaughtExceptionHandler);
}

void UncaughtExceptionHandler(NSException* exception)
{
    NSString* name = [ exception name ];
    NSString* reason = [ exception reason ];
    NSArray* symbols = [ exception callStackSymbols ]; // 异常发生时的调用栈
    NSMutableString* strSymbols = [ [ NSMutableString alloc ] init ]; //将调用栈拼成输出日志的字符串
    for ( NSString* item in symbols )
    {
        [ strSymbols appendString: item ];
        [ strSymbols appendString: @"\r\n" ];
    }
    
    //将crash日志保存到Document目录下的Log文件夹下
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *logDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Log"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:logDirectory]) {
        [fileManager createDirectoryAtPath:logDirectory  withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *logDate = [SuperLoggerFunctions getDateTimeStringWithFormat:@"yyyy-MM-dd_HH:mm"];
    
    NSString *logFilePath = [logDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_Cash.log",logDate]];
    NSString *dateStr = [SuperLoggerFunctions getDateTimeStringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *crashString = [NSString stringWithFormat:@"<- %@ ->[ Uncaught Exception ]\r\nName: %@, Reason: %@\r\n[ Fe Symbols Start ]\r\n%@[ Fe Symbols End ]\r\n\r\n", dateStr, name, reason, strSymbols];
    
    //把错误日志写到文件中
    if (![fileManager fileExistsAtPath:logFilePath]) {
        [crashString writeToFile:logFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }else{
        NSFileHandle *outFile = [NSFileHandle fileHandleForWritingAtPath:logFilePath];
        [outFile seekToEndOfFile];
        [outFile writeData:[crashString dataUsingEncoding:NSUTF8StringEncoding]];
        [outFile closeFile];
    }
}

-(NSArray *)getLogList
{
    return [SuperLoggerFunctions getFilenamelistOfType:@"log" fromDirPath:_logDirectory];
}

-(id)getListView
{
    return [[SuperLogerListView alloc]init];
}

-(void)cleanLogs
{
    NSArray *filename = [SuperLoggerFunctions getFilenamelistOfType:@"log" fromDirPath:_logDirectory];
    NSInteger count = filename.count;
    for (int i = 0; i<count; i++) {
        [self deleteLogWithFilename:[filename objectAtIndex:i]];
    }
}

-(NSData *)getDataWithFilename:(NSString *)filename
{
    NSString *logFilePath = [_logDirectory stringByAppendingPathComponent:filename];
    return [NSData dataWithContentsOfFile:logFilePath];
}

-(void)deleteLogWithFilename:(NSString *)filename
{
    NSString *logFilePath = [_logDirectory stringByAppendingPathComponent:filename];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:logFilePath error:NULL];
}

@end
