//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// List of possible errrors that can happen during connection.
public enum BluetoothError: Error {
    case bluetoothUnavailable
    case incompatibleDevice
}

public enum AdvertisementError: Error {
    case bluetoothError(BluetoothError)
    case deviceNotAdvertising
}

public enum ConnectionError: Error {
    case bluetoothError(BluetoothError)
    case deviceConnectionLimitExceed
    case deviceAlreadyConnected
}
