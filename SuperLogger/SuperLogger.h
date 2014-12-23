//
//  SuperLogger.h
//  LogToFileDemo
//
//  Created by YourtionGuo on 12/23/14.
//  Copyright (c) 2014 GYX. All rights reserved.
//

@interface SuperLogger : NSObject
@property(strong, nonatomic) NSString *mailTitle;
@property(strong, nonatomic) NSString *mailContect;
@property(strong, nonatomic) NSArray *mailRecipients;

+ (SuperLogger *)sharedInstance;
-(void)redirectNSLogToDocumentFolder;
-(NSArray *)getLogList;
-(id)getListView;
-(void)cleanLogs;
-(NSData *)getDataWithFilename:(NSString *)filename;
-(void)deleteLogWithFilename:(NSString *)filename;
@end
