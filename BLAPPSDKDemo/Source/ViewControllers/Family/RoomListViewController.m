//
//  RoomListViewController.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/2/21.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "RoomListViewController.h"
#import "BLNewFamilyManager.h"

#import "BLStatusBar.h"

@interface RoomListViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *roomListTable;
- (IBAction)barButtonClick:(UIBarButtonItem *)sender;

@property (nonatomic, copy)NSArray *roomList;

@end

@implementation RoomListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.roomList = [[NSArray alloc] init];
    self.roomListTable.delegate = self;
    self.roomListTable.dataSource = self;
    [self setExtraCellLineHidden:self.roomListTable];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getFamilyRooms];
}

- (IBAction)barButtonClick:(UIBarButtonItem *)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Add Family Room" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"";
        textField.placeholder = @"Please input new room name";
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        BLSRoomInfo *info = [[BLSRoomInfo alloc] init];
        
        info.name = alertController.textFields.firstObject.text;
        info.action = @"add";
        info.order = self.roomList.count + 1;
        
        [self manageRoom:info];
        
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)getFamilyRooms {
    
    BLNewFamilyManager *manager = [BLNewFamilyManager sharedFamily];
    [self showIndicatorOnWindow];
    
    [manager getFamilyRoomsWithCompletionHandler:^(BLSManageRoomResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
            
            if ([result succeed]) {
                self.roomList = result.roomInfos;
                [self.roomListTable reloadData];
            } else {
                [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Get Rooms Failed. Code:%ld MSG:%@", result.status, result.msg]];
            }
        });
    }];
}

- (void)manageRoom:(BLSRoomInfo *)info {
    
    NSArray *infos = @[info];
    BLNewFamilyManager *manager = [BLNewFamilyManager sharedFamily];
    [self showIndicatorOnWindow];
    
    [manager manageRooms:infos completionHandler:^(BLSManageRoomResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
            
            if ([result succeed]) {
                [self getFamilyRooms];
            } else {
                [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Manage Room Failed. Code:%ld MSG:%@", result.status, result.msg]];
            }
            
        });
    }];
}

#pragma mark - delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.roomList.count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"MEMBER_CELL";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    BLSRoomInfo *info = self.roomList[indexPath.row];
    
    cell.textLabel.text = info.name;
    cell.detailTextLabel.text = info.roomid;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        BLSRoomInfo *info = self.roomList[indexPath.row];
        info.action = @"del";
        [self manageRoom:info];
    }
}

@end
