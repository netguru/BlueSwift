//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//


import Foundation

/// Command enum - a handy wrapper for creating requests to peripheral devices.
/// Handles creation of data with length according to passed parameter type, also creates data straight from hexadecimal
/// string with exact the same value. If none of the cases matches needed type, use .data(Data) case where Data object can be
/// passed directly.
public enum Command {
    case int8(UInt8)
    case int16(UInt16)
    case int32(UInt32)
    case hexString(String)
    case data(Data)
    
    /// An error triggered when data parse fails.
    public enum ConversionError: Error {
        case incorrectInputFormat
    }
}

internal extension Command {
    
    /// Variable used for conversion of parameters to Data possible to write to peripheral.
    /// - Throws: Command.ConversionError
    internal func convertedData() throws -> Data {
        switch self {
        case .int8(let number):
            return number.decodedData
        case .int16(let number):
            return number.decodedData
        case .int32(let number):
            return number.decodedData
        case .hexString(let string):
            return try string.hexDecodedData()
        case .data(let data):
            return data
        }
    }
}
