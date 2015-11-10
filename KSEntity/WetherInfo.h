//
//  WetherInfo.h
//  KSEntity
//
//  Created by Hantianyu on 15/11/9.
//  Copyright © 2015年 HTY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Aqi.h"
#import "BasicInfo.h"
#import "Suggestion.h"
@interface WetherInfo : NSObject
@property(nonatomic,strong)Aqi *aqi;
@property(nonatomic,strong)BasicInfo *basic;
@property(nonatomic,strong)Suggestion *suggestion;
@property(nonatomic,strong)NSArray *daily_forecast;
@property(nonatomic,strong)NSString *pres;
@property(nonatomic,strong)NSDictionary *now;
@end
