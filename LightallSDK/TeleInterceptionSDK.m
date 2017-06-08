//
//  TeleInterceptionSDK.m
//  TeleInterceptionSDK
//
//  Created by river on 2017/3/28.
//  Copyright © 2017年 richinfo. All rights reserved.
//

#import "TeleInterceptionSDK.h"

@implementation TeleInterceptionSDK

-(BOOL)initSDK:(NSString *)hostUrl withGroupId:(NSString *)groudId
{
    [UserDefaults setObject:hostUrl forKey:kNumVersionDataHostC];
    [UserDefaults setObject:groudId forKey:kNumVersionDataGroupC];
    [UserDefaults synchronize];
    
    return YES;
}

-(BOOL)isNeedUpdateStrangeCallsCompletion:(SCResultBlock)successBlock
                                  onError:(SCErrorBlock)errorBlock
{
    //本地检查
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray * nums =[[TDEntity sharedTDEntity] queryWithClass:[SCVersionModel class] condition:nil sqlOrder:nil];
    
    NSString *cachePath = [CacheVersionDataPath stringByAppendingPathComponent:kNumVersionDataVersionflie];
    
    if ([nums count] > 0) {
        
        
        if ([fileManager fileExistsAtPath:cachePath]) {
            NSDictionary *resultObj = [NSDictionary dictionaryWithContentsOfFile:cachePath];
            NSLog(@"%@",resultObj);
            //3、进行与本地数据对比
            SCVersionModel * oldModel = nums[0];
            SCVersionModel * model = [SCVersionModel modelWithDictionary:resultObj];
            if ([model.version intValue] >[oldModel.version intValue])
            {
                if (successBlock) {
                    successBlock(YES,cachePath);
                    return YES;
                }
            }
        }
    }
    //当本地数据库等于本地配置文件 或数据库无数据、无配置的时候，需要请求配置信息
    //1、网络请求配置信息
    NSString *url = [UserDefaults objectForKey:kNumVersionDataHostC] ?[UserDefaults objectForKey:kNumVersionDataHostC] : kNumVersionDataHost;
    [[HKHNetworkHelper new] getGitUpdateVersion:url finished:^(BOOL result, NSString *path) {
        if (result) {
            //2、进行数据获取
            if ([fileManager fileExistsAtPath:cachePath]) {
                NSDictionary *resultObj = [NSDictionary dictionaryWithContentsOfFile:cachePath];
                NSLog(@"%@",resultObj);
                //3、进行与本地数据对比
                SCVersionModel * model = [SCVersionModel modelWithDictionary:resultObj];
                if ([nums count] <= 0 ) {
                    if (successBlock) {
                        successBlock(YES,cachePath);
                    }
                }else
                {
                    SCVersionModel * oldModel = nums[0];
                    if ([model.version intValue] >[oldModel.version intValue]) {
                        if (successBlock) {
                            successBlock(YES,cachePath);
                        }
                    }else
                    {
                        if (successBlock) {
                            successBlock(NO,cachePath);
                        }
                    }
                }
            }
            
        }else
        {
            if (errorBlock) {
                errorBlock(500,kErrorMessage);
            }
        }
    }];
    return YES;
}

