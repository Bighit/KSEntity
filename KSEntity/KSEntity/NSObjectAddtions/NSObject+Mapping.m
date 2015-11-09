//
//  NSObject+extension.m
//  KSEntity
//
//  Created by Hantianyu on 15/7/27.
//  Copyright (c) 2015年 HTY. All rights reserved.
//

#import "NSObject+Mapping.h"
#import "NSObject+NetWorking.h"
@implementation NSObject (Mapping)

- (NSDictionary *)ks_getPropertyNameAndClass
{
    NSMutableDictionary *propertyNamesArray = [NSMutableDictionary dictionary];
    unsigned int        propertyCount = 0;
    objc_property_t     *properties = class_copyPropertyList([self class], &propertyCount);

    for (unsigned int i = 0; i < propertyCount; ++i) {
        objc_property_t property = properties[i];
        const char      *name = property_getName(property);
        const char      *attribute = property_getAttributes(property);
        NSString        *attributeString = [NSString stringWithUTF8String:attribute];
        NSArray         *array = [attributeString componentsSeparatedByString:@"\""];

        if (array.count > 2) {
            [propertyNamesArray setObject:array[1] forKey:[NSString stringWithUTF8String:name]];
        } else {
            [propertyNamesArray setObject:@"" forKey:[NSString stringWithUTF8String:name]];
        }
    }

    free(properties);
    return propertyNamesArray;
}

- (instancetype)_initWithJsonDictionary:(NSDictionary *)keyValues
{
    self = [NSObject ks_reflectDataObject:self FromOtherObject:keyValues key:nil];
    return self;
}

- (id)ks_reflectDataObject:(id)container FromOtherObject:(id)value key:(NSString *)key
{
    if ([container getNetMapping] && [value isKindOfClass:[NSDictionary class]]) {
        value = [container convertkeyValueDictionary:value];
    }

    if ([value isKindOfClass:[NSArray class]]) {
        NSMutableArray *arr = [NSMutableArray array];

        for (id obj in value) {
            NSDictionary *arrayMapping=[container getArrayMapping];
            if (arrayMapping&&key) {
                NSString * className=arrayMapping[key];
                id data=[[NSClassFromString(className) alloc]init];
                [arr addObject:[self ks_reflectDataObject:data FromOtherObject:obj key:nil]];
            }else
            {
                id data = [[[container class] alloc]init];
                [arr addObject:[self ks_reflectDataObject:data FromOtherObject:obj key:nil]];
            }
            
        }

        return arr;
    } else if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *propertyDic = [container ks_getPropertyNameAndClass];

        for (NSString *key in [propertyDic allKeys]) {
            id propertyValue = [value valueForKey:key];

            if ([[propertyDic objectForKey:key] hasPrefix:@"NS"] || ([(NSString *)[propertyDic objectForKey:key] length] == 0)) {
                if ([propertyValue ks_isValid]) {
                    if ([container isEqual:[self ks_reflectDataObject:container FromOtherObject:propertyValue key:key]]) {
                        continue;
                    }
                    
                    [container setValue:[self ks_reflectDataObject:container FromOtherObject:propertyValue key:key] forKey:key];
                }
            } else {
                id customObject = [[NSClassFromString([propertyDic objectForKey:key]) alloc]init];
                [self ks_reflectDataObject:customObject FromOtherObject:propertyValue key:key];
                [container setValue:customObject forKey:key];
            }
        }

        return container;
    } else {
        if ([value ks_isValid]) {
            return value;
        } else {
            return nil;
        }
    }
}

- (NSDictionary *)convertkeyValueDictionary:(NSDictionary *)dictionary
{
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


- (BOOL)ks_isValid
{
    return !(self == nil || [self isKindOfClass:[NSNull class]]);
}

@end