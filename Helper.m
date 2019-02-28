//
//  Helper.m
//  Uchat
//
//  Created by 李鹏飞 on 2017/10/23.
//  Copyright © 2017年 AFlyLi. All rights reserved.
//

#import "Helper.h"


@implementation Helper


+ (void)getNetworkState{
    // 网络监控
    AFNetworkReachabilityManager *networkReachbilityManager = [AFNetworkReachabilityManager sharedManager];
    
    [networkReachbilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        switch (status) {
                
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未知网络");
                break;
                
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"断网");
                [MBProgressHUD SG_showMBProgressHUDWithOnlyMessage:@"网络请求失败,请检查您的网络设置" delayTime:2];
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"蜂窝数据");
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"WiFi网络");
            
                break;
                
            default:
                break;
        }
    }];
    // 开启监控
    [networkReachbilityManager startMonitoring];
}

+ (void)get:(NSString *)url parameters:(NSDictionary *)parameters success:(void (^)(id responseObject))success failure:(void (^)(NSError *))failure
{
     [self getNetworkState];
//    [SVProgressHUD show];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //设置请求数据类型
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    //设置返回数据类型
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/plain",@"text/html", nil];
    
//    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
//
//    NSString *headerString = [NSString stringWithFormat:@"Bearer %@",token];
//
//    [manager.requestSerializer setValue:headerString forHTTPHeaderField:@"Authorization"];
    
    [manager GET:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSString *code = [NSString stringWithFormat:@"%@",responseObject[@"success"]];
        if ([code isEqualToString:@"200"]) {
            if (success) {
                success(responseObject);
                NSLog(@"%@",responseObject);
            }
            [SVProgressHUD dismiss];
            
        }else{
            NSLog(@"%@",responseObject);
            [MBProgressHUD SG_showMBProgressHUDWithOnlyMessage:responseObject[@"message"] delayTime:3];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    
        if (failure) {
            failure(error);
            [SVProgressHUD dismiss];
            NSLog(@"failure:%@",error);
            
        }
    }];
}


+ (void)post:(NSString *)url parameters:(NSDictionary *)parameters success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    [self getNetworkState];
//    [SVProgressHUD show];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //设置请求数据类型
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    //设置返回数据类型
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/plain",@"text/html", nil];
    
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:@"tokenArr"];
    NSString *token = dic[@"token"];

    NSString *headerString = [NSString stringWithFormat:@"Bearer %@",token];

    [manager.requestSerializer setValue:headerString forHTTPHeaderField:@"Authorization"];
    
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    
        NSString *code = [NSString stringWithFormat:@"%@",responseObject[@"success"]];
        
        if ([code isEqualToString:@"200"]) {
            if (success) {
                success(responseObject);
                NSLog(@"%@",responseObject);
            }
//            [SVProgressHUD dismiss];
            
        }else if ([code isEqualToString:@"800"]){
            if (success) {
                success(responseObject);
                NSLog(@"800:::%@",responseObject);
            }
        }else if ([code isEqualToString:@"406"]){
            if (success) {
                success(responseObject);
                NSLog(@"406:::%@",responseObject);
            }
        }else{
            NSLog(@"%@",responseObject);
            [MBProgressHUD SG_showMBProgressHUDWithOnlyMessage:responseObject[@"message"] delayTime:3];
            
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
//            [SVProgressHUD dismiss];
            NSHTTPURLResponse *response = (NSHTTPURLResponse*)task.response;
            //通讯协议状态码
            NSInteger statusCode = response.statusCode;
            //服务器返回的业务逻辑报文信息
            NSString* errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
            NSLog(@"%ld----%@",(long)statusCode,errResponse);
            if (statusCode == 401) {
                
                [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"tokenArr"];
                [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"userInfo"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                [[NSNotificationCenter defaultCenter] removeObserver:self name:@"edit_success" object:nil];
                [[NSNotificationCenter defaultCenter] removeObserver:self name:@"recharge_success" object:nil];
                [[NSNotificationCenter defaultCenter] removeObserver:self name:@"addGoods_success" object:nil];
                [[NSNotificationCenter defaultCenter] removeObserver:self name:@"editGoods_success" object:nil];
                [[NSNotificationCenter defaultCenter] removeObserver:self name:@"alipay_settlement_success" object:nil];
                [[NSNotificationCenter defaultCenter] removeObserver:self name:@"wechat_settlement_success" object:nil];
                [[NSNotificationCenter defaultCenter] removeObserver:self name:@"check_order" object:nil];
                [[NSNotificationCenter defaultCenter] removeObserver:self name:@"pay_success" object:nil];
                
                UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UIViewController *loginVC = [story instantiateViewControllerWithIdentifier:@"loginNav"];
                [UIApplication sharedApplication].keyWindow.rootViewController = loginVC;
                [MBProgressHUD SG_showMBProgressHUDWithOnlyMessage:@"登录已过期,请重新登录" delayTime:3];
            }else if (statusCode == 500){
                [MBProgressHUD SG_showMBProgressHUDWithOnlyMessage:@"服务器错误" delayTime:3];
            }
            
        }
    }];
}
+ (void)showHud{
    [SVProgressHUD show];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD dismissWithDelay:2.0];
}
+ (void)showHudWithInfo:(NSString *)InfoStr{
    [SVProgressHUD showInfoWithStatus:InfoStr];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    
    [SVProgressHUD dismissWithDelay:2.0];
}
+ (void)showHudWithSuccessInfo:(NSString *)InfoStr{
    [SVProgressHUD showSuccessWithStatus:InfoStr];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD dismissWithDelay:2.0];
}
+ (void)showHudWithErrorInfo:(NSString *)InfoStr{
    [SVProgressHUD showErrorWithStatus:InfoStr];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD dismissWithDelay:2.0];
}
+ (void)showError:(NSString *)errorStr{
    [SVProgressHUD showInfoWithStatus:errorStr];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD dismissWithDelay:2.0];
}

