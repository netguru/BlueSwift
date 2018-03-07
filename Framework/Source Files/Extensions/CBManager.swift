//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import CoreBluetooth

internal extension CBManager {
    
    func validateState() throws {
        switch state {
        case .poweredOff, .resetting, .unauthorized:
            throw BluetoothError.bluetoothUnavailable
        case .unsupported, .unknown:
            throw BluetoothError.incompatibleDevice
        default:
            break
        }
    }
}
