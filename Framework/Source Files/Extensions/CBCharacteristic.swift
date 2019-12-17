//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import CoreBluetooth.CBCharacteristic

internal extension CBCharacteristic {
    
    /// Validates if given characteristic is readable.
    func validateForRead() -> Bool {
        return properties.contains(.read)
    }
    
    /// Validates if given characteristic is writeable.
    func validateForWrite() -> Bool {
        return properties.contains(.write) || properties.contains(.writeWithoutResponse)
    }
}
