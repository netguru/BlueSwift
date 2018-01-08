//
//  ConfigurationTests.swift
//  FrameworkTests
//
//  Created by Jan Posz on 08.01.2018.
//  Copyright © 2018 Netguru. All rights reserved.
//

import XCTest
import CoreBluetooth.CBUUID
@testable import Bluetooth

class ConfigurationTests: XCTestCase {
    
    func testServiceUUIDCreation() {
        
        let correctUUIDLong = "4983BB4D-EC7A-47DD-88E7-EB48859B083A"
        let correctUUIDShort = "1800"
        let incorrectUUID = "test"
        
        let serviceLong = try? Service(uuid: correctUUIDLong, characteristics: [])
        let serviceShort = try? Service(uuid: correctUUIDShort, characteristics: [])
        
        assert(serviceLong?.bluetoothUUID.uuidString == correctUUIDLong, "Incorrect parse of long UUID's for Service.")
        assert(serviceShort?.bluetoothUUID.uuidString == correctUUIDShort, "Incorrect parse of short UUID's for Service.")
        
        do {
            _ = try Service(uuid: incorrectUUID, characteristics: [])
        } catch let error {
            guard let error = error as? CBUUID.CreationError else {
                assertionFailure()
                return
            }
            assert(error == CBUUID.CreationError.invalidString, "Incorrect error returned when parsing wrong UUID.")
        }
    }
    
    func testCharacteristicUUIDCreation() {
        
        let correctUUIDLong = "9CD82657-17AC-404D-B9D6-CF7D4F0F94A2"
        let correctUUIDShort = "2A01"
        let incorrectUUID = "2A01B"
        
        let characteristicLong = try? Characteristic(uuid: correctUUIDLong)
        let characteristicShort = try? Characteristic(uuid: correctUUIDShort)
        
        assert(characteristicLong?.bluetoothUUID.uuidString == correctUUIDLong, "Incorrect parse of long UUID's for Characteristic.")
        assert(characteristicShort?.bluetoothUUID.uuidString == correctUUIDShort, "Incorrect parse of short UUID's for Characteristic.")
        
        do {
            _ = try Characteristic(uuid: incorrectUUID)
        } catch let error {
            guard let error = error as? CBUUID.CreationError else {
                assertionFailure()
                return
            }
            assert(error == CBUUID.CreationError.invalidString, "Incorrect error returned when parsing wrong UUID.")
        }
    }
}
