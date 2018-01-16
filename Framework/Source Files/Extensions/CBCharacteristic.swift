//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import CoreBluetooth.CBCharacteristic

internal extension CBCharacteristic {
    
    /// Validates if given characteristic is readable.
    internal func validateForRead() -> Bool {
        return properties == .read
    }
    
    /// Validates if given characteristic is writeable.
    internal func validateForWrite() -> Bool {
        return properties == .write || properties == .writeWithoutResponse
    }
}
