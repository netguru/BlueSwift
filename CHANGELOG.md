# Change Log
All notable changes to this project will be documented in this file.

## [1.1.4] - 2023-01-20

### Changed

- Synchronize access to array storing peripherals to increase thread safety.


## [1.1.3] - 2022-10-25

### Changed

- Peripheral which was connected, but it was not on the list of peripherals that should be connected, is disconnected. This change allows to discover this peripheral again. 

## [1.1.2] - 2022-09-06

### Added

- added settable `centralManagerStateUpdateHandler` public property to `BluetoothConnection` to monitor updates to Central Manager state.

## [1.1.1] - 2022-04-14

### Added

- `bluetoothAuthorizationStatus` public property was added to `BluetoothConnection` to determine current Bluetooth authorization status.
- `requestBluetoothAuthorization()` public method was added to `BluetoothConnection` to requests User for authorization to use Bluetooth.
- `BluetoothAuthorizationStatus` enum describing Bluetooth authorization status

### Changed

- `ConnectionService`: centralManager (`CBCentralManager`) is instantiated lazily to postpone showing Bluetooth authorization popup until it is needed.

## [1.1.0] - 2022-04-13

### Changed

- enabled Swift library evolution (`BUILD_LIBRARY_FOR_DISTRIBUTION = YES`) to allow creating XCFrameworks using BlueSwift. See ["Library Evolution in Swift"](https://www.swift.org/blog/library-evolution/) official swift blogpost.
This change:
    - allows modules built with different compiler versions to be used together in one app.
    - allows developers of binary frameworks to make additive changes to the API of their framework while remaining binary compatible with previous versions.

## [1.0.6] - 2022-04-08

### Added

- added public `peripheralConnectionCancelledHandler(_:)` setable property to `BluetoothConnection` class. It is called when disconnecting a peripheral using `disconnect(_:)` is completed

### Changed

- refactored `.filter(_:).first` to `first(where:)` for optimisation
