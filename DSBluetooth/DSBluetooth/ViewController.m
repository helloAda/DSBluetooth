//
//  ViewController.m
//  DSBluetooth
//
//  Created by HelloAda on 2018/4/9.
//  Copyright © 2018年 HelloAda. All rights reserved.
//

#import "ViewController.h"
#import "DSSettingDataSource.h"
#import "BindViewController.h"
#import "ConnectViewController.h"
#import "DSBluetooth.h"
#import "UIView+Toast.h"

@interface ViewController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) DSSettingDataSource *dataSource;
@property (nonatomic, strong) NSMutableArray *array;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}


- (void)setupUI {
    self.title = @"DSBluetoothDemo";
    self.view.backgroundColor = [UIColor whiteColor];
    _array = [[NSMutableArray alloc] init];
    
    {
        DSSettingItem *item = [DSSettingItem itemWithTitle:@"绑定设备" icon:@"绑定" type:DSSettingItemTypeArrow];
        item.didSelectBlock = ^{
            if ([DSBluetooth bluetooth].bluetoothIsPoweredOn) {
                BindViewController *vc = [[BindViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                [self.view makeToast:@"蓝牙未打开" duration:2 position:CSToastPositionCenter];
            }
        };
        [_array addObject:item];
    }
    {
        DSSettingItem *item = [DSSettingItem itemWithTitle:@"连接设备" icon:@"连接" type:DSSettingItemTypeArrow];
        item.didSelectBlock = ^{
            if ([DSBluetooth bluetooth].bluetoothIsPoweredOn) {
                ConnectViewController *vc = [[ConnectViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                [self.view makeToast:@"蓝牙未打开" duration:2 position:CSToastPositionCenter];
            }

        };
        [_array addObject:item];
        
    }
    _dataSource = [[DSSettingDataSource alloc] initWithItems:_array];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = _dataSource;
    self.tableView.delegate = _dataSource;
    [self.view addSubview:self.tableView];
}
@end
