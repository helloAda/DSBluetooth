//
//  ConnectViewController.m
//  DSBluetooth
//
//  Created by HelloAda on 2018/5/7.
//  Copyright © 2018年 HelloAda. All rights reserved.
//

#import "ConnectViewController.h"
#import "DSBluetooth.h"
#import "UIView+Toast.h"

#define ConnectVCIdentifier @"ConnectVCIdentifier"
@interface ConnectViewController ()<UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *array;
@end

@implementation ConnectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"deviceIdentifier"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请先绑定设备" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
    } else {
        [self setupUI];
        [self setupBluetooth];
    }
}


- (void)setupBluetooth {
    __weak typeof(self) wself = self;
    DSBluetooth *bluetooth = [DSBluetooth bluetooth];
    
    /*
     便利连接 如果有绑定了就直接使用这个比较方便，否则就需要在discoverPeripheralWithIdentifier:block:里面自己调用连接的方法。这里就简单演示一下。
     */
    [bluetooth convenientConnectWithIdentifier:ConnectVCIdentifier filterRules:^BOOL(CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"deviceIdentifier"] isEqualToString:peripheral.identifier.UUIDString]) {
            return YES;
        }
        return NO;
    } success:^{
        [wself.view hideToastActivity];
        [wself.view makeToast:@"连接成功" duration:2 position:CSToastPositionCenter];
        [wself.tableView reloadData];

    } fail:^{
        [wself.view hideToastActivity];
        [wself.view makeToast:@"连接失败" duration:2 position:CSToastPositionCenter];
    }];
    
    [bluetooth servicesDiscoverCharacteristicsWithIdentifier:ConnectVCIdentifier block:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        //一般连接上之后，不会使用这个回调 ，可以通过findCharacteristicFormUUIDString这个方法获取到需要的特征，这里只是为了显示。
        NSString *serviceUUID = service.UUID.UUIDString;
        NSDictionary *dic = @{serviceUUID : service.characteristics};
        [wself.array addObject:dic];
    }];
    
    //如果有需要配置则要先初始化，然后在开始扫描
    //    DSBluetoothConfig *config = [DSBluetoothConfig alloc] initWithScanForPeripheralsServices:<#(NSArray *)#> discoverServices:<#(NSArray *)#> discoverCharacteristics:<#(NSArray *)#>
    //    [bluetooth configWithIdentifier:ConnectVCIdentifier config:config];
    
    //切换到该标示下的Block
    [bluetooth switchIdentifier:ConnectVCIdentifier];
    [bluetooth startScan];
    [self.view makeToastActivity:CSToastPositionCenter];
    NSLog(@"标记%@ ，开始扫描", ConnectVCIdentifier);
}


- (void)setupUI {
    _array = [[NSMutableArray alloc] init];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
}



#pragma mark --- tableVeiw


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.array.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.array[section] allValues].firstObject count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CBCharacteristic *characteristic = [self.array[indexPath.section] allValues].firstObject[indexPath.row];
    NSString *cellIdentifier = @"characteristicCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@",characteristic.UUID];
    cell.detailTextLabel.text = characteristic.description;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.array[section] allKeys].firstObject;
}

#pragma mark -- UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
