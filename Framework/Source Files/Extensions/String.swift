//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

internal extension String {
    
    /// Validates if String is a proper shoretened UUID which means its 4 or 6 characters long and contains only hexadecimal characters.
    internal func isValidShortenedUUID() -> Bool {
        var evaluation = self
        if hasPrefix("0x") {
            evaluation = evaluation.replacingOccurrences(of: "0x", with: "")
        }
        return isHexadecimal && (evaluation.count == 4 || evaluation.count == 6)
    }
    
    /// Checks if string contains only hexadecimal characters.
    internal var isHexadecimal: Bool {
        let invertedHexCharacterSet = NSCharacterSet(charactersIn: "0123456789ABCDEF").inverted
        return uppercased().rangeOfCharacter(from: invertedHexCharacterSet) == nil
    }
}

/// String extension allowing conversion of strings like 0x2A01 into Data with the same format.
internal extension String {
    
    /// Returns Data with decoded string.
    internal func hexDecodedData() throws -> Data {
        guard isHexadecimal else {
            throw Command.ConversionError.incorrectInputFormat
        }
        var data = Data(capacity: count / 2)
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSMakeRange(0, utf16.count)) { match, _, _ in
            guard let nsRange = match?.range, let range = Range(nsRange, in: self) else { return }
            let byteString = self[range]
            guard var num = UInt8(byteString, radix: 16) else { return }
            data.append(&num, count: 1)
        }
        return data
    }
}
