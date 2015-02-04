//
//  SuperLogger.h
//  LogToFileDemo
//
//  Created by YourtionGuo on 12/23/14.
//  Copyright (c) 2014 GYX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SuperLogger : NSObject
@property(strong, nonatomic) NSString *mailTitle;
@property(strong, nonatomic) NSString *mailContect;
@property(strong, nonatomic) NSArray *mailRecipients;

/**
 *  SuperLogger sharedInstance
 *
 *  @return SuperLogger sharedInstance
 */
+ (SuperLogger *)sharedInstance;

/**
 *  Start redirectNSLogToDocumentFolder
 */
- (void)redirectNSLogToDocumentFolder;

/**
 *  Get all logfile
 *
 *  @return logfile list Array
 */
- (NSArray *)getLogList;
/**
 *  Get SuperLogerListView
 *
 *  @return UITableView logger listview
 */
- (id)getListView;

/**
 *  Star with filename
 *
 *  @param filename filename log filename
 *
 *  @return Is star succee
 */
- (BOOL)starWithFilename:(NSString *)filename;
/**
 *  Is file stared
 *
 *  @param filename log filename
 *
 *  @return is file stared
 */
- (BOOL)isStaredWithFilename:(NSString *)filename;

/**
 *  Clean all logs
 */
- (void)cleanLogs;

/**
 *  Delete crash log
 */
-(void)deleteCrash;

-(BOOL)cleanLogsBefore:(NSDate *)before keeping:(int)keepMaxLogs withStarts:(BOOL)starts;

/**
 *  Get logfile's NSData with filename
 *
 *  @param filename log filename
 *
 *  @return logfile content data
 */
- (NSData *)getDataWithFilename:(NSString *)filename;

/**
 *  Delete Logfile With Filename
 *
 *  @param filename log filename
 */
- (void)deleteLogWithFilename:(NSString *)filename;
@end
