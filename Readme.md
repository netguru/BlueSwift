![](https://img.shields.io/badge/swift-4.2-orange.svg)
![](https://img.shields.io/github/release/netguru/BlueSwift.svg)
![](https://img.shields.io/badge/carthage-compatible-green.svg)
![](https://img.shields.io/badge/cocoapods-compatible-green.svg)
![](https://app.bitrise.io/app/23a07b63b3f55f97/status.svg?token=Rt_2gKUavbR8LQ7PVuTbYg&branch=master)

Set of emojis ( 🛠 , ⚙️ , 📲 , 📡 , 📬  , 🤹🏻‍♂️ , )

Easy to use Bluetooth open source library brought to you by Netguru.<br/>
🤟 Probably the easiest way to interact with bluetooth peripherals 🤟

## Features

- [x] Handles connection with remote peripherals.
- [x] Handles advertising an iPhone as Bluetooth LE peripheral.
- [x] Closure based read/write/notify requests.
- [x] Built in data conversion method with `Command` wrapper.

##  📲  Connection:



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

## 📡 Advertisement:



```swift
let characteristic = try! Characteristic(uuid: "your_characteristic_uuid")
let service = try! Service(uuid: "your_service_uuid", characteristics: [characteristic])
let configuration = try! Configuration(services: [service], advertisement: "your_service_uuid")
let peripheral = Peripheral(configuration: configuration, advertisementData: [.localName("Test"), .servicesUUIDs("your_service_uuid")])
advertisement.advertise(peripheral: peripheral) { _ in
	// handle possible error            
}
```

## ⚙️ Advanced usage:

For more advanced usage check out documentation page at: https://blueswift.github.io

## 🛠 Dependency management:

BlueSwift can be drag'n dropped to the project directory,<br/>but what's more important it's supported by most common dependency management!

### ![](https://img.shields.io/badge/cocoapods-compatible-green.svg)

Just drop the line below to your Podfile:

`pod 'BlueSwift'`

(but probably you'd like to pin it to the nearest major release, so `pod 'BlueSwift' , '~> 1.0.0'`)

### ![](https://img.shields.io/badge/carthage-compatible-green.svg)

`github 'netguru/BlueSwift'`

## 📄 License

(As all cool open source software, it's...)<br/>
Licensed under MIT license.<br/>

Also it would be really nice if you could drop us a line about your usage!! 🚀🚀
