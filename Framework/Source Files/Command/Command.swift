//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//


import Foundation

public enum Command {
    case int8(UInt8)
    case int16(UInt16)
    case int32(UInt32)
    case hexString(String)
    case data(Data)
}

internal extension Command {
    
    internal var data: Data {
        return Data()
    }
}
