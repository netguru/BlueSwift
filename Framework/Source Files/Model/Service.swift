//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import CoreBluetooth.CBUUID

/// Struct wrapping Apple's native CBService class. Used to create Configuration for this framework.
public struct Service {
    
    /// UUID of desired service.
    public let uuid: String
    
    /// A set of characteristics this service should contain.
    public let characteristics: [Characteristic]
    
    /// CBUUID parsed from passed UUID String.
    internal let bluetoothUUID: CBUUID
    
    /// Initializes a new instance of Service. It's failable if passed UUID String is not parseable to UUID standards.
    /// - Parameter uuid: UUID of desired service, should be parseable to CBUUID in order for the initializer to work.
    /// - Parameter characteristics: a list of Characteristic desired Service should contain. Please note that this list does not
    /// have to be exhaustive and contain all characteristics desired service contains on the peripheral. Pass only ones
    /// you wish to use.
    /// - Throws: CBUUID.CreationError
    /// - SeeAlso: CBUUID.CreationError
    public init(uuid: String, characteristics: [Characteristic]) throws {
        self.bluetoothUUID = try CBUUID(uuidString: uuid)
        self.uuid = uuid
        self.characteristics = characteristics
    }
}
