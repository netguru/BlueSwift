//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import Bluetooth

class ExtensionTests: XCTestCase {
    
    func testShortUUIDValidation() {
        let fourCharactersCorrect = "1800"
        let sixCharactersCorrext = "2A0B16"
        
        let tooLong = "1800000"
        let tooShort = "67A"
        
        let notHexadecimal = "180X"
        
        XCTAssertTrue(fourCharactersCorrect.isValidShortenedUUID())
        XCTAssertTrue(sixCharactersCorrext.isValidShortenedUUID())
        XCTAssertFalse(tooLong.isValidShortenedUUID())
        XCTAssertFalse(tooShort.isValidShortenedUUID())
        XCTAssertFalse(notHexadecimal.isValidShortenedUUID())
    }
    
}
