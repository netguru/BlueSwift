//
//  ExtensionTests.swift
//  FrameworkTests
//
//  Created by Jan Posz on 08.01.2018.
//  Copyright © 2018 Netguru. All rights reserved.
//

import XCTest
@testable import Bluetooth

class ExtensionTests: XCTestCase {
    
    func testShortUUIDValidation() {
        let fourCharactersCorrect = "1800"
        let sixCharactersCorrext = "2A0B16"
        
        let tooLong = "180000"
        let tooShort = "67A"
        
        let notHexadecimal = "180X"
        
        XCTAssertTrue(fourCharactersCorrect.isValidShortenedUUID())
        XCTAssertTrue(sixCharactersCorrext.isValidShortenedUUID())
        XCTAssertFalse(tooLong.isValidShortenedUUID())
        XCTAssertFalse(tooShort.isValidShortenedUUID())
        XCTAssertFalse(notHexadecimal.isValidShortenedUUID())
    }
    
}
