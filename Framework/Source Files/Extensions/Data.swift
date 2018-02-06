//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Data extension allowing conversion from Data into String containing exactly the same bytes.
internal extension Data {
    
    /// Returns encoded String.
    internal var hexEncodedString: String {
        return map { String(format: "%02hhX", $0) }.joined()
    }
}
