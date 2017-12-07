//
//  SystemInvestigator.m
//  GPUImageDemo
//
//  Created by mac on 2017/12/7.
//  Copyright © 2017年 wsj. All rights reserved.
//

#import "SystemInvestigator.h"

@implementation SystemInvestigator

+(NSString *)appName{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    CFShow((__bridge CFTypeRef)(infoDictionary));
    NSString *app_Name = [infoDictionary objectForKey:@"CFBundleName"];
    return app_Name;
}

@end
