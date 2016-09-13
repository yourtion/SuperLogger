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

#define STARLIST @"SuperLogger_star"

@interface SuperLogger()
@property(strong, nonatomic) NSUserDefaults *userDefaults;
@property(strong, nonatomic) NSMutableArray *starList;
@property(strong, nonatomic) NSString *logDirectory;
@property(strong, nonatomic) NSString *logFilename;
@property(strong, nonatomic) NSString *logFileFormat;
@end

@implementation SuperLogger
{
    NSString *crash;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Do not init SuperLogger"
                                   reason:@"You should use [SuperLogger sharedInstance]"
                                 userInfo:nil];
    return nil;
}

+ (NSBundle *)getBundle
{
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"SuperLogger" ofType:@"bundle"]];
    if (!bundle) {
        bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[SuperLogger self]] pathForResource:@"SuperLogger" ofType:@"bundle"]];
    }
    return bundle;
}


/**
 *  SuperLogger sharedInstance
 */
+ (SuperLogger *)sharedInstance
{
    static SuperLogger*_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[SuperLogger alloc] initPrivate];
        _sharedInstance.enableStar =YES; //Default: Allow Star
        _sharedInstance.enableDelete =YES;
        _sharedInstance.enableMail=YES;
        _sharedInstance.enablePreview=YES;
        _sharedInstance.bundle = [SuperLogger getBundle];
    });
    return _sharedInstance;
}

/**
 *  SuperLogger initPrivate (set logDirectory)
 */
- (instancetype)initPrivate
{
    self = [super init];
    if (self) {
        self.userDefaults = [NSUserDefaults standardUserDefaults];
        if ([self.userDefaults objectForKey:STARLIST]) {
            self.starList = [[NSMutableArray alloc]initWithArray:[self.userDefaults objectForKey:STARLIST]];
        }else{
            self.starList = [[NSMutableArray alloc]init];
        }
        //将NSlog打印信息保存到Document目录下的Log文件夹下
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        self.logDirectory = [paths[0] stringByAppendingPathComponent:@"Log"];
        self.logFileFormat = @"yyyy-MM-dd_HH:mm:ss";
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
    
    NSString *dateStr = [SuperLoggerFunctions getDateTimeStringWithFormat:_logFileFormat];
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
    NSString *logDirectory = [paths[0] stringByAppendingPathComponent:@"Log"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:logDirectory]) {
        [fileManager createDirectoryAtPath:logDirectory  withIntermediateDirectories:YES attributes:nil error:nil];
    }

    NSString *logFilePath = [logDirectory stringByAppendingPathComponent:@"CrashLog.log"];
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
 */
-(NSArray *)getLogList
{
    return [SuperLoggerFunctions getFilenamelistOfType:@"log" fromDirPath:_logDirectory];
}

/**
 *  Get SuperLogerListView
 */
-(id)getListView
{
    return [[SuperLogerListView alloc]init];
}

/**
 *  Star with filename
 */
-(BOOL)starWithFilename:(NSString *)filename
{
    if ([self.starList containsObject:filename]) {
        [self.starList removeObject:filename];
    }else{
        [self.starList addObject:filename];
    }
    [self.userDefaults setObject:self.starList forKey:STARLIST];
    return [self.userDefaults synchronize];
}

/**
 *  Is file stared
 */
-(BOOL)isStaredWithFilename:(NSString *)filename
{
    return [self.starList containsObject:filename];
}

/**
 *  Clean all logs
 */
-(void)cleanLogs
{
    NSArray *files = [SuperLoggerFunctions getFilenamelistOfType:@"log" fromDirPath:_logDirectory];
    for (NSString *file in files) {
        if (![file isEqualToString: @"CrashLog.log"] &&
            ![file isEqualToString: self.logFilename]) {
            [self deleteLogWithFilename:file];
        }
    }
}

/**
 *  Delete crash logs
 */
-(void)deleteCrash
{
    [self deleteLogWithFilename:@"CrashLog.log"];
}

-(BOOL)cleanLogsByKeeping:(int)keepMaxLogs deleteStarts:(BOOL)starts
{
    NSMutableArray *logs = [[NSMutableArray alloc]initWithArray:[self getLogList]];
    [logs removeObject:@"CrashLog.log"];
    if (!starts) {
        for (NSString *file in _starList) {
            [logs removeObject:file];
        }
    }
    if (keepMaxLogs > 1 && [logs count] > keepMaxLogs) {
        [logs removeObjectsInRange:NSMakeRange(0, keepMaxLogs)];
        for (NSString *file in logs) {
            [self deleteLogWithFilename:file];
        }
    }else{
        return NO;
    }
    return YES;
}

-(BOOL)cleanLogsBefore:(NSDate *)before deleteStarts:(BOOL)starts
{
    NSMutableArray *logs = [[NSMutableArray alloc]initWithArray:[self getLogList]];
    [logs removeObject:@"CrashLog.log"];
    if (!starts) {
        for (NSString *file in _starList) {
            [logs removeObject:file];
        }
    }
    if (before) {
        for (NSString *file in logs) {
            NSDate *fileDate = [SuperLoggerFunctions getDateTimeFromString:[file substringToIndex:[file length]-4] withFormat:_logFileFormat];
            if ([fileDate timeIntervalSinceDate:before] < 0 && ![file isEqualToString: self.logFilename]) {
                [self deleteLogWithFilename:file];
            }
        }
    }else{
        return NO;
    }
    return YES;
}

/**
 *  Get logfile's NSData with filename
 */
-(NSData *)getDataWithFilename:(NSString *)filename
{
    NSString *logFilePath = [_logDirectory stringByAppendingPathComponent:filename];
    return [NSData dataWithContentsOfFile:logFilePath];
}

/**
 *  Delete Logfile With Filename
 */
-(void)deleteLogWithFilename:(NSString *)filename
{
    NSString *logFilePath = [_logDirectory stringByAppendingPathComponent:filename];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:logFilePath error:NULL];
}

@end
