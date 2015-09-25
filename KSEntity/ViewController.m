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
#import "NSArray+NetWorking.h"
#import "NSObject+Mapping.h"
#import "EntityTest.h"
@interface ViewController ()
@property(nonatomic, strong) KSConnectionOperation *operation;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSMutableArray *array=[[NSMutableArray alloc]init];
    for (int i=0; i<100; i++) {
        EntityTest *test = [[EntityTest alloc]init];
        test.requestUrlStringKS = @"http://10.1.7.100/doctorapi/newflow_getCasePostListBySpaceIdAndPaitentId?os=ios&xdebug=1&app=doctor&v=3.2.3&api=1.2&certificateToken=009cd921e8c06f8f467fe804a8034a04&deviceOpenUDID=6bf746daba8852f459b2420aaef0b0c1981ca586&userId=67967975&caseId=3459121353&caseType=flow&pageId=2&pageSize=10&patientId=3459108864&spaceId=67967975&tabType=all&userId=67967975";
        [array addObject:test];
    }
    [array sendRequestFinish:^(BOOL isSuccess, NSError *err, NSUInteger index) {
        if (isSuccess) {
           [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
               NSLog(@"%@-%lu",[(EntityTest *)obj errorCode],(unsigned long)idx);
           }];
        }else
        {
            NSLog(@"%lu-%@",(unsigned long)index,[err localizedDescription]);
        }
    }];
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end