//正则表达式判断电话号码邮箱
+ (BOOL)isValidateMobile:(NSString *)mobile
{
    NSString *phoneRegex = @"^(13[0-9]|14[579]|15[0-3,5-9]|16[6]|17[0135678]|18[0-9]|19[89])\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:mobile];
}

+ (BOOL)validateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

//解析json文件
+ (NSDictionary *)jiexiJson:(NSString *)jsonName
{
    NSString *path = [[NSBundle mainBundle] pathForResource:jsonName ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    return dic;
}


#pragma mark - 将某个时间转化成 时间戳
+(NSInteger)timeSwitchTimestamp:(NSString *)formatTime andFormatter:(NSString *)format{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:format]; //(@"YYYY-MM-dd hh:mm:ss") ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    
    [formatter setTimeZone:timeZone];
    
    NSDate* date = [formatter dateFromString:formatTime]; //------------将字符串按formatter转成nsdate
    
    //时间转时间戳的方法:
    
    NSInteger timeSp = [[NSNumber numberWithDouble:[date timeIntervalSince1970]] integerValue];

    NSLog(@"将某个时间转化成 时间戳 timeSp:%ld",(long)timeSp); //时间戳的值
    
    return timeSp;
    
}

//将某个时间戳转化成 时间

#pragma mark - 将某个时间戳转化成 时间

+(NSString *)timestampSwitchTime:(NSInteger)timestamp andFormatter:(NSString *)format{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:format]; // （@"YYYY-MM-dd hh:mm:ss"）----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    
    [formatter setTimeZone:timeZone];
    
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:timestamp];
    
    NSLog(@"timestampSwitchTime :date  = %@",confromTimesp);
    
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    
    return confromTimespStr;
    
}

//去掉json中的空格和换行
+ (NSString *)jsonStringWithArray:(NSMutableArray *)array {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString;
    if (!jsonData) {
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr;
}

+ (NSString *)jsonStringWithDic:(NSDictionary *)dict{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString;
    if (!jsonData) {
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr;
}

//jsonstr转化为dic
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

//jsonstr转化为array
+ (NSArray *)arrayWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSArray *arr = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return arr;
}


/**
 判断是否为空字符串
 
 @param string 需要判断的字符串
 @return 结果
 */
+ (BOOL)isBlankString:(NSString *)string{
    
    if (string == nil || string == NULL) {
        NSLog(@"--nil NULL--");
        return YES;
    }
    
    if ([string isKindOfClass:[NSNull class]]) {
        NSLog(@"--[NSNull class]--");
        return YES;
    }
    
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) {
        NSLog(@"--length--");
        return YES;
    }
    
    return NO;
}
//数组按某个 key 重新分组
+ (NSArray*)reGroupArray:(NSArray*)array withFieldName:(NSString*)fieldName {
    NSMutableDictionary *groupDict = [NSMutableDictionary dictionary];
    for (id aData in array) {
        NSString *theKey = [aData valueForKey:fieldName];
        NSMutableArray *theArr = groupDict[theKey];
        if (!theArr) {
            theArr = [NSMutableArray array];
            groupDict[theKey] = theArr;
        }
        [theArr addObject:aData];
    }
    return [groupDict allValues];
}
@end

@implementation NSString (HightLight)

+ (NSMutableAttributedString *)setHighLightText:(NSString *)str andSeparateStr:(NSString *)separateStr andLength:(NSInteger)length andColor:(UIColor *)color
{
    
    
    NSMutableAttributedString *noteStr = [[NSMutableAttributedString alloc] initWithString:str];
    
    NSRange highLightColorRange = NSMakeRange([[noteStr string] rangeOfString:separateStr].location + 1,length);
    
    [noteStr addAttribute:NSForegroundColorAttributeName value:color range:highLightColorRange];
    
    return noteStr;
}


+ (NSMutableAttributedString *)setHighLightText:(NSString *)str FromWhere:(NSInteger)fromWhere andLength:(NSInteger)length andColor:(UIColor *)color
{
    
    NSMutableAttributedString *noteStr = [[NSMutableAttributedString alloc] initWithString:str];
    
    NSRange highLightColorRange = NSMakeRange(fromWhere,length);
    
    [noteStr addAttribute:NSForegroundColorAttributeName value:color range:highLightColorRange];
    
    return noteStr;
}
+ (NSMutableAttributedString *)setHighLightText:(NSString *)str FromWhere:(NSInteger)fromWhere andLength:(NSInteger)length andColor:(UIColor *)color andFont:(UIFont *)font
{
    NSMutableAttributedString *noteStr = [[NSMutableAttributedString alloc] initWithString:str];
    
    NSRange highLightColorRange = NSMakeRange(fromWhere,length);
    
    [noteStr addAttribute:NSForegroundColorAttributeName value:color range:highLightColorRange];
    [noteStr addAttribute:NSFontAttributeName value:font range:highLightColorRange];
    return noteStr;
}

- (BOOL)isChinese
{
    NSString *match = @"(^[\u4e00-\u9fa5]+$)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:self];
}


@end
