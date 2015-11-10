//
//  NSArray+NetWorking.m
//  KSEntity
//
//  Created by Hantianyu on 15/9/25.
//  Copyright © 2015年 HTY. All rights reserved.
//

#import "NSArray+NetWorking.h"
#import "NSObject+NetWorking.h"
@implementation NSArray (NetWorking)
-(void)sendRequestFinish:(void (^)(BOOL isSuccess,NSError* err,NSUInteger index))block
{
    __block BOOL        success = YES;
    __block NSUInteger  index = 0;
    __block NSError     *error;
    __block NSUInteger  count=0;
    dispatch_queue_t    queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t    group = dispatch_group_create();
    [self enumerateObjectsUsingBlock:^(id  obj, NSUInteger idx, BOOL * stop) {
        [obj sendRequestFinish:^(BOOL isSuccess, NSError *err) {
            count++;
            dispatch_group_async(group, queue, ^{
                if (!isSuccess) {
                    success = isSuccess;
                    index = idx;
                    error = err;
                }
            });
                if (count==self.count) {
                    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
                        block(success, error, index);
                    });

                }
           
        }];
    }];
    
}
@end
