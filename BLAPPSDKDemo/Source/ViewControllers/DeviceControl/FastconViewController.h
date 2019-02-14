//
//  FastconViewController.h
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2019/2/14.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class BLDNADevice;

@interface FastconViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) BLDNADevice *device;

@property (weak, nonatomic) IBOutlet UITextView *resultView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

NS_ASSUME_NONNULL_END
