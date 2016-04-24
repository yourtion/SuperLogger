//
//  ViewController.m
//  SuperLoggerDemo
//
//  Created by YourtionGuo on 12/23/14.
//  Copyright (c) 2014 GYX. All rights reserved.
//

#import "ViewController.h"
#import <SuperLogger/SuperLogger.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addLog:(id)sender {
    NSLog(@"This is a log.");
}

- (IBAction)addCrash:(id)sender {
    [self delete:nil];
}

- (IBAction)l2logs:(id)sender {
    [[SuperLogger sharedInstance]cleanLogsByKeeping:2 deleteStarts:NO];
}
- (IBAction)l4logs:(id)sender {
    [[SuperLogger sharedInstance]cleanLogsByKeeping:2 deleteStarts:YES];
}
- (IBAction)delCrash:(id)sender {
     [[SuperLogger sharedInstance]deleteCrash];
}
- (IBAction)del5m:(id)sender {
    NSDate *five = [[NSDate date]dateByAddingTimeInterval:-60*5];
    [[SuperLogger sharedInstance]cleanLogsBefore:five deleteStarts:YES];
}

- (IBAction)showLogList:(id)sender {
    [self presentViewController:[[SuperLogger sharedInstance] getListView] animated:YES completion:nil];
}

@end
