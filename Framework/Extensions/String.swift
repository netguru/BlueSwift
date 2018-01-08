//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

extension String {
    
    func isValidShortenedUUID() -> Bool {
        let invertedHexCharacterSet = NSCharacterSet(charactersIn: "0123456789ABCDEF").inverted
        return uppercased().rangeOfCharacter(from: invertedHexCharacterSet) == nil && (count == 4 || count == 6)
    }
}
