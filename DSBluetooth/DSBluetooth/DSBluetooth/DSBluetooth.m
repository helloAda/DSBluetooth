//
//  DSBluetooth.m
//  DSBluetooth
//
//  Created by 黄铭达 on 2017/9/27.
//  Copyright © 2017年 黄铭达. All rights reserved.
//

#import "DSBluetooth.h"

NSNotificationName const DSBluetoothNotificationCentralManagerDidUpdateState = @"DSBluetoothNotificationCentralManagerDidUpdateState";

@interface DSBluetooth ()<CBCentralManagerDelegate,CBPeripheralDelegate>
{
    BOOL _convenientConnect;        // 便利连接 连接后直接获取Characteristic
    NSInteger numOfServices;        // 服务的数量，用来判断特征是否全部加载完成
    
    NSMutableArray *discoverPeripherals;   //发现的设备 -- 这里如果没有强引用peripheral会被释放
}

//主设备 (该项目为手机)
@property (nonatomic, strong) CBCentralManager *centralManager;
//外设
@property (nonatomic, strong) CBPeripheral *peripheral;
//外设的特征值
@property (nonatomic, strong) NSMutableArray *characteristics;
//标记 用来标记该使用哪个DSCallback实例去回调block
@property (nonatomic, strong) NSMutableDictionary *identifiers;
// 当前的标记
@property (nonatomic, copy)   NSString *currentIdentifier;

@end

@implementation DSBluetooth

