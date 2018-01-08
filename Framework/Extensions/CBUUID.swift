//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import CoreBluetooth.CBUUID

internal extension CBUUID {
    
    /// Error for creating a CBUUID with string invalid to UUID standards.
    enum CreationError: Error {
        case invalidString
    }
    
    /// Convenience initializer, a wrapper for default init(string: String) method with error handling, not crashing like default one.
    ///
    /// - Parameter uuidString - a String wished to be converted into CBUIID.
    /// - Throws: CreationError.invalidString if passed String is not valid.
    convenience internal init(uuidString: String) throws {
        guard let uuid = UUID(uuidString: uuidString) else {
            if uuidString.isValidShortenedUUID() {
                self.init(string: uuidString)
                return
            }
            throw CreationError.invalidString
        }
        self.init(nsuuid: uuid)
    }
}
