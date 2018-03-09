//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// List of possible general Bluetooth failures.
public enum BluetoothError: Error {
    case bluetoothUnavailable
    case incompatibleDevice
}

/// List of possible errors during advertisement.
public enum AdvertisementError: Error {
    case bluetoothError(BluetoothError)
    case deviceNotAdvertising
    case incorrectUpdateData
    case otherError(Error)
}

/// List of possible errors during connection.
public enum ConnectionError: Error {
    case bluetoothError(BluetoothError)
    case deviceConnectionLimitExceed
    case deviceAlreadyConnected
}
