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
    self.fileList = [[SuperLogger sharedInstance]getLogList];
    self.navigationItem.title = @"LogList";
    self.navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_navigationBar];
    [self.navigationBar pushNavigationItem:self.navigationItem animated:NO];
    UIBarButtonItem *backBtn=[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(done)];
    [self.navigationItem setLeftBarButtonItem:backBtn];
    UIBarButtonItem *cleanBtn=[[UIBarButtonItem alloc] initWithTitle:@"Clean" style:UIBarButtonItemStylePlain target:self action:@selector(clean)];
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
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _tempFilename = [_fileList objectAtIndex:indexPath.row];
    [self exportTapped:self];
}

- (void)exportTapped:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:_tempFilename
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Preview", @"Send via Email", @"Delete", nil];
    [actionSheet showInView:self.view];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex ==  0) {
        SuperLoggerPreviewView *pre = [[SuperLoggerPreviewView alloc]init];
        pre.logData = [[SuperLogger sharedInstance] getDataWithFilename:_tempFilename];
        pre.logFilename = _tempFilename;
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self presentViewController:pre animated:YES completion:nil];
        });
    }
    else if (buttonIndex == 1) {
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
                    [self presentViewController:picker animated:YES completion:nil];
                });
            }
        }];
    }
    else if (buttonIndex == 2) {
        [[SuperLogger sharedInstance]deleteLogWithFilename:_tempFilename];
        self.fileList = nil;
        self.fileList = [[SuperLogger sharedInstance]getLogList];
        [self.tableView reloadData];
    }
    
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
