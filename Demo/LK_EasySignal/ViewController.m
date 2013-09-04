//
//  ViewController.m
//  LK_EasySignal
//
//  Created by hesh on 13-9-4.
//  Copyright (c) 2013年 ilikeido. All rights reserved.
//

#import "ViewController.h"
#import "LK_EasySignal.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

ON_LKSIGNAL3(UIButton, UPINSIDE, signal){
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Test2" message:@"click now" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView showInView:self.view cancelSignalObject:nil sumbitSignalObject:nil];
}

ON_LKSIGNAL2(UIAlertView, signal){
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"Test3" delegate:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Sure" otherButtonTitles:nil, nil];
    sheet.tagString = @"TEST3";
    [sheet showInView:self.view];
}

ON_LKSIGNAL3(UIActionSheet, TEST3, signal){
    NSLog(@"Test3 is finished");
}



@end