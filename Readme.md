![](https://img.shields.io/badge/swift-4.2-orange.svg)
![](https://img.shields.io/github/release/netguru/BlueSwift.svg)
![](https://img.shields.io/badge/carthage-compatible-green.svg)
![](https://img.shields.io/badge/cocoapods-compatible-green.svg)
![](https://app.bitrise.io/app/23a07b63b3f55f97/status.svg?token=Rt_2gKUavbR8LQ7PVuTbYg&branch=master)

Easy to use Bluetooth open source library brought to you by Netguru.
Probably the easiest way to interact with bluetooth peripherals 🤟

## Features

- [x] Handles connection with remote peripherals.
- [x] Handles advertising an iPhone as Bluetooth LE peripheral.
- [x] Closure based read/write/notify requests.
- [x] Built in data conversion method with `Command` wrapper.

### Connection:

Below you can find

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

### Dependency management:

BlueSwift can be drag'n dropped to the project directory, but what's more important it's supported by most common dependency management!

## Cocoapods

`pod "BlueSwift"``

## Carthage

`github "netguru/BlueSwift"``

### License

(As all cool open source software, it's...)
Licensed under MIT license.
🚀🚀
