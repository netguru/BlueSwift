//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
import CoreBluetooth
@testable import BlueSwift

class ExtensionTests: XCTestCase {
    
    //MARK: String extension tests
    
    func testShortUUIDValidation() {
        let fourCharactersCorrect = "1800"
        let sixCharactersCorrext = "2A0B16"
        
        let tooLong = "1800000"
        let tooShort = "67A"
        
        let notHexadecimal = "180X"
        
        XCTAssertTrue(fourCharactersCorrect.isValidShortenedUUID(), "Four character valid uuid validation failed")
        XCTAssertTrue(sixCharactersCorrext.isValidShortenedUUID(), "Six character valid uuid validation failed")
        XCTAssertFalse(tooLong.isValidShortenedUUID(), "Too long invalid uuid validation passed")
        XCTAssertFalse(tooShort.isValidShortenedUUID(), "Too short invalid uuid validation passed")
        XCTAssertFalse(notHexadecimal.isValidShortenedUUID(), "Not hexadecimal invalid uuid validation passed")
    }
    
    //MARK: Array extension tests
    
    func testArrayCommonPart() {
        let first = [1, 2, 3, 4, 5]
        let second = [4, 5, 6, 7]
        
        let common = first.matchingElementsWith(second) { $0 == $1 }
        
        XCTAssertEqual(common.count, 2, "Expected matches count is invalid")
        XCTAssertEqual(common.first?.0, 4, "Array first element matching failed")
        XCTAssertEqual(common.last?.1, 5, "Array second element matching failed")
    }
    
    func testServiceMatching() {
        let services = [try! Service(uuid: "1800", characteristics: []),
                        try! Service(uuid: "1801", characteristics: [])]
        let cbServices = [CBMutableService(type: CBUUID(string: "1800"), primary: false) as CBService,
                          CBMutableService(type: CBUUID(string: "1802"), primary: false) as CBService]
        
        let common = services.matchingElementsWith(cbServices)
        
        XCTAssertEqual(common.count, 1, "Expected matches count is invalid")
        XCTAssertEqual(common.first?.0.bluetoothUUID.uuidString, common.first?.1.uuid.uuidString, "Expected uuid's does not match")
    }
    
    func testCharacteristicMatching() {
        let services = [try! Characteristic(uuid: "2A0B"),
                        try! Characteristic(uuid: "1801")]
        let cbCharacteristics = [CBMutableCharacteristic(type: CBUUID(string: "1801"), properties: [.read], value: nil, permissions: .readable) as CBCharacteristic,
                                 CBMutableCharacteristic(type: CBUUID(string: "1800"), properties: [.read], value: nil, permissions: .readable) as CBCharacteristic]
        
        let common = services.matchingElementsWith(cbCharacteristics)
        
        XCTAssertEqual(common.count, 1, "Expected matches count is invalid")
        XCTAssertEqual(common.first?.0.bluetoothUUID.uuidString, common.first?.1.uuid.uuidString, "Expected uuid's does not match")
    }
    
    func testAdvertisementCombine() {
        
        let advertisementParameters: [AdvertisementData] = [.localName("Test"), .servicesUUIDs("2A01"), .servicesUUIDs("2A02"), .txPower(30)]
        let dictionary = advertisementParameters.combined()
        
        XCTAssertEqual(dictionary[CBAdvertisementDataLocalNameKey] as? String, "Test")
        XCTAssertEqual(dictionary[CBAdvertisementDataTxPowerLevelKey] as? Int, 30)
        guard let array = dictionary[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] else {
            XCTFail()
            return
        }
        XCTAssertEqual(array[0].uuidString, "2A01")
        XCTAssertEqual(array[1].uuidString, "2A02")
    }
}

