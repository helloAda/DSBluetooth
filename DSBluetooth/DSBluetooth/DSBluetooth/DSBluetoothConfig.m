//
//  DSBluetoothConfig.m
//  DSBluetooth
//
//  Created by HelloAda on 2018/4/12.
//  Copyright © 2018年 HelloAda. All rights reserved.
//

#import "DSBluetoothConfig.h"

@implementation DSBluetoothConfig

- (instancetype)init
{
    self = [super init];
    if (self) {
        _scanForPeripheralsServices = nil;
        _scanForPeripheralsOptions  = nil;
        _connectPeripheralOptions   = nil;
        _discoverServices           = nil;
        _discoverCharacteristics    = nil;
    }
    return self;
}


- (instancetype)initWithScanForPeripheralsServices:(NSArray *)scanForPeripheralsServices discoverServices:(NSArray *)discoverServices discoverCharacteristics:(NSArray *)discoverCharacteristics {
    self = [self initWithScanForPeripheralsServices:scanForPeripheralsServices scanForPeripheralsOptions:nil connectPeripheralOptions:nil discoverServices:discoverServices discoverCharacteristics:discoverCharacteristics];
    return self;
}

- (instancetype)initWithScanForPeripheralsServices:(NSArray *)scanForPeripheralsServices scanForPeripheralsOptions:(NSDictionary *)scanForPeripheralsOptions connectPeripheralOptions:(NSDictionary *)connectPeripheralOptions discoverServices:(NSArray *)discoverServices discoverCharacteristics:(NSArray *)discoverCharacteristics {
    self = [super init];
    if (self) {
        self.scanForPeripheralsServices = scanForPeripheralsServices;
        self.scanForPeripheralsOptions = scanForPeripheralsOptions;
        self.connectPeripheralOptions = connectPeripheralOptions;
        self.discoverServices = discoverServices;
        self.discoverCharacteristics = discoverCharacteristics;
    }
    return self;
}
@end
