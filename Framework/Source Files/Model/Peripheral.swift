//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import CoreBluetooth

/// Class wrapping native Apple's CBPeripheral class. Should be passed as connection parameter and initialized with a Configuration.
/// It presents a clear interface for writing and reading interactions with remote peripherals adding closure reponses.
public final class Peripheral {
    
    /// Configuration of services and characteristics desired peripheral should contain.
    public let configuration: Configuration
    
    /// A device parameter. Should be cached locally in order to pass for every connection after the first one.
    /// If passed, every connection should happen much quicker.
    public var deviceIdentifier: String?
    
    /// Indicates if device is currently connected.
    public var isConnected: Bool {
        guard let peripheral = peripheral else { return false }
        return peripheral.state == .connected
    }
    
    /// Deafult initializer for Perpipheral.
    /// - Parameter configuration: proviously created configuration containing all desired services and characteristics.
    /// - Parameter deviceIdentifier: optional parameter. If device identifier is cached locally than it should be passed here.
    ///   When set, connection to peripheral is much quicker.
    public init(configuration: Configuration, deviceIdentifier: String? = nil) {
        self.configuration = configuration
        self.deviceIdentifier = deviceIdentifier
    }
    
    /// Private instance of Apple native peripheral class. Used to manage write and read requests.
    internal var peripheral: CBPeripheral?
}
