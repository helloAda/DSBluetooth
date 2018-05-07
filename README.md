### 前言

写这个库主要是因为`CoreBluetooth`的回调在多个页面的时候不好处理，虽然改用Block形式也是代码量没太多减少，但是逻辑相对来说比较清晰点。
另外由于时间有限，这个库目前只限于手机作为`Central`端，BLE设备作为`Peripheral`端的一对一的使用，欢迎大家一起完善更多功能。
如果你才刚接触蓝牙，可以看看[这篇文章](http://helloada.cn/2018/05/05/ios-corebluetooth/)，至少能理解与蓝牙交互的整个过程。



### 简单使用

一般来说，在项目中都需要先绑定一个设备然后下次使用的时候，直接能够连接这个设备，就不必在手动选择了。
```
    DSBluetooth *bluetooth = [DSBluetooth bluetooth];
    [bluetooth discoverPeripheralWithIdentifier:@"identifier" block:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
    //扫描到设备 to do 绑定等。
    }];

    //如果有需要配置则要先初始化，然后在开始扫描
//    DSBluetoothConfig *config = [DSBluetoothConfig alloc] initWithScanForPeripheralsServices:nil discoverServices:nil discoverCharacteristics:nil
//    [bluetooth configWithIdentifier:@"identifier" config:config];
    
    //切换到这个标记下的Block
    [bluetooth switchIdentifier:@"identifier"];
    [bluetooth startScan];
    NSLog(@"标记@"identifier" ，开始扫描");

```

绑定之后连接，就只需要使用这个方法。
```
    DSBluetooth *bluetooth = [DSBluetooth bluetooth];
    /*
     便利连接 如果有绑定了就直接使用这个比较方便，否则就需要在discoverPeripheralWithIdentifier:block:里面自己调用连接的方法。这里就简单演示一下。
     */
    [bluetooth convenientConnectWithIdentifier:@"identifier" filterRules:^BOOL(CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
    //筛选
   } success:^{
      //成功
    } fail:^{
    //失败
    }];
     [bluetooth switchIdentifier:@"identifier"];
    [bluetooth startScan];
    NSLog(@"标记@"identifier" ，开始扫描");
```

更多的使用可以下载Demo进行了解，每个方法都有注释。
在多个界面使用的时候，只需要添加这个界面独有的identifier在切换过去，这样就解决了多个界面使用的问题，每个标记对应一个独立的callblock。

### 大致结构
![结构](https://github.com/helloAda/DSBluetooth/blob/master/DSBluetooth/image/struct.png)


#### 如果觉得对你有帮助，欢迎`Star`

