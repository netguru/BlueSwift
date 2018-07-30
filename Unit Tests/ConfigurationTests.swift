//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
import CoreBluetooth.CBUUID
@testable import BlueSwift

class ConfigurationTests: XCTestCase {
    
    func testServiceUUIDCreation() {
        
        let correctUUIDLong = "4983BB4D-EC7A-47DD-88E7-EB48859B083A"
        let correctUUIDShort = "1800"
        let incorrectUUID = "test"
        
        let serviceLong = try? Service(uuid: correctUUIDLong, characteristics: [])
        let serviceShort = try? Service(uuid: correctUUIDShort, characteristics: [])
        
        XCTAssertEqual(serviceLong?.bluetoothUUID.uuidString, correctUUIDLong, "Incorrect parse of long UUID's for Service.")
        XCTAssertEqual(serviceShort?.bluetoothUUID.uuidString, correctUUIDShort, "Incorrect parse of short UUID's for Service.")
        
        do {
            _ = try Service(uuid: incorrectUUID, characteristics: [])
            XCTFail("Improper Service creation should throw an error.")
        } catch let error {
            guard let error = error as? CBUUID.CreationError else {
                XCTFail()
                return
            }
            XCTAssertEqual(error, CBUUID.CreationError.invalidString, "Incorrect error returned when parsing wrong UUID.")
        }
    }
    
    func testCharacteristicUUIDCreation() {
        
        let correctUUIDLong = "9CD82657-17AC-404D-B9D6-CF7D4F0F94A2"
        let correctUUIDShort = "2A01"
        let incorrectUUID = "2A01B"
        
        let characteristicLong = try? Characteristic(uuid: correctUUIDLong)
        let characteristicShort = try? Characteristic(uuid: correctUUIDShort)
        
        XCTAssertEqual(characteristicLong?.bluetoothUUID.uuidString, correctUUIDLong, "Incorrect parse of long UUID's for Characteristic.")
        XCTAssertEqual(characteristicShort?.bluetoothUUID.uuidString, correctUUIDShort, "Incorrect parse of short UUID's for Characteristic.")
        
        do {
            _ = try Characteristic(uuid: incorrectUUID)
            XCTFail("Improper Characteristic creation should throw an error.")
        } catch let error {
            guard let error = error as? CBUUID.CreationError else {
                XCTFail()
                return
            }
            XCTAssertEqual(error, CBUUID.CreationError.invalidString, "Incorrect error returned when parsing wrong UUID.")
        }
    }
}
