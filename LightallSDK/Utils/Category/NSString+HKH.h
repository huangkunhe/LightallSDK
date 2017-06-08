//
//  NSString+HKH.h
//  HKHStrangeCallsSDK
//
//  Created by river on 2017/3/28.
//  Copyright © 2017年 richinfo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HKH)

// NSString+PJR相关
-(BOOL)isBlank;
-(BOOL)isValid;
- (NSString *)removeWhiteSpacesFromString;
- (NSString *)replaceCharcter:(NSString *)olderChar withCharcter:(NSString *)newerChar;

- (id)objectFromJSONString;

@end
