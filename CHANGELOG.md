# Change Log
All notable changes to this project will be documented in this file.
    
## [1.0.6] - 2022-04-08

### Added

- added public `peripheralConnectionCancelledHandler(_:)` setable property to `BluetoothConnection` class. It is called when disconnecting a peripheral using `disconnect(_:)` is completed

### Changed

- refactored `.filter(_:).first` to `first(where:)` for optimisation
