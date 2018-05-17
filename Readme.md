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

TODO

## Carthage

TODO

## Example connection usage

Feel free to check out bundled sample project.

### Connection:

Here you can find a sample code used to connect with a remote peripheral with one service and characteristic:

```
let connection = BluetoothConnection.shared
let characteristic = try! Characteristic(uuid: "your_characteristic_uuid", shouldObserveNotification: true)
let service = try! Service(uuid: "your_service_uuid", characteristics: [characteristic])
let configuration = try! Configuration(services: [service], advertisement: "your_advertising_uuid")
let peripheral = Peripheral(configuration: configuration)
connection.connect(peripheral) { _ in
	print("Connected")
}
```swift

### Data transfer:

Handling write requests:

```
let command = Command.utf8String("Hello world")
peripheral.write(command: command, characteristic: someCharacteristic, handler: { error in
	// do sth
})
```swift

Handling read requests:

```
peripheral.read(characteristic, handler: { [weak self] data, error in
	// do sth
})
```swift

Handling characteristic notifications:

```
characteristic.notifyHandler = { [weak self] data in
	// do sth
}
```swift

## Example advertisement usage.

### Advertisement setup:

```
let characteristic = try! Characteristic(uuid: "your_characteristic_uuid")
let service = try! Service(uuid: "your_service_uuid", characteristics: [characteristic])
let configuration = try! Configuration(services: [service], advertisement: "your_service_uuid")
let peripheral = Peripheral(configuration: configuration, advertisementData: [.localName("Test"), .servicesUUIDs("your_service_uuid")])
advertisement.advertise(peripheral: peripheral) { _ in
	// handle possible error            
}
```swift

### Handling requests:

Updating values for characteristics:

```
let command = Command.int8(3)
advertisement.update(command, characteristic: characteristic) { error in
	// notified subscribed centrals
}
```swift

Handling write requests:

```
advertisement.writeRequestCallback = { characteristic, data in
	// handle write request
}
```swift

Handling read requests:

```
advertisement.readRequestCallback = { characteristic -> Data in
	// respond to read request
}
```swift

### License

Licensed under MIT license.

