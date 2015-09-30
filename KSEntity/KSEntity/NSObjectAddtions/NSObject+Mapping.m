//
//  NSObject+extension.m
//  KSEntity
//
//  Created by Hantianyu on 15/7/27.
//  Copyright (c) 2015年 HTY. All rights reserved.
//

#import "NSObject+Mapping.h"

@implementation NSObject (Mapping)

static const void *dbMappingKey;
static NSMutableDictionary *_classMapping;

- (NSDictionary *)ks_getPropertyNameAndClass
{
    NSMutableDictionary  *propertyNamesArray = [NSMutableDictionary dictionary];
    unsigned int    propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &propertyCount);

    for (unsigned int i = 0; i < propertyCount; ++i) {
        objc_property_t property = properties[i];
        const char      *name = property_getName(property);
        const char      *attribute=property_getAttributes(property);
        NSString *attributeString=[NSString stringWithUTF8String:attribute];
        NSArray  *array=[attributeString componentsSeparatedByString:@"\""];
        if (array.count>2) {
            [propertyNamesArray setObject:array[1] forKey:[NSString stringWithUTF8String:name]];
        }else
        {
            [propertyNamesArray setObject:@"" forKey:[NSString stringWithUTF8String:name]];
        }
    }

    free(properties);
    return propertyNamesArray;
}


- (instancetype)_initWithJsonDictionary:(NSDictionary *)keyValues
{
    self = [NSObject ks_reflectDataObject:self FromOtherObject:keyValues];
    return self;
}

- (id)ks_reflectDataObject:(id)container FromOtherObject:(id)dataSource
{

    if ([container getNetMapping]&&[dataSource isKindOfClass:[NSDictionary class]]) {
        dataSource = [container convertkeyValueDictionary:dataSource];
    }
    
    if ([dataSource isKindOfClass:[NSArray class]]) {
        NSMutableArray *arr = [NSMutableArray array];

        for (id obj in dataSource) {
            id data = [[[container class] alloc]init];
            [arr addObject:[self ks_reflectDataObject:data FromOtherObject:obj]];
        }

        return arr;
    } else if ([dataSource isKindOfClass:[NSDictionary class]]) {
        NSDictionary *propertyDic=[container ks_getPropertyNameAndClass];
        
        for (NSString *key in [propertyDic allKeys]) {
            
            id propertyValue = [dataSource valueForKey:key];
            if ([[propertyDic objectForKey:key] hasPrefix:@"NS"]||[(NSString *)[propertyDic objectForKey:key] length]==0) {
                if ([propertyValue ks_isValid]) {
                    if ([container isEqual:[self ks_reflectDataObject:container FromOtherObject:propertyValue]]) {
                        continue;
                    }
                    [container setValue:[self ks_reflectDataObject:container FromOtherObject:propertyValue] forKey:key];
                }
            }else
            {
                id customObject=[[NSClassFromString([propertyDic objectForKey:key]) alloc]init];
                [self ks_reflectDataObject:customObject FromOtherObject:propertyValue];
                [container setValue:customObject forKey:key];
            }
           
        }

        return container;
    } else {
        if ([dataSource ks_isValid]) {
            return dataSource;
        } else {
            return @"";
        }
    }
}

- (NSDictionary *)convertkeyValueDictionary:(NSDictionary *)dictionary
{
    //    NSDictionary *objectPropertys = [self objectPropertys];
    NSDictionary        *mapping = [self getNetMapping];
    NSMutableDictionary *dicTemp = [[NSMutableDictionary alloc] init];

    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj ks_isValid]) {
            NSString *useKey = mapping[key] ? : key;

            if ([obj isKindOfClass:[NSString class]]) {
                NSError *error = nil;
                id jsonObject = [NSJSONSerialization JSONObjectWithData:[obj dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];

                if (!error) {
                    obj = jsonObject;
                }
            }

            [dicTemp setObject:obj forKey:useKey];
        }
    }];
    return dicTemp;
}

- (NSDictionary *)getNetMapping
{
    if (_classMapping) {
        return [_classMapping objectForKey:NSStringFromClass([self class])];
    }else
    {
        return nil;
    }
}

+ (void)setNetMapping:(NSDictionary *)mapping
{
    static dispatch_once_t  once;
    dispatch_once(&once, ^{
        _classMapping = [[NSMutableDictionary alloc]init];
    });
    [_classMapping setObject:mapping forKey:NSStringFromClass([self class])];
}

- (NSDictionary *)getDbMapping
{
    NSDictionary *mapping = objc_getAssociatedObject(self, &dbMappingKey);

    return mapping;
}

- (void)setDbMapping:(NSDictionary *)mapping
{
    objc_setAssociatedObject(self, &dbMappingKey, mapping, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)ks_isValid
{
    return !(self == nil || [self isKindOfClass:[NSNull class]]);
}

@end