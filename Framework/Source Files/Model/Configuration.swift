//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import CoreBluetooth

/// Configuration struct is used to create a complete representation of peripheral's services and characteristics.
/// Use to initialize Perpiheral class.
public struct Configuration {

    /// An array of services contained in configuration.
    public let services: [Service]
    
    /// Advertised UUID from initializer parsed to a CBUUID instance.
    internal let advertisementUUID: CBUUID
    
    /// Creates a new instance of configuration containing Services desired peripheral should contain.
    /// Used to initialize a Peripheral instance.
    ///
    /// - Parameters:
    ///     - services: An array of Services wished to use.
    ///     - advertisement: UUID of desired peripheral that is specified in advertisement header.
    /// - Throws: CBUUID.CreationError
    /// - SeeAlso: `CBUUID.CreationError`
    public init(services: [Service], advertisement: String) throws {
        advertisementUUID = try CBUUID(uuidString: advertisement)
        self.services = services
    }
}

internal extension Configuration {
    
    /// Helper method to check peripheral advertisement against one passed in conifguration.
    internal func matches(advertisement: [String: Any]) -> Bool {
        guard let uuids = advertisement[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] else { return false }
        for uuid in uuids {
            if uuid.uuidString.uppercased() == advertisementUUID.uuidString.uppercased() { return true }
        }
        return false
    }
    
    /// Helper method used to search characteristics wrapper for specified CBCharacteristic
    internal func characteristic(matching cbCharacteristic: CBCharacteristic) -> Characteristic? {
        let characteristics = services.flatMap { $0.characteristics }
        return characteristics.filter { $0.bluetoothUUID.uuidString == cbCharacteristic.uuid.uuidString }.first
    }
}