-(void)updateStrangeCallsWithSuccess:(SCSimpleBlock)success
                         withFailure:(SCErrorBlock)failure
                        withProgress:(SCProgressBlock)progress
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *vpath = [CacheVersionDataPath stringByAppendingPathComponent:kNumVersionDataVersionflie];
    NSString * hostUrl =@"";
    if ([fileManager fileExistsAtPath:vpath]) {
        NSDictionary *resultObj = [NSDictionary dictionaryWithContentsOfFile:vpath];
        SCVersionModel * model = [SCVersionModel modelWithDictionary:resultObj];
        hostUrl = model.downurl;
    }else
    {
        if (failure) {
            failure(500,@"找不到服务");
        }
        return;
    }
    [[HKHNetworkHelper new]getGitNumData:hostUrl progress:^(double doub) {
        
        if (progress) {
            progress(doub*0.7);
        }
        
    } finished:^(BOOL result, NSString *path) {
        if (result) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                NSString * ppath =[path stringByAppendingPathComponent:kNumDataVersionflie];
                if ([fileManager fileExistsAtPath:ppath]) {
                    NSDictionary *dicObj = [NSDictionary dictionaryWithContentsOfFile:ppath];
                    NSString *jsonStringS =[HKHEncryptHelper decryptString:dicObj[@"response"]];
                    NSDictionary *responseDict = [jsonStringS objectFromJSONString];
                    NSDictionary * resultDict = responseDict[@"result"];
                    NSArray *resultObjs =resultDict[@"markList"];
                    
                    if (progress) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            progress(0.73);
                        });
                        
                    }
                    if (progress) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            progress(0.75);
                        });

                        
                    }
                    NSMutableArray * array = [NSMutableArray new];
                    //2、保存号码数据
                    for (int i=0; i < resultObjs.count; i++){
                        
                         NSDictionary * dic=(NSDictionary *)resultObjs[i];
                        //手机号码+86
                        NSString *phone = (NSString *)dic[@"phone"];

                        if (![phone isValid]) {
                            return;
                        }
                        
                        SCPhoneNumber * num =  [SCPhoneNumber modelWithDictionary:dic];
                        //区号，去除0，补86
                        if ([phone isPhoneNumber]||[phone isLandlineNumber]) {
                            NSString *numString = [NSString stringWithFormat:@"+86%@",num.phone];
                            num.phone =@([numString integerValue]);
                        }
                        if ([num.phone integerValue] <=0) {
                            NSString *numString = [NSString stringWithFormat:@"+86%@",phone];
                            num.phone =@([numString integerValue]);
                        }
                        [array addObject:num];
                        
                        if (progress) {
                            if(resultObjs.count/5==i||resultObjs.count/5*2==i||resultObjs.count/5*3==i||resultObjs.count/5*4==i){
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    progress(0.75+0.1*i/resultObjs.count);
                                    
                                });
                            }
                        }
                    }
                   NSArray *myArray=[[TDEntity sharedTDEntity]queryWithClass:[SCPhoneNumber class] condition:@{@"source":kMY} sqlOrder:@"ORDER BY phone ASC"];
                    
                    [array addObjectsFromArray:myArray];
                    
                    NSArray *resultObj = [array sortedArrayUsingComparator:^NSComparisonResult(SCPhoneNumber * obj1, SCPhoneNumber* obj2) {
                        
                        if ([obj1.phone integerValue] > [obj2.phone integerValue]) {
                            return (NSComparisonResult)NSOrderedDescending;
                        }
                        if ([obj1.phone integerValue] < [obj2.phone integerValue]) {
                            return (NSComparisonResult)NSOrderedAscending;
                        }
                        return (NSComparisonResult)NSOrderedSame;
                    }];
                    
                    //1、删除本地数据
                    [[TDEntity sharedTDEntity]deleteWithClass:[SCPhoneNumber class] condition:nil];
                    
                    for (int j=0; j<resultObj.count; j++) {
                        SCPhoneNumber * num =resultObj[j];
                        num.indexID=j+1;
                        if (![num.tagStr isEqualToString:kBlackList]) {
                         num.tagStr=kMrakList;
                        }
                        [[TDEntity sharedTDEntity]saveWithClass:[SCPhoneNumber class] model:num];
                        if (progress) {
                            if(resultObj.count/5==j||resultObj.count/5*2==j||resultObj.count/5*3==j||resultObj.count/5*4==j){
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    progress(0.85+0.1*j/resultObj.count);
                                    
                                });
                            }
                        }

                        
                    }
                    
                    
                    if (progress) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                             progress(0.98);
                        });
                    }
                    //3、更新本地配置
                    if ([fileManager fileExistsAtPath:vpath]) {
                        [[TDEntity sharedTDEntity]deleteWithClass:[SCVersionModel class] condition:nil];
                        NSDictionary *resultObj = [NSDictionary dictionaryWithContentsOfFile:vpath];
                        SCVersionModel * model = [SCVersionModel modelWithDictionary:resultObj];
                        [[TDEntity sharedTDEntity]saveWithClass:[SCVersionModel class] model:model];
                    }
                    
                    if (progress) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                           progress(1.00);
                        });

                       
                    }
                    if (success) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                          success();
                        });

                        
                    }
                    
                }else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (failure) {
                            failure(500,kErrorMessage);
                        }
                    });

                    
                }
            });
            
        }else
        {
            if (failure) {
                failure(500,kErrorMessage);
            }
        }
        
    } failed:^(NSError *error) {
        if (error) {
            if (failure) {
                
                failure(error.code,error.domain);
            }
        }
    }];
}

