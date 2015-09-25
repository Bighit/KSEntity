//
//  EntityTest.h
//  KSEntity
//
//  Created by Hantianyu on 15/7/23.
//  Copyright (c) 2015年 HTY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+NetWorking.h"
#import "MappingTest.h"
@interface EntityTest : NSObject

@property(nonatomic,copy)NSString *code;
@property(nonatomic,copy)NSString *errorCode;
@property(nonatomic,strong)MappingTest *data;
@end
