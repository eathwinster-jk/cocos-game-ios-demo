// iOS Demo 账号密码登录客户端，负责换取业务 UID、IM UID 与 Token。
#pragma once

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DemoLoginResult : NSObject

@property(nonatomic, readonly) int64_t liveUserId;
@property(nonatomic, readonly) int64_t imUserId;
@property(nonatomic, copy, readonly) NSString *token;

@end

typedef void (^DemoLoginCompletion)(DemoLoginResult *_Nullable result, NSString *_Nullable errorMessage);

@interface DemoLoginClient : NSObject

/**
 * 请求登录，completion 在主线程回调。
 */
- (void)loginWithAccount:(NSString *)account
                password:(NSString *)password
              completion:(DemoLoginCompletion)completion;

@end

NS_ASSUME_NONNULL_END
