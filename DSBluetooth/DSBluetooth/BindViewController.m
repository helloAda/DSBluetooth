//
//  BindViewController.m
//  DSBluetooth
//
//  Created by HelloAda on 2018/5/7.
//  Copyright © 2018年 HelloAda. All rights reserved.
//

#import "BindViewController.h"
#import "DSBluetooth.h"
#import "UIView+Toast.h"
#define BindVCIdentifier @"BindVcIdentifier"

@interface BindViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, assign) NSInteger tag;
@end

@implementation BindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _array = [[NSMutableArray alloc] init];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    [self setupBluetooth];
}

- (void)setupBluetooth {
    __weak typeof(self) wself = self;
    DSBluetooth *bluetooth = [DSBluetooth bluetooth];

    [bluetooth discoverPeripheralWithIdentifier:BindVCIdentifier block:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        if (peripheral.name) {
            wself.tag = 0;
            for (NSDictionary *dic in self.array) {
                if ([dic objectForKey:@"device"] == peripheral) {
                    wself.tag = 1;
                    NSInteger i = [self.array indexOfObject:dic];
                    [wself.array replaceObjectAtIndex:i withObject:@{@"rssi" : RSSI ,@"device": peripheral}];
                    break;
                }
            }
            if (!(wself.tag)) {
                [wself.array addObject:@{@"rssi" : RSSI ,@"device": peripheral}];
            }
            [wself.tableView reloadData];
        }
    }];
    
    //如果有需要配置则要先初始化，然后在开始扫描
//    DSBluetoothConfig *config = [DSBluetoothConfig alloc] initWithScanForPeripheralsServices:<#(NSArray *)#> discoverServices:<#(NSArray *)#> discoverCharacteristics:<#(NSArray *)#>
//    [bluetooth configWithIdentifier:BindVCIdentifier config:config];
    
    //切换到该标示下的Block
    [bluetooth switchIdentifier:BindVCIdentifier];
    [bluetooth startScan];
    NSLog(@"标记%@ ，开始扫描", BindVCIdentifier);
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dic = self.array[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    
    NSString *deviceName = [(CBPeripheral *)[dic objectForKey:@"device"] name];
    NSInteger rssi = [[dic objectForKey:@"rssi"] integerValue];
    cell.textLabel.text = [NSString stringWithFormat:@"%@,信号：%ld",deviceName,(long)rssi];
    cell.detailTextLabel.text = [(CBPeripheral *)[dic objectForKey:@"device"] description];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CBPeripheral *peripheral = [self.array[indexPath.row] objectForKey:@"device"];
    [[NSUserDefaults standardUserDefaults] setObject:peripheral.identifier.UUIDString forKey:@"deviceIdentifier"];
    [[DSBluetooth bluetooth] stopScan];
    [self.view makeToast:@"绑定成功" duration:2 position:CSToastPositionCenter];
}
@end
