//
//  NSObject+extension.h
//  KSEntity
//
//  Created by Hantianyu on 15/7/27.
//  Copyright (c) 2015年 HTY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
@interface NSObject (Mapping)
- (NSDictionary *)ks_getPropertyNameAndClass;
- (id)ks_reflectDataObject:(id)container FromOtherObject:(id)dataSource;
- (instancetype)_initWithJsonDictionary:(NSDictionary *)keyValues;
+ (void)setNetMapping:(NSDictionary *)mapping;
- (void)setDbMapping:(NSDictionary *)mapping;
@end
