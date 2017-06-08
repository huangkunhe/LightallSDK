
// +----------------------------------------------------------------------
// | ThinkDrive [ WE CAN DO IT JUST THINK IT ]
// +----------------------------------------------------------------------
// | Copyright (c) 2014 Richinfo. All rights reserved.
// +----------------------------------------------------------------------

#import "HKHEncryptHelper.h"
#import "TD_ER3DESEncrypt.h"
#import "NSString+TD_Encrypt3DESandBase64.h"

static NSString *const TD_ER3DESENCRYPY_KEY = @"river_hkh";

@implementation HKHEncryptHelper

+ (NSString *)encryptString:(NSString *)originalString
{
    TD_ER3DESEncrypt *encryptKey = [[TD_ER3DESEncrypt alloc] initWithKey:TD_ER3DESENCRYPY_KEY];
    return [encryptKey encryptString:originalString];
}

+ (NSString *)decryptString:(NSString *)encryptedString
{
    TD_ER3DESEncrypt *encryptKey = [[TD_ER3DESEncrypt alloc] initWithKey:TD_ER3DESENCRYPY_KEY];
    return [encryptKey decryptString:encryptedString];
}

@end
