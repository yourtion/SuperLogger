//
//  SuperLogerListViewTableViewController.m
//  LogToFileDemo
//
//  Created by YourtionGuo on 12/23/14.
//  Copyright (c) 2014 GYX. All rights reserved.
//

#import "SuperLogerListView.h"
#import "SuperLogger.h"
#import <MessageUI/MessageUI.h>
#import "SuperLoggerPreviewView.h"

@interface SuperLogerListView ()<UIActionSheetDelegate, MFMailComposeViewControllerDelegate>
@property(strong,nonatomic) NSArray *fileList;
@property (strong) UINavigationBar* navigationBar;
@property (strong, nonatomic) NSString *tempFilename;
@end

@implementation SuperLogerListView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

-(void)layoutNavigationBar
{
    self.navigationBar.frame = CGRectMake(0, self.tableView.contentOffset.y, self.tableView.frame.size.width, self.topLayoutGuide.length + 44);
    self.tableView.contentInset = UIEdgeInsetsMake(self.navigationBar.frame.size.height, 0, 0, 0);
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self layoutNavigationBar];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self layoutNavigationBar];
}

- (void)loadView
{
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    self.tableView = [[UITableView alloc]initWithFrame:applicationFrame];
    self.view.backgroundColor=[UIColor whiteColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
     
    self.fileList = [[SuperLogger sharedInstance]getLogList];
    self.navigationItem.title = SLLocalizedString( @"SL_LogList",  @"Log file list");
    self.navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_navigationBar];
    [self.navigationBar pushNavigationItem:self.navigationItem animated:NO];
    UIBarButtonItem *backBtn=[[UIBarButtonItem alloc] initWithTitle:SLLocalizedString( @"SL_Back", @"Back") style:UIBarButtonItemStylePlain target:self action:@selector(done)];
    [self.navigationItem setLeftBarButtonItem:backBtn];
    if ([SuperLogger sharedInstance].enableDelete){
        UIBarButtonItem *cleanBtn=[[UIBarButtonItem alloc] initWithTitle:SLLocalizedString( @"SL_Clean", @"Clean") style:UIBarButtonItemStylePlain target:self action:@selector(clean)];
        [self.navigationItem setRightBarButtonItem:cleanBtn];
    }
}

-(void)done
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)clean
{
    [[SuperLogger sharedInstance]cleanLogs];
    self.fileList = nil;
    self.fileList = [[SuperLogger sharedInstance]getLogList];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fileList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]init];
    cell.textLabel.text = self.fileList[indexPath.row];
    if ([[SuperLogger sharedInstance] isStaredWithFilename:self.fileList[indexPath.row]]) {
        if ([SuperLogger sharedInstance].enableStar){
            cell.accessoryType = UITableViewCellAccessoryDetailButton;
        }
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    _tempFilename = _fileList[indexPath.row];
    [self exportTapped:cell];
}

/**
 *  Shows Alert controller after user tapped on a log file
 *
 *  @param sender object that triggered the alert controller
 */
- (void)exportTapped:(id)sender
{
    UITableViewCell *cell = (UITableViewCell *) sender;
    
    @try {
        NSBundle* myBundle;
        NSString *path = [[NSBundle mainBundle] pathForResource:@"SuperLogger" ofType:@"bundle"];
        myBundle = [NSBundle bundleWithPath:path];
        
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:cell.textLabel.text message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIPopoverPresentationController *popover = alertController.popoverPresentationController;
        if (popover) {
            alertController = [UIAlertController alertControllerWithTitle:cell.textLabel.text message:nil preferredStyle:UIAlertControllerStyleAlert];
            popover.sourceView = self.view;
            popover.sourceRect = CGRectMake((CGRectGetWidth(popover.sourceView.bounds)-2)*0.5f, (CGRectGetHeight(popover.sourceView.bounds)-2)*0.5f, 2, 2);// Show in center.
        }
        
        if ([SuperLogger sharedInstance].enableStar){
            [alertController addAction:[self getAlertActionEnableStar]];
        }
        
        if ([SuperLogger sharedInstance].enablePreview){
            
            [alertController addAction:[self getAlertActionEnablePreview]];
        }
        if ([SuperLogger sharedInstance].enableMail){
           
            [alertController addAction:[self getAlertActionEnableMail]];
        }
        
        if ([SuperLogger sharedInstance].enableDelete) {
            [alertController addAction:[self getAlertActionEnableDelete]];
        }
        
        UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:SLLocalizedString( @"SL_Cancel", @"Cancel") style:UIAlertActionStyleDefault handler:Nil];
        [alertController addAction:cancelAction];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self presentViewController:alertController animated:YES completion:nil];
        });
        
    }
    @catch (NSException * e)
    { NSLog(@"Exception: %@", e); }
}

- (UIAlertAction *)getAlertActionEnableStar {
    NSString *isStar = [[SuperLogger sharedInstance] isStaredWithFilename:_tempFilename] ? SLLocalizedString(@"SL_Unstar",@"Unstar"): SLLocalizedString( @"SL_Star",  @"Star");
    
    UIAlertAction * starAction = [UIAlertAction actionWithTitle:isStar style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        [[SuperLogger sharedInstance]starWithFilename:_tempFilename];
        self.fileList = nil;
        self.fileList = [[SuperLogger sharedInstance]getLogList];
        [self.tableView reloadData];
    }];
    
    return starAction;
}

- (UIAlertAction *)getAlertActionEnablePreview {
    UIAlertAction * previewAction = [UIAlertAction actionWithTitle:SLLocalizedString( @"SL_Preview", @"Preview")  style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        SuperLoggerPreviewView *pre = [[SuperLoggerPreviewView alloc]init];
        pre.logData = [[SuperLogger sharedInstance] getDataWithFilename:_tempFilename];
        pre.logFilename = _tempFilename;
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self presentViewController:pre animated:YES completion:nil];
        });
        
    }];
    return previewAction;
}

- (UIAlertAction *)getAlertActionEnableMail {
    UIAlertAction * mailAction = [UIAlertAction actionWithTitle:SLLocalizedString( @"SL_SendViaMail", @"Send via Email")  style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            SuperLogger *logger = [SuperLogger sharedInstance];
            NSData *tempData = [logger getDataWithFilename:_tempFilename];
            if (tempData != nil) {
                MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
                [picker setSubject:logger.mailTitle];
                [picker setToRecipients:logger.mailRecipients];
                [picker addAttachmentData:tempData mimeType:@"application/text" fileName:_tempFilename];
                [picker setToRecipients:@[]];
                [picker setMessageBody:logger.mailContect isHTML:NO];
                [picker setMailComposeDelegate:self];
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    @try {
                        [self presentViewController:picker animated:YES completion:nil];
                    }
                    @catch (NSException * e)
                    { NSLog(@"Exception: %@", e); }
                });
            }
        }];
        
    }];
    return mailAction;
}

- (UIAlertAction *)getAlertActionEnableDelete {
    UIAlertAction * deleteAction = [UIAlertAction actionWithTitle:SLLocalizedString( @"SL_Delete", @"Delete")  style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
        [[SuperLogger sharedInstance]deleteLogWithFilename:_tempFilename];
        self.fileList = nil;
        self.fileList = [[SuperLogger sharedInstance]getLogList];
        [self.tableView reloadData];
    }];
    return deleteAction;
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
