//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import CoreBluetooth.CBCharacteristic


internal extension CBCharacteristic {
    
    internal func validateForRead() -> Bool {
        return properties == .read
    }
    
    internal func validateForWrite() -> Bool {
        return properties == .write || properties == .writeWithoutResponse
    }
}
