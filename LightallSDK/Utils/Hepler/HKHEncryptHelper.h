
// +----------------------------------------------------------------------
// | ThinkDrive [ WE CAN DO IT JUST THINK IT ]
// +----------------------------------------------------------------------
// | Copyright (c) 2014 Richinfo. All rights reserved.
// +----------------------------------------------------------------------
#import <Foundation/Foundation.h>
/**
 *  加密工具类
 */
@interface HKHEncryptHelper : NSObject
+ (NSString *)encryptString:(NSString *)originalString;
+ (NSString *)decryptString:(NSString *)encryptedString;

@end
