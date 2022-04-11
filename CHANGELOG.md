# Change Log
All notable changes to this project will be documented in this file.


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
