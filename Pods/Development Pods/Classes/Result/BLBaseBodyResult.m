//
//  BLBaseBodyResult.m
//  Let
//
//  Created by zjjllj on 2017/2/21.
//  Copyright © 2017年 BroadLink Co., Ltd. All rights reserved.
//

#import "BLBaseBodyResult.h"

@implementation BLBaseBodyResult

- (NSString *)responseBody {
    
    if (self.respbody != nil) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:self.respbody options:0 error:nil];
        _responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    
    return _responseBody;
}

@end
