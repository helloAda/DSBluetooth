//
//  DSCallback.m
//  
//
//  Created by HelloAda on 2018/4/2.
//  Copyright © 2018年 黄铭达. All rights reserved.
//

#import "DSCallback.h"

@implementation DSCallback

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setFilterDiscoverPeripherals:^(CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
            if (peripheral.name) {
                return YES;
            }
            return NO;
        }];
        
        [self setFilterConnectPeripherals:^(CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
            if (peripheral.name) {
                return YES;
            }
            return NO;
        }];
    }
    return self;
}
@end
