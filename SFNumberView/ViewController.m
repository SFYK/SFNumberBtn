//
//  ViewController.m
//  SFNumberView
//
//  Created by 王帅锋 on 2017/8/17.
//  Copyright © 2017年 WSF. All rights reserved.
//

#import "ViewController.h"
#import "SFNumberBtn.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    SFNumberBtn *numberBtn = [[SFNumberBtn alloc] initWithFrame:CGRectMake(100, 200, 20, 20)];
    numberBtn.number = 12;
    [self.view addSubview:numberBtn];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
