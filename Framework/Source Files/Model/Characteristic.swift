//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import CoreBluetooth

/// Struct wrapping Apple's native CBCharacteristic class. Used to create Configuration to connect with peripheral.
/// It presents a clear interface for interacting with characteristics providing notify property.
public class Characteristic {
    
    /// UUID of desired Characteristic.
    public let uuid: String
    
    /// A bool indicating if isNotifying value should be set on a characteristic upon discovery.
    public let isObservingValue: Bool
    
    /// A handler indicating characteristic value update events.
    public var notifyHandler: ((Data?) -> ())?
    
    /// Raw characteristics value filled after connection.
    internal var rawCharacteristic: CBCharacteristic?
    
    /// Raw mutable characteristic, assigned for advertisement needs.
    internal var advertisementCharacteristic: CBMutableCharacteristic?
    
    /// CBUUID parsed from passed UUID String.
    internal let bluetoothUUID: CBUUID
    
    /// Initializes a new instance of Characteristic. It's failable if passed UUID String is not parseable to UUID standards.
    ///
    /// - Parameters:
    ///     - uuid: UUID of desired service, should be parseable to CBUUID in order for the initializer to work.
    ///     - shouldObserveNotification: indicates if this characteristic should notify when it's value changes. Note that this will happen only when characteristic properties include Notify. False by default.
    /// - Throws: CBUUID.CreationError
    /// - SeeAlso: `CBUUID.CreationError`
    public init(uuid: String, shouldObserveNotification: Bool = false) throws {
        self.bluetoothUUID = try CBUUID(uuidString: uuid)
        self.uuid = uuid
        self.isObservingValue = shouldObserveNotification
    }
    
    /// Sets raw characteristic used for notifying purposes
    internal func setRawCharacteristic(_ characteristic: CBCharacteristic) {
        rawCharacteristic = characteristic
    }
}
