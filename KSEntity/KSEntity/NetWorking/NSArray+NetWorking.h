//
//  NSArray+NetWorking.h
//  KSEntity
//
//  Created by Hantianyu on 15/9/25.
//  Copyright © 2015年 HTY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (NetWorking)
-(void)sendRequestFinish:(void (^)(BOOL isSuccess,NSError* err,NSUInteger index))block;
@end
