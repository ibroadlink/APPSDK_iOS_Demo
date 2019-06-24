/*!
  @header BLTokenBurst.m

  @author Created by zjjllj on 2017/3/27.

  @version 1.00 2017/3/27Creation

  Copyright © 2017年 BroadLink Co., Ltd. All rights reserved.
*/

#import "BLTokenBurst.h"
#import "BLCommonTools.h"

#define TOKEN_GRANULARITY (100)

@interface BLTokenBurst ()

@property (nonatomic, assign) NSUInteger quota;
@property (nonatomic, assign) NSUInteger interval;

@property (nonatomic, assign) NSInteger step;
@property (nonatomic, assign) NSInteger burst;

@property (nonatomic, strong) NSMutableDictionary *apiTokens;

@end

@implementation BLTokenBurst

+ (instancetype)sharedBurst {
    static dispatch_once_t onceToken;
    static BLTokenBurst *blTokenBurst = nil;
    dispatch_once(&onceToken, ^{
        blTokenBurst = [[BLTokenBurst alloc] init];
    });
    
    return blTokenBurst;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _quota = 100;
        _interval = 180;
        _burst = _quota * TOKEN_GRANULARITY;
        _step = _quota * TOKEN_GRANULARITY / _interval;
        
        _apiTokens = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    
    return self;
}

- (void)saveTokensWithUrl:(NSString *)host tokens:(NSInteger)tokens quertTime:(double)lastquery {
    NSDictionary *apiToken = @{
                               @"tokens":[NSNumber numberWithInteger:tokens],
                               @"lastquery":[NSNumber numberWithDouble:lastquery]
                               };
    @synchronized (self.apiTokens){
        if (![BLCommonTools isEmpty:host]) {
            [self.apiTokens setValue:apiToken forKey:host];
        }
    }
}

- (BOOL)queryTokenBurstWithUrl:(NSString *)url {
    
    double now = [[NSDate date] timeIntervalSince1970] * 1000;  //毫秒级
    
    NSInteger tokens;
    NSInteger token;
    double lastquery;
    
    NSString *host;
    NSRange range = [url rangeOfString:@"?"];
    if (range.location == NSNotFound) {
        host = url;
    } else {
        host = [url substringFromIndex:(range.location - 1)];
    }
    if ([BLCommonTools isEmpty:host]) {
        return NO;
    }
    NSDictionary *apiToken = [self.apiTokens objectForKey:host];
    if (apiToken) {
        tokens = [[apiToken objectForKey:@"tokens"] integerValue];
        lastquery = [[apiToken objectForKey:@"lastquery"] doubleValue];
    } else {
        lastquery = now;
        tokens = self.burst;
    }
    double diff = now - lastquery;
    token = diff * self.step / TOKEN_GRANULARITY;
    
    lastquery = now;
    tokens += token;
    if (tokens > self.burst) {
        tokens = self.burst;
    }
    
    if (tokens >= TOKEN_GRANULARITY) {
        tokens -= TOKEN_GRANULARITY;
        
        [self saveTokensWithUrl:host tokens:tokens quertTime:lastquery];
        return YES;
    }
    
    [self saveTokensWithUrl:host tokens:tokens quertTime:lastquery];
    return NO;
}


@end
