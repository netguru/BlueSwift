//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

extension String {
    
    // Validates if String is a proper shoretened UUID which means its 4 or 6 characters long and contains only hexadecimal characters.
    func isValidShortenedUUID() -> Bool {
        var evaluation = self
        if hasPrefix("0x") {
            evaluation = evaluation.replacingOccurrences(of: "0x", with: "")
        }
        let invertedHexCharacterSet = NSCharacterSet(charactersIn: "0123456789ABCDEF").inverted
        return evaluation.uppercased().rangeOfCharacter(from: invertedHexCharacterSet) == nil
            && (evaluation.count == 4 || evaluation.count == 6)
    }
}
