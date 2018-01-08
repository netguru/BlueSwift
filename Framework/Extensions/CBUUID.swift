//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import CoreBluetooth.CBUUID

internal extension CBUUID {
    
    /// An error for creating
    enum CreationError: Error {
        case invalidString
    }
    
    convenience internal init(uuidString: String) throws {
        guard let uuid = UUID(uuidString: uuidString) else {
            throw CBUUID.CreationError.invalidString
        }
        self.init(nsuuid: uuid)
    }
}
