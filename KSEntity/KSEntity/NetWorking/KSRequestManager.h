//
//  KSRequestManager.h
//  KSEntity
//
//  Created by Hantianyu on 15/7/24.
//  Copyright (c) 2015年 HTY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSConnectionOperation.h"
typedef void (^ responseBlock)(BOOL isSuccess, NSError *err);

@interface KSRequestManager : NSObject

@property(nonatomic, strong) NSMutableDictionary    *requestHeaders;
@property(nonatomic, assign) NSInteger              timeout;
@property(nonatomic, assign) NSInteger              tryCount;

+ (KSRequestManager *)manager;

- (void)sendRequestUrlString                :(NSString *)urlString
        params                              :(NSDictionary *)params
        object                              :(id)object
        isSupportBreakPointContinueTransfer :(BOOL)isSupport
        method                              :(NSString *)method finishBlock:(responseBlock)block;
- (void)cancelAllRequest;
- (void)cancelRequestWithObject:(id)object;
- (void)setSuspended:(BOOL)suspended;
- (void)setUseCache:(BOOL)useCache;
@end