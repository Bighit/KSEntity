//
//  ViewController.m
//  KSEntity
//
//  Created by Hantianyu on 15/7/21.
//  Copyright (c) 2015年 HTY. All rights reserved.
//

#import "ViewController.h"
#import "KSConnectionOperation.h"
#import "NSObject+NetWorking.h"
#import "NSObject+Mapping.h"
#import "EntityTest.h"
@interface ViewController ()
@property(nonatomic, strong) KSConnectionOperation *operation;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    for (int i = 0; i < 1000; i++) {
        EntityTest *test = [[EntityTest alloc]init];
        test.requestParamsKS = @{@"ip":@"63.223.108.42"};
        test.requestUrlStringKS = @"http://ip.taobao.com/service/getIpInfo.php";
        //        test.SupportBreakPointContinueTransfer=YES;
        [MappingTest setNetMapping:@{@"ip":@"addr"}];
        [test sendRequestFinish:^(BOOL isSuccess, NSError *err) {
            if (isSuccess) {
                KSLog(@"%@——%d", test.data.country, i);
                KSLog(@"%@——%d", test.code, i);
                KSLog(@"%@——%d", test.data.addr, i);
//                KSLog(@"%@——%d", test.test, i);
            } else {
                KSLog(@"%@", err.localizedDescription);
            }
        }];
    }
//
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    [button setFrame:CGRectMake(0, 50, 100, 100)];
//    [button setBackgroundColor:[UIColor redColor]];
//    [button addTarget:self action:@selector(sendRequest) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:button];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)sendRequest
{
    EntityTest *test = [[EntityTest alloc]init];
    test.requestParamsKS = @{@"ip":@"63.223.108.42"};
    test.requestUrlStringKS = @"http://ip.taobao.com/service/getIpInfo.php";
    //        test.SupportBreakPointContinueTransfer=YES;
    [test sendRequestFinish:^(BOOL isSuccess, NSError *err) {
        if (isSuccess) {
//            KSLog(@"%@", test.country);
        } else {
            KSLog(@"%@", err.localizedDescription);
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end