//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import CoreBluetooth

internal extension CBManager {

    /// Validates the current state of CBManager class to determine if Bluetooth is not supported on this device or is turned off or unavailable for some other reason.
    func validateState() throws {
        switch state {
        case .poweredOff:
            BlueSwiftLogger.shared.log(.error, "validateState - poweredOff", data: state)
            throw BluetoothError.bluetoothUnavailable
        case .resetting:
            BlueSwiftLogger.shared.log(.error, "validateState - resetting", data: state)
            throw BluetoothError.bluetoothUnavailable
        case .unauthorized:
            BlueSwiftLogger.shared.log(.error, "validateState - unauthorized", data: state)
            throw BluetoothError.unauthorized
        case .unsupported:
            BlueSwiftLogger.shared.log(.error, "validateState - unsupported", data: state)
            throw BluetoothError.incompatibleDevice
        case .unknown:
            BlueSwiftLogger.shared.log(.error, "validateState - unknown", data: state)
            throw BluetoothError.incompatibleDevice
        default:
            BlueSwiftLogger.shared.log(.info, "validateState", data: state)
            break
        }
    }
}
