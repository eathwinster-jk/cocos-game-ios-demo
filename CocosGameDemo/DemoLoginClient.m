// iOS Demo 账号登录请求与响应解析。
#import "DemoLoginClient.h"

#import "DemoConfig.h"

@interface DemoLoginResult ()

@property(nonatomic, readwrite) int64_t liveUserId;
@property(nonatomic, readwrite) int64_t imUserId;
@property(nonatomic, copy, readwrite) NSString *token;

@end

@implementation DemoLoginResult
@end

@implementation DemoLoginClient

/**
 * 请求登录并在主线程返回结果。
 */
- (void)loginWithAccount:(NSString *)account
                password:(NSString *)password
              completion:(DemoLoginCompletion)completion {
    NSURLRequest *request = [self createRequestWithAccount:account password:password];
    NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithRequest:request
        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSInteger statusCode = [response isKindOfClass:NSHTTPURLResponse.class] ? ((NSHTTPURLResponse *)response).statusCode : 0;
        NSString *message = nil;
        DemoLoginResult *result = error ? nil : [self parseData:data statusCode:statusCode errorMessage:&message];
        if (error) {
            NSLog(@"Demo 账号登录网络异常，error=%@", error);
            message = @"登录网络异常，请稍后重试";
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(result, message);
        });
    }];
    [task resume];
}

/**
 * 创建账号登录请求。
 */
- (NSURLRequest *)createRequestWithAccount:(NSString *)account password:(NSString *)password {
    NSURLComponents *components = [NSURLComponents componentsWithString:DemoLoginAPIURL];
    components.queryItems = @[
        [NSURLQueryItem queryItemWithName:@"account" value:account],
        [NSURLQueryItem queryItemWithName:@"password" value:password],
        [NSURLQueryItem queryItemWithName:@"apptype" value:DemoLoginAppType],
        [NSURLQueryItem queryItemWithName:@"pid" value:DemoLoginPid],
        [NSURLQueryItem queryItemWithName:@"countryCode" value:DemoLoginCountryCode],
    ];
    components.percentEncodedQuery = [components.percentEncodedQuery stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:components.URL];
    request.timeoutInterval = DemoRequestTimeoutSeconds;
    [request setValue:DemoLoginPid forHTTPHeaderField:@"pid"];
    [request setValue:DemoLoginVersion forHTTPHeaderField:@"version"];
    [request setValue:DemoLoginUserAgent forHTTPHeaderField:@"User-Agent"];
    return request;
}

/**
 * 解析登录业务状态、UID、IM UID 和 Token。
 */
- (DemoLoginResult *)parseData:(NSData *)data statusCode:(NSInteger)statusCode errorMessage:(NSString **)errorMessage {
    NSDictionary *response = data.length > 0 ? [NSJSONSerialization JSONObjectWithData:data options:0 error:nil] : nil;
    if (![response isKindOfClass:NSDictionary.class]) {
        *errorMessage = @"登录服务未返回有效响应";
        return nil;
    }
    NSString *message = [response[@"msg"] description] ?: @"登录失败";
    if (statusCode < 200 || statusCode >= 300 || ![[response[@"code"] description] isEqualToString:@"0"]) {
        *errorMessage = message;
        return nil;
    }
    NSDictionary *userInfo = [response[@"userinfo"] isKindOfClass:NSDictionary.class] ? response[@"userinfo"] : @{};
    DemoLoginResult *result = [[DemoLoginResult alloc] init];
    result.liveUserId = [[response[@"uid"] description] longLongValue];
    result.imUserId = [[userInfo[@"imUserId"] description] longLongValue];
    result.token = [response[@"token"] description] ?: @"";
    if (result.liveUserId <= 0 || result.imUserId <= 0 || result.token.length == 0) {
        *errorMessage = @"登录响应缺少 UID、IM UID 或 Token";
        return nil;
    }
    return result;
}

@end
