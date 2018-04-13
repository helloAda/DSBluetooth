//
//  DSBluetoothConfig.h
//  DSBluetooth
//
//  Created by HelloAda on 2018/4/12.
//  Copyright © 2018年 HelloAda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DSBluetoothConfig : NSObject

/**
 扫描设备Services参数
 scanForPeripheralsWithServices:options:
 */
@property (nonatomic, strong) NSArray *scanForPeripheralsServices;

/**
 扫描设备options参数
 scanForPeripheralsWithServices:options:
 */
@property (nonatomic, strong) NSDictionary *scanForPeripheralsOptions;

/**
 连接设备option参数
 connectPeripheral:options:nil
 */
@property (nonatomic, strong) NSDictionary *connectPeripheralOptions;

/**
 设备发现指定服务
 discoverServices:
 */
@property (nonatomic, strong) NSArray *discoverServices;

/**
 服务发现指定特征
 discoverCharacteristics:forService:
 */
@property (nonatomic, strong) NSArray *discoverCharacteristics;

#pragma mark --- 初始化方法 ---

- (instancetype)initWithScanForPeripheralsServices:(NSArray *)scanForPeripheralsServices
                                  discoverServices:(NSArray *)discoverServices
                           discoverCharacteristics:(NSArray *)discoverCharacteristics;

- (instancetype)initWithScanForPeripheralsServices:(NSArray *)scanForPeripheralsServices
                         scanForPeripheralsOptions:(NSDictionary *)scanForPeripheralsOptions
                          connectPeripheralOptions:(NSDictionary *)connectPeripheralOptions
                                  discoverServices:(NSArray *)discoverServices
                           discoverCharacteristics:(NSArray *)discoverCharacteristics;


@end
