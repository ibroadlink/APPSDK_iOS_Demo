//
//  FastconViewController.h
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2019/2/14.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FastconViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITextView *resultView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

NS_ASSUME_NONNULL_END
