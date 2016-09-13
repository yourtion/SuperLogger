//
//  SuperLogger.h
//  LogToFileDemo
//
//  Created by YourtionGuo on 12/23/14.
//  Copyright (c) 2014 GYX. All rights reserved.
//

#import <Foundation/Foundation.h>


#define SLLocalizedString(key, comment) [[SuperLogger sharedInstance].bundle localizedStringForKey:(key) value:comment table:@"SLLocalizable"]


@interface SuperLogger : NSObject
@property(strong, nonatomic) NSString *mailTitle;
@property(strong, nonatomic) NSString *mailContect;
@property(strong, nonatomic) NSArray *mailRecipients;
@property(assign,nonatomic) BOOL enableStar;
@property(assign,nonatomic) BOOL enablePreview;
@property(assign,nonatomic) BOOL enableMail;
@property(assign,nonatomic) BOOL enableDelete;
@property(strong, nonatomic) NSBundle *bundle;

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

/**
 *  Clean and keep numbers of logs
 *
 *  @param keepMaxLogs Number of logs you want to keep
 *  @param starts      Clean starts logs ?
 *
 *  @return Succeed to clean
 */
-(BOOL)cleanLogsByKeeping:(int)keepMaxLogs deleteStarts:(BOOL)starts;

/**
 *  Clean logs befor date
 *
 *  @param before The date you want to clean logs befor
 *  @param starts Clean starts logs ?
 *
 *  @return Succeed to clean
 */
-(BOOL)cleanLogsBefore:(NSDate *)before deleteStarts:(BOOL)starts;

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
