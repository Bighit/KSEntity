//
//  ViewController.m
//  KSEntity
//
//  Created by Hantianyu on 15/7/21.
//  Copyright (c) 2015年 HTY. All rights reserved.
//

#import "ViewController.h"

#import "NSObject+NetWorking.h"
#import "NSArray+NetWorking.h"
#import "NSObject+Mapping.h"
#import "EntityTest.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSMutableArray *array=[[NSMutableArray alloc]init];
    for (int i=0; i<100; i++) {
        EntityTest *test = [[EntityTest alloc]init];
        test.requestUrlStringKS = @"http://ip.taobao.com/service/getIpInfo.php";
        test.requestParamsKS= @{@"ip":@"63.223.108.42"};
        [array addObject:test];
    }
    
    [array sendRequestFinish:^(BOOL isSuccess, NSError *err, NSUInteger index) {
        if (isSuccess) {
           [array enumerateObjectsUsingBlock:^(id  obj, NSUInteger idx, BOOL * stop) {
               NSLog(@"%@-%lu",[(EntityTest *)obj code],(unsigned long)idx);
           }];
        }else
        {
            NSLog(@"%ld%@",index,[err localizedDescription]);
        }
    }];
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end