//
//  NSObject+NetWorking.h
//  KSEntity
//
//  Created by Hantianyu on 15/7/23.
//  Copyright (c) 2015年 HTY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSRequestManager.h"
@interface NSObject (NetWorking)

@property(nonatomic,copy)NSString *requestUrlStringKS;  
@property(nonatomic,copy)NSDictionary *requestParamsKS;
@property(nonatomic,assign,getter=isSupportBreakPointContinueTransfer)BOOL supportBreakPointContinueTransfer;

-(void)sendRequestFinish:(void (^)(BOOL isSuccess,NSError* err))block;
-(void)postRequestFinish:(void (^)(BOOL isSuccess,NSError* err))block;
-(void)setSupportBreakPointContinueTransfer:(BOOL)isSupport;
-(void)cancelRequest;
//mapping
- (NSDictionary *)getNetMapping;
+ (void)setNetMapping:(NSDictionary *)mapping;
- (NSDictionary *)getArrayMapping;
+ (void)setArrayMapping:(NSDictionary *)mapping;
@end