+ (instancetype)bluetooth {
    static DSBluetooth *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DSBluetooth alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _centralManager    = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        _characteristics   = [[NSMutableArray alloc] init];
        _convenientConnect = NO;

        //构建默认标记的回调对象
        _identifiers       = [[NSMutableDictionary alloc] init];
        _currentIdentifier = kDEFAULT_IDENTIFIER;
        DSCallback *defaultCallback  = [[DSCallback alloc] init];
        [_identifiers setObject:defaultCallback forKey:_currentIdentifier];
        
        discoverPeripherals = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark -----  对外接口  -----

- (void)startScan {
    NSArray *services = [self currentCallback].config.scanForPeripheralsServices;
    NSDictionary *options = [self currentCallback].config.scanForPeripheralsOptions;
    [self.centralManager scanForPeripheralsWithServices:services options:options];
}

- (void)stopScan {
    [self.centralManager stopScan];
}

- (void)connectPeripheral:(CBPeripheral *)peripheral {
    NSDictionary *options = [self currentCallback].config.connectPeripheralOptions;
    [self.centralManager connectPeripheral:peripheral options:options];
}

- (void)cancelPeripheralConnect {
    if (self.peripheral) {
        [self.centralManager cancelPeripheralConnection:self.peripheral];
    }
}

- (void)writeData:(NSData *)data characteristic:(CBCharacteristic *)characteristic WithResponse:(BOOL)yesOrNo {
    if (!self.peripheral) return;
    if (yesOrNo) {
        [self.peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
    } else {
        [self.peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
    }
}

- (void)readCharacteristic:(CBCharacteristic *)Characteristic {
    if (self.peripheral) {
        [self.peripheral readValueForCharacteristic:Characteristic];
    }
}

- (void)listenForNotification:(BOOL)isNotify characteristic:(CBCharacteristic *)characteristic {
    if (self.peripheral) {
        [self.peripheral setNotifyValue:isNotify forCharacteristic:characteristic];
    }
}

- (CBCharacteristic *)findCharacteristicFormUUIDString:(NSString *)UUIDString {
    for (CBCharacteristic *c in self.characteristics) {
        if ([c.UUID.UUIDString isEqualToString:UUIDString]) {
            return c;
        }
    }
    return nil;
}

- (BOOL)bluetoothIsPoweredOn {
    if (self.centralManager.state == CBCentralManagerStatePoweredOn) {
        return YES;
    }
    return NO;
}

#pragma mark   --- CBCentralManagerDelegate 主设备相关代理

//蓝牙状态改变时
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    NSNotification *notification = [NSNotification notificationWithName:DSBluetoothNotificationCentralManagerDidUpdateState object:@{@"central" : central}];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    
    if ([self currentCallback].centralManagerStateChange) {
        [self currentCallback].centralManagerStateChange(central);
    }
}

/**
 发现外设回调

 @param central 蓝牙管理对象
 @param peripheral 外设
 @param advertisementData 外设携带信息
 @param RSSI 外设信号强度
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    
    if (![discoverPeripherals containsObject:peripheral]) {
        [discoverPeripherals addObject:peripheral];
    }
    //扫描发现设备callback
    if ([[self currentCallback] filterDiscoverPeripherals]) {
        if([[self currentCallback] filterDiscoverPeripherals](peripheral, advertisementData, RSSI)) {
            if ([self currentCallback].discoverPeripheralBlock) {
                [self currentCallback].discoverPeripheralBlock(central,peripheral,advertisementData,RSSI);
            }
        }
    }
    
    //便利连接处理
    if ([[self currentCallback] filterConnectPeripherals]) {
        if([[self currentCallback] filterConnectPeripherals](peripheral, advertisementData, RSSI)) {
            [self connectPeripheral:peripheral];
        }
    }
    

}

//设备连接成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
    [self stopScan];
    self.peripheral = peripheral;
    self.peripheral.delegate = self;
    
    if ([self currentCallback].connectPeripheralBlock) {
        [self currentCallback].connectPeripheralBlock(central, peripheral);
    }
    if (_convenientConnect) {
        //寻找服务
        NSArray *services = [self currentCallback].config.discoverServices;
        [self.peripheral discoverServices:services];
    }
}

//设备连接失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if ([self currentCallback].failConnectPeripheralBlock) {
        [self currentCallback].failConnectPeripheralBlock(central, peripheral, error);
    }
    if (_convenientConnect && [self callback].convenientConnectFail) {
        [self currentCallback].convenientConnectFail();
    }
}

//断开链接时(主动断开||其他因素断开)
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if ([self currentCallback].disconnectPeripheralBlock) {
        [self currentCallback].disconnectPeripheralBlock(central, peripheral, error);
    }
}


///////////////////////////////////////////////////////////////////////


#pragma mark --- CBPeripheralDelegate 外设相关代理

//发现外设的服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error {
    if ([self currentCallback].peripheralDiscoverServices) {
        [self currentCallback].peripheralDiscoverServices(peripheral, error);
    }
    if (_convenientConnect) {
        numOfServices = peripheral.services.count;
        for (CBService *service in peripheral.services) {
            //寻找该服务下特征
            NSArray *characteristics = [self currentCallback].config.discoverCharacteristics;
            [self.peripheral discoverCharacteristics:characteristics forService:service];
        }
    }
}

//发现外设的特征
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if ([self currentCallback].servicesDiscoverCharacteristics) {
        [self currentCallback].servicesDiscoverCharacteristics(peripheral, service, error);
    }
    if (_convenientConnect) {
        numOfServices--;
        //将搜索到的特征加入特征数组，提供给后续使用
        for (CBCharacteristic *characteristic in service.characteristics) {
            [self.characteristics addObject:characteristic];
        }
        //每个服务下的特征都加载完毕了
        if (numOfServices == 0 && [self currentCallback].convenientConnectSuccess) {
            [self currentCallback].convenientConnectSuccess();
        }
    }
}

//写入数据到特征时回调
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if ([self currentCallback].writeValueForCharacteristic) {
        [self currentCallback].writeValueForCharacteristic(peripheral, characteristic, error);
    }
}

//外设特征数据改变时会回调这个方法（蓝牙传过来的数据都会走这里）
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if ([self currentCallback].updateValueForCharacteristic) {
        [self currentCallback].updateValueForCharacteristic(peripheral, characteristic, error);
    }
}


#pragma mark --- 回调方法 只在单一界面处理 就可以使用这个---

//便利连接
- (void)convenientConnectFilterRules:(DSFilterConnectPeripherals)filterRules success:(DSConvenientConnectSuccess)success fail:(DSConvenientConnectFail)fail {
    [self callback].filterConnectPeripherals = filterRules;
    [self callback].convenientConnectSuccess = success;
    [self callback].convenientConnectFail = fail;
    _convenientConnect = YES;
}

//蓝牙扫描，连接时的配置参数 详见DSBluetoothConfig
- (void)config:(DSBluetoothConfig *)config {
    [self callback].config = config;
}
//蓝牙状态改变
- (void)centralManagerStateChange:(DSCentralManagerStateChange)block {
    [self callback].centralManagerStateChange = block;
}

//搜索到外设
- (void)discoverPeripheralBlock:(DSDiscoverPeripheralBlock)block {
    [self callback].discoverPeripheralBlock = block;
}

//外设连接成功
- (void)connectPeripheralBlock:(DSConnectPeripheralBlock)block {
    [self callback].connectPeripheralBlock = block;
}

//外设连接失败
- (void)failConnectPeripheralBlock:(DSFailConnectPeripheralBlock)block {
    [self callback].failConnectPeripheralBlock = block;
}

//外设连接断开
- (void)disconnectPeripheralBlock:(DSDisconnectPeripheralBlock)block {
    [self callback].disconnectPeripheralBlock = block;
}

//发现外设服务
- (void)peripheralDiscoverServices:(DSPeripheralDiscoverServices)block {
    [self callback].peripheralDiscoverServices = block;
}

//发现外设特征
- (void)servicesDiscoverCharacteristics:(DSServicesDiscoverCharacteristics)block {
    [self callback].servicesDiscoverCharacteristics = block;
}

//写入数据到特征
- (void)writeValueForCharacteristic:(DSWriteValueForCharacteristic)block {
    [self callback].writeValueForCharacteristic = block;
}

//接收到特征数据
- (void)updateValueForCharacteristic:(DSUpdateValueForCharacteristic)block {
    [self callback].updateValueForCharacteristic = block;
}

//筛选发现到的peripherals规则
- (void)filterOnDiscoverPeripherals:(DSFilterDiscoverPeripherals)block {
    [self callback].filterDiscoverPeripherals = block;
}

#pragma mark --- 带标记的回调方法  适用于在不同界面使用 ---

//便利连接
- (void)convenientConnectWithIdentifier:(NSString *)identifier filterRules:(DSFilterConnectPeripherals)filterRules success:(DSConvenientConnectSuccess)success fail:(DSConvenientConnectFail)fail {
    [self callbackWithIdentifier:identifier].filterConnectPeripherals = filterRules;
    [self callbackWithIdentifier:identifier].convenientConnectSuccess = success;
    [self callbackWithIdentifier:identifier].convenientConnectFail = fail;
    _convenientConnect = YES;
}

//蓝牙扫描，连接时的配置参数
- (void)configWithIdentifier:(NSString *)identifier config:(DSBluetoothConfig *)config {
    [self callbackWithIdentifier:identifier].config = config;
}

//蓝牙状态改变
- (void)centralManagerStateChangeWithIdentifier:(NSString *)identifier block:(DSCentralManagerStateChange)block {
    [self callbackWithIdentifier:identifier].centralManagerStateChange = block;
}

//搜索外设，搜索到外设回调
- (void)discoverPeripheralWithIdentifier:(NSString *)identifier block:(DSDiscoverPeripheralBlock)block {
    [self callbackWithIdentifier:identifier].discoverPeripheralBlock = block;
}

//外设连接成功
- (void)connectPeripheralWithIdentifier:(NSString *)identifier block:(DSConnectPeripheralBlock)block {
    [self callbackWithIdentifier:identifier].connectPeripheralBlock = block;
}

//外设连接失败
- (void)failConnectPeripheralWithIdentifier:(NSString *)identifier block:(DSFailConnectPeripheralBlock)block {
    [self callbackWithIdentifier:identifier].failConnectPeripheralBlock = block;
}

//外设连接断开
- (void)disconnectPeripheralWithIdentifier:(NSString *)identifier block:(DSDisconnectPeripheralBlock)block {
    [self callbackWithIdentifier:identifier].disconnectPeripheralBlock = block;
}

//发现外设服务
- (void)peripheralDiscoverServicesWithIdentifier:(NSString *)identifier block:(DSPeripheralDiscoverServices)block {
    [self callbackWithIdentifier:identifier].peripheralDiscoverServices = block;
}

//发现外设特征
- (void)servicesDiscoverCharacteristicsWithIdentifier:(NSString *)identifier block:(DSServicesDiscoverCharacteristics)block {
    [self callbackWithIdentifier:identifier].servicesDiscoverCharacteristics = block;
}

//写入数据到特征
- (void)writeValueForCharacteristicWithIdentifier:(NSString *)identifier block:(DSWriteValueForCharacteristic)block {
    [self callbackWithIdentifier:identifier].writeValueForCharacteristic = block;
}

//接收到特征数据
- (void)updateValueForCharacteristicWithIdentifier:(NSString *)identifier block:(DSUpdateValueForCharacteristic)block {
    [self callbackWithIdentifier:identifier].updateValueForCharacteristic = block;
}

//筛选发现到的peripherals规则
- (void)filterOnDiscoverPeripheralsWithIdentifier:(NSString *)idebtifier block:(DSFilterDiscoverPeripherals)block {
    [self callbackWithIdentifier:idebtifier].filterDiscoverPeripherals = block;
}

#pragma mark -- 标记切换 查找回调block --

- (void)switchIdentifier:(NSString *)identifier {
    if (identifier) {
        if ([_identifiers objectForKey:identifier]) {
            //切换成功
            _currentIdentifier = identifier;
        } else {
            //没有对应的标记
        }
    } else {
        //传nil则切换到默认标记
        _currentIdentifier = kDEFAULT_IDENTIFIER;
    }
}

//默认标记对应的callback
- (DSCallback *)callback {
    DSCallback *callback = [_identifiers objectForKey:kDEFAULT_IDENTIFIER];
    return callback;
}

//找到当前标记对应的callback
- (DSCallback *)currentCallback {
    DSCallback *callback = [_identifiers objectForKey:_currentIdentifier];
    return callback;
}

//找到标记对应的callback 没有则新增
- (DSCallback *)callbackWithIdentifier:(NSString *)identifier {
    DSCallback *callback = [_identifiers objectForKey:identifier];
    if (!callback) {
        callback = [[DSCallback alloc] init];
        [_identifiers setObject:callback forKey:identifier];
    }
    return callback;
}

@end
