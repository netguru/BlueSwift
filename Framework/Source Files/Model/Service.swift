//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import CoreBluetooth

/// Struct wrapping Apple's native CBService class. Used to create Configuration for this framework.
public class Service {
    
    /// UUID of desired service.
    public let uuid: String
    
    /// A set of characteristics this service should contain.
    public let characteristics: [Characteristic]
    
    /// CBUUID parsed from passed UUID String.
    internal let bluetoothUUID: CBUUID
    
    /// Mutable characteristic used for advertisement.
    internal var advertisementService: CBMutableService?
    
    /// Initializes a new instance of Service. It's failable if passed UUID String is not parseable to UUID standards.
    ///
    /// - Parameters:
    ///     - uuid: UUID of desired service, should be parseable to CBUUID in order for the initializer to work.
    ///     - characteristics: a list of Characteristic desired Service should contain. Please note that this list does not have to be exhaustive and contain all characteristics desired service contains on the peripheral. Pass only ones
    /// you wish to use.
    /// - Throws: CBUUID.CreationError
    /// - SeeAlso: `CBUUID.CreationError`
    public init(uuid: String, characteristics: [Characteristic]) throws {
        self.bluetoothUUID = try CBUUID(uuidString: uuid)
        self.uuid = uuid
        self.characteristics = characteristics
    }
}

internal extension Service {
    
    /// Creates CBMutableService used for advertisement and assigns it to the local variable.
    internal func assignAdvertisementService() -> CBMutableService {
        let service = CBMutableService(type: bluetoothUUID, primary: true)
        var cbCharacteristics = [CBMutableCharacteristic]()
        characteristics.forEach { characteristic in
            let cbCharacteristc = CBMutableCharacteristic(type: characteristic.bluetoothUUID, properties: [.read, .write, .notify], value: nil, permissions: [.readable, .writeable])
            cbCharacteristics.append(cbCharacteristc)
            characteristic.advertisementCharacteristic = cbCharacteristc
        }
        service.characteristics = cbCharacteristics
        advertisementService = service
        return service
    }
}
