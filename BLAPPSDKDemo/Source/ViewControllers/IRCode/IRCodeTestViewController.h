//
//  IRCodeTestViewController.h
//  BLAPPSDKDemo
//
//  Created by zjjllj on 2017/2/24.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "BaseViewController.h"
@interface SubAreaInfo : NSObject
@property(nonatomic, assign) NSInteger locateid;
@property(nonatomic, assign) NSInteger levelid;
@property(nonatomic, assign) NSInteger isleaf;
@property(nonatomic, assign) NSString *status;
@property(nonatomic, strong) NSString *name;
@end

@interface IRCodeTestViewController : BaseViewController

@end
