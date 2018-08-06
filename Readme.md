![](https://img.shields.io/badge/swift-4.0-orange.svg)

Easy to use Bluetooth open source library by Netguru. Provides convenient methods of interacting with Bluetooth LE peripherals.

## Features

- [x] Handles connection with remote peripharals.
- [x] Handles advertising an iPhone as Bluetooth LE peripheral.
- [x] Closure based read/write/notify requests.
- [x] Built in data conversion method with `Command` wrapper.

## Requirements

Swift 4.1, iOS 10.0 or higher.

## Cocoapods

pod 'BlueSwift'

## Carthage

github "netguru/BlueSwift"

## Example connection usage

Feel free to check out bundled sample project.

### Connection:

Here you can find a sample code used to connect with a remote peripheral with one service and characteristic:

```swift
let connection = BluetoothConnection.shared
let characteristic = try! Characteristic(uuid: "your_characteristic_uuid", shouldObserveNotification: true)
let service = try! Service(uuid: "your_service_uuid", characteristics: [characteristic])
let configuration = try! Configuration(services: [service], advertisement: "your_advertising_uuid")
let peripheral = Peripheral(configuration: configuration)
connection.connect(peripheral) { _ in
	print("Connected")
}
```

### Data transfer:

Handling write requests:

```swift
let command = Command.utf8String("Hello world")
peripheral.write(command: command, characteristic: someCharacteristic, handler: { error in
	// do sth
})
```

Handling read requests:

```swift
peripheral.read(characteristic, handler: { [weak self] data, error in
	// do sth
})
```

Handling characteristic notifications:

```swift
characteristic.notifyHandler = { [weak self] data in
	// do sth
}
```

## Example advertisement usage.

### Advertisement setup:

```swift
let characteristic = try! Characteristic(uuid: "your_characteristic_uuid")
let service = try! Service(uuid: "your_service_uuid", characteristics: [characteristic])
let configuration = try! Configuration(services: [service], advertisement: "your_service_uuid")
let peripheral = Peripheral(configuration: configuration, advertisementData: [.localName("Test"), .servicesUUIDs("your_service_uuid")])
advertisement.advertise(peripheral: peripheral) { _ in
	// handle possible error            
}
```

### Handling requests:

Updating values for characteristics:

```swift
let command = Command.int8(3)
advertisement.update(command, characteristic: characteristic) { error in
	// notified subscribed centrals
}
```

Handling write requests:

```swift
advertisement.writeRequestCallback = { characteristic, data in
	// handle write request
}
```

Handling read requests:

```swift
advertisement.readRequestCallback = { characteristic -> Data in
	// respond to read request
}
```

### License

Licensed under MIT license.

