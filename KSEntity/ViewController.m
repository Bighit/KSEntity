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
#import "WetherInfo.h"
#import "ListData.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *appkey=@"41de2017b51d688a3c492d1dc6aace98";
    [[KSRequestManager manager].requestHeaders setObject:appkey forKey:@"apikey"];
    
    
    NSMutableArray *array=[[NSMutableArray alloc]init];
    for (int i=0; i<100; i++) {
        ListData *data = [[ListData alloc]init];
        data.requestUrlStringKS = @"http://apis.baidu.com/heweather/weather/free";
        data.requestParamsKS= @{@"city":@"beijing,shanghai"};
    [ListData setNetMapping:@{@"HeWeather data service 3.0":@"startPoint"}];
    [ListData setArrayMapping:@{@"startPoint":NSStringFromClass([WetherInfo class])}];
//    [data sendRequestFinish:^(BOOL isSuccess, NSError *err) {
//        [data.startPoint enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            WetherInfo *info=obj;
//            NSLog(@"%@%@(%@:%@)",info.basic.cnty,info.basic.city,info.basic.lat,info.basic.lon);
//            NSLog(@"%@",info.aqi.city.qlty);
//            NSLog(@"%@。%@",info.suggestion.comf.brf,info.suggestion.comf.txt);
//            
//        }];
//    }];
        [array addObject:data];
    }
    
    
    [array sendRequestFinish:^(BOOL isSuccess, NSError *err, NSUInteger index) {
        if (isSuccess) {
           [array enumerateObjectsUsingBlock:^(id  obj, NSUInteger idx, BOOL * stop) {
               ListData *data=obj;
                       [data.startPoint enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                           WetherInfo *info=obj;
                           NSLog(@"%@%@(%@:%@)",info.basic.cnty,info.basic.city,info.basic.lat,info.basic.lon);
                           NSLog(@"%@",info.aqi.city.qlty);
                           NSLog(@"%@。%@",info.suggestion.comf.brf,info.suggestion.comf.txt);
                           
                       }];           }];
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