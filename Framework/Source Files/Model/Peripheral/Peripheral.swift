//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import CoreBluetooth

/// A phantom type protocol making it easier to distinguish peripherals.
public protocol PeripheralType {}

/// A phantom type enums allowing to distinguish between Peripheral used for connection and advertisement.
public enum Connectable: PeripheralType {}
public enum Advertisable: PeripheralType {}

/// Class wrapping native Apple's CBPeripheral class. Should be passed as connection parameter and initialized with a
/// Configuration. It presents a clear interface for writing and reading interactions with remote peripherals adding closure reponses.
public final class Peripheral<Type: PeripheralType>: NSObject, CBPeripheralDelegate {
    
    /// List of errors possible to happen upon a write or read request.
    public enum TransmissionError: Error {
        case invalidCharacteristicPermissions(CBCharacteristicProperties)
        case characteristicNotDiscovered
        case deviceNotConnected
        case incorrectInputFormat(Command.ConversionError)
        case auxiliaryError(Error)
    }
    
    public override init() {
        fatalError("Init is unavailable, please use init(configuration:deviceIdentifier:) instead.")
    }
    
    internal init(configuration: Configuration, deviceIdentifier: String? = nil, advertisementData: [AdvertisementData]? = nil) {
        self.configuration = configuration
        self.deviceIdentifier = deviceIdentifier
        self.advertisementData = advertisementData
    }
    
    /// Configuration of services and characteristics desired peripheral should contain.
    public let configuration: Configuration
    
    /// A device parameter. Should be cached locally in order to pass for every connection after the first one.
    /// If passed, every connection should happen much quicker.
    public var deviceIdentifier: String?
    
    internal var advertisementData: [AdvertisementData]?
    
    /// Private instance of Apple native peripheral class. Used to manage write and read requests.
    internal var peripheral: CBPeripheral? {
        didSet {
            peripheral?.delegate = self
        }
    }
    
    /// Private variable for storing reference to write completion callback.
    internal var writeHandler: ((TransmissionError?) -> ())?
    
    /// Private variable for storing reference to read completion callback.
    internal var readHandler: ((Data?, TransmissionError?) -> ())?
}
