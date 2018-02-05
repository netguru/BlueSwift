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
        let invertedHexCharacterSet = NSCharacterSet(charactersIn: "0123456789ABCDEF").inverted
        return evaluation.uppercased().rangeOfCharacter(from: invertedHexCharacterSet) == nil
            && (evaluation.count == 4 || evaluation.count == 6)
    }
}

/// String extension allowing conversion of strings like 0x2A01 into Data with the same format.
internal extension String {
    
    /// Returns Data with decoded string.
    internal func hexDecodedData() throws -> Data {
        var data = Data(capacity: count / 2)
        guard let regex = try? NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive) else {
            throw Command.ConversionError.incorrectInputFormat
        }
        regex.enumerateMatches(in: self, range: NSMakeRange(0, utf16.count)) { match, _, _ in
            guard let nsRange = match?.range, let range = Range(nsRange, in: self) else { return }
            let byteString = self[range]
            guard var num = UInt8(byteString, radix: 16) else { return }
            data.append(&num, count: 1)
        }
        guard data.count != 0 else {
            throw Command.ConversionError.incorrectInputFormat
        }
        return data
    }
}
