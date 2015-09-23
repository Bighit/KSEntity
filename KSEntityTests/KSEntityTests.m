//
//  KSEntityTests.m
//  KSEntityTests
//
//  Created by Hantianyu on 15/7/21.
//  Copyright (c) 2015年 HTY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "EntityTest.h"
#import "KSConnectionOperation.h"
#import "NSObject+NetWorking.h"
#import "NSObject+Mapping.h"
@interface KSEntityTests : XCTestCase
@property(nonatomic,strong)EntityTest *entity;
@property(nonatomic,strong)KSConnectionOperation *operation;
@end

@implementation KSEntityTests

- (void)setUp {
    [super setUp];
    self.entity=[[EntityTest alloc]init];
    [self.entity setRequestUrlStringKS:@"/patientapi/intention_getIntentionDetail"];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testPrintNetworkInfo{
    KSLog(@"%@",self.entity.requestUrlStringKS);
}


//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//      
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
