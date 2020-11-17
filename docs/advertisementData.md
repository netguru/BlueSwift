## AdverisementData

## Overview

It's a convenient enum to deal with values put in advertisement header when acting as a peripheral. Used when initializing [Peripheral](./peripheral.md) in an `Advertisable` generic mode. It's intended to be a wrapper around CoreBluetooth default statics such as `CBAdvertisementDataServiceUUIDsKey` which makes them hard to remember.

## Topics

```swift
case localName(String)
```swift

```swift
case servicesUUIDs(String)
```swift

```swift
case serviceData(Data)
```swift

```swift
case txPower(Int)
```swift

```swift
case manufacturersData(String)
```swift

```swift
case custom(String, Any)
```swift
