//
//  DSBluetooth.h
//  DSBluetooth
//
//  Created by 黄铭达 on 2017/9/27.
//  Copyright © 2017年 黄铭达. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DSCallback.h"

//通知
//蓝牙状态改变时的通知
extern NSNotificationName const DSBluetoothNotificationCentralManagerDidUpdateState;

//默认标记
#define kDEFAULT_IDENTIFIER @"DSBluetoothDefaultIdentifier"

@interface DSBluetooth : NSObject

#pragma mark --- 回调方法 只在单一界面处理 就可以使用这个---

//便利连接
- (void)convenientConnectFilterRules:(DSFilterConnectPeripherals)filterRules success:(DSConvenientConnectSuccess)success fail:(DSConvenientConnectFail)fail;

//蓝牙扫描，连接时的配置参数 详见DSBluetoothConfig
- (void)config:(DSBluetoothConfig *)config;

//蓝牙状态改变
- (void)centralManagerStateChange:(DSCentralManagerStateChange)block;

//搜索外设，搜索到外设回调
- (void)discoverPeripheralBlock:(DSDiscoverPeripheralBlock)block;

//外设连接成功
- (void)connectPeripheralBlock:(DSConnectPeripheralBlock)block;

//外设连接失败
- (void)failConnectPeripheralBlock:(DSFailConnectPeripheralBlock)block;

//外设连接断开
- (void)disconnectPeripheralBlock:(DSDisconnectPeripheralBlock)block;

//发现外设服务
- (void)peripheralDiscoverServices:(DSPeripheralDiscoverServices)block;

//发现外设特征
- (void)servicesDiscoverCharacteristics:(DSServicesDiscoverCharacteristics)block;

//写入数据到特征
- (void)writeValueForCharacteristic:(DSWriteValueForCharacteristic)block;

//接收到特征数据
- (void)updateValueForCharacteristic:(DSUpdateValueForCharacteristic)block;

//筛选发现到的peripherals规则
- (void)filterOnDiscoverPeripherals:(DSFilterDiscoverPeripherals)block;


#pragma mark --- 带标记的回调方法  适用于在不同界面使用 ---

/**
 便利连接，自动连接到筛选出来的peripheral，并且获取所有Characteristic

 @param identifier block实例的标记
 @param filterRules 筛选peripherals的规则
 @param success 连接成功
 @param fail 连接失败
 */
- (void)convenientConnectWithIdentifier:(NSString *)identifier filterRules:(DSFilterConnectPeripherals)filterRules success:(DSConvenientConnectSuccess)success fail:(DSConvenientConnectFail)fail;

//蓝牙扫描，连接时的配置参数 详见DSBluetoothConfig
- (void)configWithIdentifier:(NSString *)identifier config:(DSBluetoothConfig *)config;

//蓝牙状态改变
- (void)centralManagerStateChangeWithIdentifier:(NSString *)identifier block:(DSCentralManagerStateChange)block;

//搜索外设，搜索到外设回调
- (void)discoverPeripheralWithIdentifier:(NSString *)identifier block:(DSDiscoverPeripheralBlock)block;

//外设连接成功
- (void)connectPeripheralWithIdentifier:(NSString *)identifier block:(DSConnectPeripheralBlock)block;

//外设连接失败
- (void)failConnectPeripheralWithIdentifier:(NSString *)identifier block:(DSFailConnectPeripheralBlock)block;

//外设连接断开
- (void)disconnectPeripheralWithIdentifier:(NSString *)identifier block:(DSDisconnectPeripheralBlock)block;

//发现外设服务
- (void)peripheralDiscoverServicesWithIdentifier:(NSString *)identifier block:(DSPeripheralDiscoverServices)block;

//发现外设特征
- (void)servicesDiscoverCharacteristicsWithIdentifier:(NSString *)identifier block:(DSServicesDiscoverCharacteristics)block;

//写入数据到特征
- (void)writeValueForCharacteristicWithIdentifier:(NSString *)identifier block:(DSWriteValueForCharacteristic)block;

//接收到特征数据
- (void)updateValueForCharacteristicWithIdentifier:(NSString *)identifier block:(DSUpdateValueForCharacteristic)block;

//筛选发现到的peripherals规则
- (void)filterOnDiscoverPeripheralsWithIdentifier:(NSString *)idebtifier block:(DSFilterDiscoverPeripherals)block;

#pragma mark -- 标记切换用于查找回调block --

//标记切换
- (void)switchIdentifier:(NSString *)identifier;

#pragma mark -- 基本方法 --

//单例
+ (instancetype)bluetooth;

//开始扫描
- (void)startScan;

//停止扫描
- (void)stopScan;

//连接外设
- (void)connectPeripheral:(CBPeripheral *)peripheral;

//主动断开当前外设连接
- (void)cancelPeripheralConnect;

//写入数据到特征值
- (void)writeData:(NSData *)data characteristic:(CBCharacteristic *)characteristic WithResponse:(BOOL)yesOrNo;

//读取特征值
- (void)readCharacteristic:(CBCharacteristic *)Characteristic;

//监听特征值
- (void)listenForNotification:(BOOL)isNotify characteristic:(CBCharacteristic *)characteristic;

//找到对应特征值
- (CBCharacteristic *)findCharacteristicFormUUIDString:(NSString *)UUIDString;

//蓝牙是否可用
- (BOOL)bluetoothIsPoweredOn;


@end