-(NSArray *)getAllMarkedNumber{
    return [[TDEntity sharedTDEntity]queryWithClass:[SCPhoneNumber class] condition:@{@"tagStr <>":kBlackList} sqlOrder:@"ORDER BY phone ASC"];
    
}

-(NSArray *)getMarkedNumber:(long)from to:(long)to{
    return [[TDEntity sharedTDEntity]queryWithClass:[SCPhoneNumber class] condition:@{@"tagStr <>":kBlackList,@"indexID >=":@(from),@"indexID <=":@(to)} sqlOrder:@"ORDER BY phone ASC"];
}

-(NSArray *)getAllBlackNumber{
    return [[TDEntity sharedTDEntity]queryWithClass:[SCPhoneNumber class] condition:@{@"tagStr":kBlackList} sqlOrder:@"ORDER BY phone ASC"];
}

-(NSArray *)getBlackNumber:(long)from to:(long)to{
    
    return [[TDEntity sharedTDEntity]queryWithClass:[SCPhoneNumber class] condition:@{@"tagStr":kBlackList,@"indexID >=":@(from),@"indexID <=":@(to)} sqlOrder:@"ORDER BY phone ASC"];
}

-(BOOL)markCallNumber:(NSString *)callNumber withInfo:(NSString *)info
{
    SCPhoneNumber * num = [SCPhoneNumber new];
    num.phone =@([callNumber integerValue]);
    num.mark = info;
    num.tagStr =kMrakList;
    num.source = kMY;
    //jia indexid
    //区号，去除0，补86
    if ([callNumber isPhoneNumber]||[callNumber isLandlineNumber]) {
        NSString *numString = [NSString stringWithFormat:@"+86%@",num.phone];
        num.phone =@([numString integerValue]);
    }
    
    if ([self checkExitCallNumber:num.phone]) {
        
        return YES;
    }
    num.indexID=[self selectIndexID:num.phone];
    return [[TDEntity sharedTDEntity]saveWithClass:[SCPhoneNumber class] model:num];
}

-(BOOL)unMarkCallNumber:(NSNumber *)callNumber
{
    return [[TDEntity sharedTDEntity]deleteWithClass:[SCPhoneNumber class] condition:@{@"phone":[callNumber description],@"tagStr":kMrakList}];
    
}

-(BOOL)markBlackCallNumber:(NSString *)callNumber withInfo:(NSString *)info
{
    SCPhoneNumber * num = [SCPhoneNumber new];
    num.phone =@([callNumber integerValue]);
    num.mark = info;
    num.tagStr =kBlackList;
    num.source = kMY;
    //区号，去除0，补86
    if ([callNumber isPhoneNumber]||[callNumber isLandlineNumber]) {
        NSString *numString = [NSString stringWithFormat:@"+86%@",num.phone];
        num.phone =@([numString integerValue]);
    }
    if ([self checkExitCallNumber:num.phone]) {
        
        return [[TDEntity sharedTDEntity]updateWithClass:[SCPhoneNumber class] value:@{@"mark":info,@"tagStr":kBlackList,@"source":kMY} condition:@{@"phone":num.phone}];
    }
    num.indexID=[self selectIndexID:num.phone];
    return [[TDEntity sharedTDEntity]saveWithClass:[SCPhoneNumber class] model:num];
    
}

-(BOOL)unMarkBlackCallNumber:(NSNumber *)callNumber{
    
    return [[TDEntity sharedTDEntity]deleteWithClass:[SCPhoneNumber class] condition:@{@"phone":[callNumber description],@"tagStr":kBlackList}];
}

-(long)selectIndexID:(NSNumber *)callNumber
{
    NSArray *nums= [[TDEntity sharedTDEntity]queryWithClass:[SCPhoneNumber class] condition:@{@"phone <=":[callNumber description]} sqlOrder:@"ORDER BY phone ASC"];
    if (nums.count<=0) {
        return 1;
    }
    SCPhoneNumber * num =nums.lastObject;
    return num.indexID;
}

-(BOOL)checkExitCallNumber:(NSNumber *)callNumber
{
    NSArray *nums= [[TDEntity sharedTDEntity]queryWithClass:[SCPhoneNumber class] condition:@{@"phone":[callNumber description]} sqlOrder:nil];
    if (nums.count<=0) {
        return NO;
    }
    return YES;
}

@end
