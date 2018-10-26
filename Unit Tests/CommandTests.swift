//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import BlueSwift

class CommandTests: XCTestCase {
    
    func testHexDataConversion() {
        let properShortString = "1A2B"
        let properLongString = "0123456789ABCDEF"
        let improperString = "12345Z"
        
        let shortData = try! properShortString.hexDecodedData()
        let shortFirst = shortData.subdata(in: 0..<1)
        XCTAssertEqual(shortFirst.hexEncodedString, "1A", "Incorrect hex string parse")
        let shortSecond = shortData.subdata(in: 1..<2)
        XCTAssertEqual(shortSecond.hexEncodedString, "2B", "Incorrect hex string parse")
        let longData = try! properLongString.hexDecodedData()
        let longFirst = longData.subdata(in: 0..<1)
        XCTAssertEqual(longFirst.hexEncodedString, "01", "Incorrect hex string parse")
        let longSecond = longData.subdata(in: 3..<4)
        XCTAssertEqual(longSecond.hexEncodedString, "67", "Incorrect hex string parse")
        let longLast = longData.subdata(in: 7..<8)
        XCTAssertEqual(longLast.hexEncodedString, "EF", "Incorrect hex string parse")
        
        do {
            _ = try improperString.hexDecodedData()
            XCTFail("Improper string successfull parse should throw an error.")
        }
        catch let error {
            guard let error = error as? Command.ConversionError else {
                XCTFail()
                return
            }
            XCTAssertEqual(error, Command.ConversionError.incorrectInputFormat, "Incorrect error created on wrong hex string parse")
        }
    }
    
    func testIntegerDataConversion() {
        
        let eightInt: UInt8 = 3
        let sixteenInt: UInt16 = 200
        let thirtyTwoInt: UInt32 = 65637
        
        let eightData = eightInt.decodedData
        XCTAssertEqual(eightData.count, 1, "Incorrect length for 8 bit data.")
        let sixteenData = sixteenInt.decodedData
        XCTAssertEqual(sixteenData.count, 2, "Incorrect length for 16 bit data.")
        let thirtyTwoData = thirtyTwoInt.decodedData
        XCTAssertEqual(thirtyTwoData.count, 4, "Incorrect length for 32 bit data.")
    }
}
