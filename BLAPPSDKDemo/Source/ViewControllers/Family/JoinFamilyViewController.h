//
//  JoinFamilyViewController.h
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2018/7/19.
//  Copyright © 2018 BroadLink. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface JoinFamilyViewController : BaseViewController

@property (nonatomic, copy)NSString *qCode;
@property (weak, nonatomic) IBOutlet UITextField *familyCodeField;
- (IBAction)joinBtn:(id)sender;

@end

NS_ASSUME_NONNULL_END
