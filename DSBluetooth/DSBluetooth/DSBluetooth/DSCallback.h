//
//  DSCallback.h
//  
//
//  Created by HelloAda on 2018/4/2.
//  Copyright © 2018年 黄铭达. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "DSBluetoothConfig.h"

//蓝牙状态改变
typedef void(^DSCentralManagerStateChange)(CBCentralManager *central);
//扫描到外设
typedef void(^DSDiscoverPeripheralBlock)(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI);
//外设连接成功
typedef void(^DSConnectPeripheralBlock)(CBCentralManager *central, CBPeripheral *peripheral);
//外设连接失败
typedef void(^DSFailConnectPeripheralBlock)(CBCentralManager *central, CBPeripheral *peripheral, NSError *error);
//外设连接断开
typedef void(^DSDisconnectPeripheralBlock)(CBCentralManager *central, CBPeripheral *peripheral, NSError *error);
//发现外设服务
typedef void(^DSPeripheralDiscoverServices)(CBPeripheral *peripheral, NSError *error);
//发现外设特征
typedef void(^DSServicesDiscoverCharacteristics)(CBPeripheral *peripheral, CBService *service, NSError *error);
//写入数据在特征时回调(有response才有)
typedef void(^DSWriteValueForCharacteristic)(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error);
//收到特征传来的数据（基本可以说这是唯一拿数据的回调）
typedef void(^DSUpdateValueForCharacteristic)(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error);
//筛选发现到的peripherals规则
typedef BOOL(^DSFilterDiscoverPeripherals)(CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI);
//筛选需要连接的peripherals规则
typedef BOOL(^DSFilterConnectPeripherals)(CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI);

//便利连接回调
typedef void(^DSConvenientConnectSuccess)(void);
typedef void(^DSConvenientConnectFail)(void);

////////////////////////////////////////////////////

@interface DSCallback : NSObject

//蓝牙扫描，连接的参数配置
@property (nonatomic, strong) DSBluetoothConfig *config;

//// 这些都是为了持有block然后去回调中执行  /////

@property (nonatomic, copy) DSCentralManagerStateChange centralManagerStateChange;
@property (nonatomic, copy) DSDiscoverPeripheralBlock discoverPeripheralBlock;
@property (nonatomic, copy) DSConnectPeripheralBlock connectPeripheralBlock;
@property (nonatomic, copy) DSFailConnectPeripheralBlock failConnectPeripheralBlock;
@property (nonatomic, copy) DSDisconnectPeripheralBlock disconnectPeripheralBlock;
@property (nonatomic, copy) DSPeripheralDiscoverServices peripheralDiscoverServices;
@property (nonatomic, copy) DSServicesDiscoverCharacteristics servicesDiscoverCharacteristics;
@property (nonatomic, copy) DSWriteValueForCharacteristic writeValueForCharacteristic;
@property (nonatomic, copy) DSUpdateValueForCharacteristic updateValueForCharacteristic;
@property (nonatomic, copy) DSConvenientConnectSuccess convenientConnectSuccess;
@property (nonatomic, copy) DSConvenientConnectFail convenientConnectFail;
@property (nonatomic, copy) DSFilterDiscoverPeripherals filterDiscoverPeripherals;
@property (nonatomic, copy) DSFilterConnectPeripherals filterConnectPeripherals;
//// 这些都是为了持有block然后去回调中执行  /////
@end
