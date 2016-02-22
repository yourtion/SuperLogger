//
//  SuperLoggerTests.m
//  SuperLoggerTests
//
//  Created by YourtionGuo on 2/19/16.
//  Copyright © 2016 Yourtion. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SuperLogger.h"
#import "SuperLoggerFunctions.h"
#import "SuperLoggerPreviewView.h"

const NSString *kTestInfo = @"Hello";
const NSString *kCrashLogFileName = @"CrashLog.log";

@interface SuperLoggerTests : XCTestCase
@end

@implementation SuperLoggerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSharedInstance {
    SuperLogger *logger = [SuperLogger sharedInstance];
    [logger redirectNSLogToDocumentFolder];
    XCTAssertNotNil(logger);
}

- (void)testGetLogList {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *logDirectory = [paths[0] stringByAppendingPathComponent:@"log"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![SuperLoggerFunctions isFileExistAtPath:logDirectory]) {
        [fileManager createDirectoryAtPath:logDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSArray *files = [SuperLoggerFunctions getFilenamelistOfType:@"log" fromDirPath:logDirectory];
    for (NSString *file in files) {
        NSString *logFilePath = [logDirectory stringByAppendingPathComponent:file];
        [fileManager removeItemAtPath:logFilePath error:NULL];
    }
    
    SuperLogger *logger = [SuperLogger sharedInstance];
    NSArray *res1 = [logger getLogList];
    XCTAssertEqual(res1.count, 0);
    NSString *dateStr = [SuperLoggerFunctions getDateTimeStringWithFormat:@"yyyy-MM-dd_HH:mm:ss"];
    NSString *logFilename = [NSString stringWithFormat:@"%@.log",dateStr];
    NSString *logFilePath = [logDirectory stringByAppendingPathComponent:logFilename];
    [kTestInfo writeToFile:logFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    res1 = [logger getLogList];
    XCTAssertEqual(res1.count, 1);
}

- (void)testIsStarFile {
    SuperLogger *logger = [SuperLogger sharedInstance];
    NSArray *res1 = [logger getLogList];
    XCTAssertEqual(res1.count, 1);
    BOOL notStar = [logger isStaredWithFilename:res1.lastObject];
    XCTAssertEqual(notStar, NO);
    [logger starWithFilename:res1[0]];
    BOOL stared = [logger isStaredWithFilename:res1.lastObject];
    XCTAssertEqual(stared, YES);
}

- (void)testPreview {
    SuperLogger *logger = [SuperLogger sharedInstance];
    NSArray *res1 = [logger getLogList];
    XCTAssertEqual(res1.count, 1);
    SuperLoggerPreviewView *view = [[SuperLoggerPreviewView alloc]init];
    view.logFilename = res1[0];
    view.logData = [logger getDataWithFilename:res1.lastObject];
    [view viewDidLoad];
    XCTAssertEqual(view.navigationItem.title, res1.lastObject);
    UITextView *textView;
    for (UIView *v in view.view.subviews) {
        if (v.tag == 999) {
            textView = (UITextView *)v;
        }
    }
    XCTAssertEqualObjects(textView.text, kTestInfo);
}

- (void)testGetDataWithFilename {
    SuperLogger *logger = [SuperLogger sharedInstance];
    NSArray *res1 = [logger getLogList];
    XCTAssertGreaterThanOrEqual(res1.count, 1);
    NSData *data = [logger getDataWithFilename:res1.lastObject];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    XCTAssertEqualObjects(str, kTestInfo);
}

- (void)testDeleteCrash {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *logDirectory = [paths[0] stringByAppendingPathComponent:@"log"];
    NSString *CrashLogFilePath = [logDirectory stringByAppendingPathComponent:[[kCrashLogFileName copy] copy]];
    [kTestInfo writeToFile:CrashLogFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    SuperLogger *logger = [SuperLogger sharedInstance];
    NSData *data = [logger getDataWithFilename:[kCrashLogFileName copy]];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    XCTAssertEqualObjects(str, kTestInfo);
    [logger deleteCrash];
    XCTAssertNil([logger getDataWithFilename:[kCrashLogFileName copy]]);
}

@end
