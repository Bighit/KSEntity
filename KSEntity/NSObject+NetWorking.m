//
//  NSObject+NetWorking.m
//  KSEntity
//
//  Created by Hantianyu on 15/7/23.
//  Copyright (c) 2015年 HTY. All rights reserved.
//

#import "NSObject+NetWorking.h"
#import <objc/runtime.h>
@implementation NSObject (NetWorking)

static const void *requestUrlStringKey;
static const void *requestParamsKey;
static const void *supportBreakPointContinueTransferKey;
- (NSString *)requestUrlStringKS
{
    return objc_getAssociatedObject(self, &requestUrlStringKey);
}

- (void)setRequestUrlStringKS:(NSString *)requestUrlString
{
    if (requestUrlString) {
        objc_setAssociatedObject(self, &requestUrlStringKey, requestUrlString, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    
}

- (NSString *)requestParamsKS
{
    return objc_getAssociatedObject(self, &requestParamsKey);
}

- (void)setRequestParamsKS:(NSString *)requestParams
{
    if (requestParams) {
        objc_setAssociatedObject(self, &requestParamsKey, requestParams, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }

}
- (BOOL)isSupportBreakPointContinueTransfer
{
    
    NSNumber *number= objc_getAssociatedObject(self, &supportBreakPointContinueTransferKey);
    return [number boolValue];
}

- (void)setSupportBreakPointContinueTransfer:(BOOL)isSupportBreakPointContinueTransfer
{

    NSNumber *number=[NSNumber numberWithBool:isSupportBreakPointContinueTransfer];
    objc_setAssociatedObject(self, &supportBreakPointContinueTransferKey, number, OBJC_ASSOCIATION_ASSIGN);
    
    
}
- (KSRequestManager *)requestManager
{
    return [KSRequestManager manager];
}

-(void)sendRequestFinish:(void (^)(BOOL isSuccess,NSError* err))block
{
    if (self.requestUrlStringKS) {
        
        [self.requestManager sendRequestUrlString:self.requestUrlStringKS
                                           params:self.requestParamsKS
                                           object:self
              isSupportBreakPointContinueTransfer:self.isSupportBreakPointContinueTransfer
                                           method:@"GET" finishBlock:block];
    }
    
}
-(void)postRequestFinish:(void (^)(BOOL isSuccess,NSError* err))block
{
    if (self.requestUrlStringKS) {
       
        [self.requestManager sendRequestUrlString:self.requestUrlStringKS
                                           params:self.requestParamsKS
                                           object:self
              isSupportBreakPointContinueTransfer:self.isSupportBreakPointContinueTransfer
                                           method:@"POST" finishBlock:block];
    }
    
}
-(void)cancelRequest
{
    [self.requestManager cancelRequestWithObject:self];
}
@end