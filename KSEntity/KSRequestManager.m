//
//  KSRequestManager.m
//  KSEntity
//
//  Created by Hantianyu on 15/7/24.
//  Copyright (c) 2015年 HTY. All rights reserved.
//

#import "KSRequestManager.h"
#import "NSObject+Mapping.h"
@interface KSRequestManager ()

@property(strong, nonatomic) NSOperationQueue *downloadQueue;
@end
@implementation KSRequestManager

- (void)dealloc
{
    [self.downloadQueue cancelAllOperations];
}

- (instancetype)init
{
    self = [super init];

    if (self) {
        self.requestHeaders = [[NSMutableDictionary alloc]init];
        self.downloadQueue = [[NSOperationQueue alloc]init];

        self.downloadQueue.maxConcurrentOperationCount = 50;
        self.timeout = 15;
        self.tryCount = 1;
        NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024
            diskCapacity:20 * 1024 * 1024
            diskPath    :nil];

        [NSURLCache setSharedURLCache:URLCache];
    }

    return self;
}

+ (KSRequestManager *)manager
{
    static dispatch_once_t  once;
    static id               manager;

    dispatch_once(&once, ^{
        manager = [self new];
    });
    return manager;
}

- (void)sendRequestUrlString                :(NSString *)urlString
        params                              :(NSDictionary *)params
        object                              :(id)object
        isSupportBreakPointContinueTransfer :(BOOL)isSupport
        method                              :(NSString *)method
        finishBlock                         :(responseBlock)block
{
    __block id obj = object;

    [self cancelRequestWithObject:object];

    KSConnectionOperation *operation = [[KSConnectionOperation alloc]initWithUrl:urlString];

    [operation setUseAsyncRequestMethod:YES];
    [operation setTryCount:self.tryCount];
    [operation setTimeout:self.timeout];
    [operation setRequestParams:params];
    [operation setHTTPMethod:method];
    [operation setSupportBreakPointContinueTransfer:isSupport];
    operation.networkingCompleteBlock = ^(BOOL isSuccess, id jsonData, NSError *err)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            if (jsonData) {
                NSError *error;
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
                KSLog(@"%@", json);

                obj = [object _initWithJsonDictionary:json];
            }

            if (block) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
                    block(isSuccess, err);
                });
            }
        });
    };

    if (object) {
        objc_setAssociatedObject(object, @"KSENTITYOPERATION", operation, OBJC_ASSOCIATION_ASSIGN);
    }

    [self.downloadQueue addOperation:operation];
}

- (KSConnectionOperation *)getOperation:(id)object
{
    return objc_getAssociatedObject(object, @"KSENTITYOPERATION");
}

- (void)cancelAllRequest
{
    [self.downloadQueue cancelAllOperations];
}

- (void)cancelRequestWithObject:(id)object
{
    KSConnectionOperation *operation = [self getOperation:object];

    if (operation) {
        [operation cancel];
    }
}

- (void)setSuspended:(BOOL)suspended
{
    [self.downloadQueue setSuspended:suspended];
}

@end