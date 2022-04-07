## BluetoothConnection

## Overview

It's a class responsible for management of peripheral connections. It's a singleton by design as it's recommended to use only one instance of `CBCentralManager` per application. One instance of that class can be also responsible for connecting multiple peripherals. Although you're welcome to create your own instance.
It uses [Peripheral](./peripheral.md) class for connection.

## Topics

```swift
static let shared = BluetoothConnection()
```

A singleton instance of the class. Motivation to use it is carried by the fact that it's recommended to use only one instance of `CBCentralManager` per application.

```swift
var advertisementValidationHandler: ((Peripheral<Connectable>, String, [String: Any]) -> (Bool))?
```

An optional closure, nil by default. If set you can setup custom filtering of scanned peripherals basing on their advertising packets.
Advertising is passed in `[String: Any]` dictionary. This data is sent along with a string representing a CoreBluetooth identifier of the device(unique and not changing per each device) and corresponding peripheral instance.
If false is returned from this method, no attempt to connect a given peripheral will we attempted.

```swift
var peripheralConnectionCancelledHandler: ((Peripheral<Connectable>, CBPeripheral) -> Void)?
```

An optional closure, nil by default - peripheral connection cancelled handler. Called when disconnecting a peripheral using `disconnect(_:)` is completed.
Contains matched peripheral and native peripheral from CoreBluetooth.

```swift
func connect(_ peripheral: Peripheral<Connectable>, handler: ((ConnectionError?) -> ())?)
```

Main method responsible for connecting a peripheral. After configuring a proper [Peripheral](./peripheral.md) class it can be passed here to be connected. After it's connected or some error is raised, the `handler` closure is called. If error is nil, you can assume connection went well.
Possible errors are raised when Bluetooth is unavailable or turned off, maximum connected devices limit is exceeded(the limit is 8 devices) or that device is already connected.

```swift
func disconnect(_ peripheral: Peripheral<Connectable>) throws
```

Disconnects a given device. It can throw only in case the device is not already connected so the error can be safely ignored in most cases.
