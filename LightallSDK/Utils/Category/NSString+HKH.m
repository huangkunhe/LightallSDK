//
//  NSString+HKH.m
//  HKHStrangeCallsSDK
//
//  Created by river on 2017/3/28.
//  Copyright © 2017年 richinfo. All rights reserved.
//

#import "NSString+HKH.h"

@implementation NSString (HKH)
#pragma mark - NSString+PJR相关
// Checking if String is Empty
- (BOOL)isBlank
{
    return ([[self removeWhiteSpacesFromString] isEqualToString:@""]) ? YES : NO;
}
//Checking if String is empty or nil
- (BOOL)isValid
{
    return ([[self removeWhiteSpacesFromString] isEqualToString:@""] || self == nil || [self isEqualToString:@"(null)"] || [self length] <= 0 || self == (id)[NSNull null]) ? NO :YES;
}

// remove white spaces from String
- (NSString *)removeWhiteSpacesFromString
{
    NSString *trimmedString = [self stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return trimmedString;
}

#pragma mark 替换字符串
- (NSString *)replaceCharcter:(NSString *)olderChar withCharcter:(NSString *)newerChar
{
    return  [self stringByReplacingOccurrencesOfString:olderChar withString:newerChar];
}

- (id)objectFromJSONString
{
    NSError *error = nil;
    id object = [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    if (error) {
        NSLog(@"JSON解析错误:%@",error.localizedDescription);
    }
    return object;
}

@end
