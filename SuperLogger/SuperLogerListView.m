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
    if (self) {
    }
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
    
    NSBundle* myBundle;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"SuperLogger" ofType:@"bundle"];
    myBundle = [NSBundle bundleWithPath:path];
    
    self.fileList = [[SuperLogger sharedInstance]getLogList];
    self.navigationItem.title = NSLocalizedStringFromTableInBundle( @"SL_LogList", @"SLLocalizable", myBundle, @"Log file list");
    self.navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_navigationBar];
    [self.navigationBar pushNavigationItem:self.navigationItem animated:NO];
    UIBarButtonItem *backBtn=[[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTableInBundle( @"SL_Back", @"SLLocalizable",myBundle, @"Back") style:UIBarButtonItemStylePlain target:self action:@selector(done)];
    [self.navigationItem setLeftBarButtonItem:backBtn];
    UIBarButtonItem *cleanBtn=[[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTableInBundle( @"SL_Clean",@"SLLocalizable", myBundle, @"Clean") style:UIBarButtonItemStylePlain target:self action:@selector(clean)];
    [self.navigationItem setRightBarButtonItem:cleanBtn];
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
    _tempFilename = [_fileList objectAtIndex:indexPath.row];
    [self exportTapped:self];
}

/**
 *  Shows Alert controller after user tapped on a log file
 *
 *  @param sender object that triggered the alert controller
 */
- (void)exportTapped:(id)sender
{
    
    //Oggerschummer 20150205
    //Replace original UIActionSheet implementation mwith modern implementation using UIAlertController
    //Thus delegate method below has been commented
    
    @try {
        
        
    NSBundle* myBundle;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"SuperLogger" ofType:@"bundle"];
    myBundle = [NSBundle bundleWithPath:path];
    
    UIAlertController * alertController = [[UIAlertController alloc] init];
   
    if ([SuperLogger sharedInstance].enableStar){
        NSString *isStar =isStar= [[SuperLogger sharedInstance] isStaredWithFilename:_tempFilename] ? NSLocalizedStringFromTableInBundle( @"SL_Unstar", @"SLLocalizable", myBundle,@"Unstar"): NSLocalizedStringFromTableInBundle( @"SL_Star", @"SLLocalizable", myBundle, @"Star");
    
        UIAlertAction * starAction = [UIAlertAction actionWithTitle:isStar style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                [[SuperLogger sharedInstance]starWithFilename:_tempFilename];
                self.fileList = nil;
                self.fileList = [[SuperLogger sharedInstance]getLogList];
                [self.tableView reloadData];
        }];
        [alertController addAction:starAction];
    }
    
    if ([SuperLogger sharedInstance].enablePreview){
        UIAlertAction * previewAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle( @"SL_Preview", @"SLLocalizable",myBundle, @"Preview")  style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
            SuperLoggerPreviewView *pre = [[SuperLoggerPreviewView alloc]init];
            pre.logData = [[SuperLogger sharedInstance] getDataWithFilename:_tempFilename];
            pre.logFilename = _tempFilename;
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [self presentViewController:pre animated:YES completion:nil];
            });

        }];
    
     [alertController addAction:previewAction];
    }
    if ([SuperLogger sharedInstance].enableMail){
    UIAlertAction * mailAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle( @"SL_SendViaMail", @"SLLocalizable", myBundle, @"Send via Email")  style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            SuperLogger *logger = [SuperLogger sharedInstance];
            NSData *tempData = [logger getDataWithFilename:_tempFilename];
            if (tempData != nil) {
                MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
                [picker setSubject:logger.mailTitle];
                [picker setToRecipients:logger.mailRecipients];
                [picker addAttachmentData:tempData mimeType:@"application/text" fileName:_tempFilename];
                [picker setToRecipients:[NSArray array]];
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
        [alertController addAction:mailAction];
    }
   
    if ([SuperLogger sharedInstance].enableDelete){
       UIAlertAction * deleteAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle( @"SL_Delete", @"SLLocalizable",myBundle, @"Delete")  style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
           [[SuperLogger sharedInstance]deleteLogWithFilename:_tempFilename];
           self.fileList = nil;
           self.fileList = [[SuperLogger sharedInstance]getLogList];
           [self.tableView reloadData];
       }];
       [alertController addAction:deleteAction];

    }
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle( @"SL_Cancel", @"SLLocalizable", myBundle, @"Cancel") style:UIAlertActionStyleDefault handler:Nil];
     [alertController addAction:cancelAction];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self presentViewController:alertController animated:YES completion:Nil];
    }];
    
    }
    @catch (NSException *exception) {
            //non critial error, lets ignore this for the time being
    }
    

}

//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    
//    if (buttonIndex ==  0) {
//        [[SuperLogger sharedInstance]starWithFilename:_tempFilename];
//        self.fileList = nil;
//        self.fileList = [[SuperLogger sharedInstance]getLogList];
//        [self.tableView reloadData];
//    }
//    else if (buttonIndex ==  1) {
//        SuperLoggerPreviewView *pre = [[SuperLoggerPreviewView alloc]init];
//        pre.logData = [[SuperLogger sharedInstance] getDataWithFilename:_tempFilename];
//        pre.logFilename = _tempFilename;
//        dispatch_async(dispatch_get_main_queue(), ^(void){
//            [self presentViewController:pre animated:YES completion:nil];
//        });
//    }
//    else if (buttonIndex == 2) {
//        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//            SuperLogger *logger = [SuperLogger sharedInstance];
//            NSData *tempData = [logger getDataWithFilename:_tempFilename];
//            if (tempData != nil) {
//                MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
//                [picker setSubject:logger.mailTitle];
//                [picker setToRecipients:logger.mailRecipients];
//                [picker addAttachmentData:tempData mimeType:@"application/text" fileName:_tempFilename];
//                [picker setToRecipients:[NSArray array]];
//                [picker setMessageBody:logger.mailContect isHTML:NO];
//                [picker setMailComposeDelegate:self];
//                dispatch_async(dispatch_get_main_queue(), ^(void){
//                    @try {
//                        [self presentViewController:picker animated:YES completion:nil];
//                    }
//                    @catch (NSException * e)
//                    { NSLog(@"Exception: %@", e); }
//                });
//            }
//        }];
//    }
//    else if (buttonIndex == 3) {
//        [[SuperLogger sharedInstance]deleteLogWithFilename:_tempFilename];
//        self.fileList = nil;
//        self.fileList = [[SuperLogger sharedInstance]getLogList];
//        [self.tableView reloadData];
//    }
//    
//}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
