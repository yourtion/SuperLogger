//
//  SuperLoggerFunctionsTest.m
//  SuperLogger
//
//  Created by YourtionGuo on 2/19/16.
//  Copyright © 2016 Yourtion. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SuperLoggerFunctions.h"

const NSString *kLogFileFormat = @"yyyy-MM-dd_HH:mm:ss";

@interface SuperLoggerFunctionsTest : XCTestCase
@end

@implementation SuperLoggerFunctionsTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGetDateTimeFromStringWithFormat {
    NSString *string1 = @"2015-01-12_12:16:11";
    NSDate *date1 = [SuperLoggerFunctions getDateTimeFromString:string1 withFormat:[kLogFileFormat copy]];
    XCTAssertEqual(date1.timeIntervalSince1970, 1421036171);
}

- (void)testGetDateTimeStringWithFormat {
    NSString *res = [SuperLoggerFunctions getDateTimeStringWithFormat:[kLogFileFormat copy]];
    XCTAssertNotNil(res);
    XCTAssertEqual(res.length, kLogFileFormat.length);
}

- (void)testFileNotExistAtPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *logDirectory = [paths[0] stringByAppendingPathComponent:@"log"];
    NSString *logFilePath = [logDirectory stringByAppendingPathComponent:@"hello"];
    BOOL exist = [SuperLoggerFunctions isFileExistAtPath:logFilePath];
    XCTAssertEqual(exist, NO);
}

@end
