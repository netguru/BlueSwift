//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Extension for signed integers allowing conversion to Data with proper size.
internal extension UnsignedInteger {

    /// Returns decoded data with proper size.
    var decodedData: Data {
        return withUnsafeBytes(of: self) { Data($0) }
    }
}
