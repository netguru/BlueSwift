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
    
    /// Called after reading data from characteristic.
    /// - SeeAlso: `CBPeripheralDelegate`
    /// This should be moved to an extension in Swift 5 according to: https://github.com/apple/swift-evolution/blob/master/proposals/0143-conditional-conformances.md feature.
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        defer {
            writeHandler = nil
        }
        guard let handler = writeHandler else { return }
        guard let error = error else {
            handler(nil)
            return
        }
        handler(.auxiliaryError(error))
    }
    
    /// Called in two cases:
    /// 1) After performing read request from peripheral.
    /// 2) After peripheral updates value for characteristic with notify turned on.
    /// - SeeAlso: `CBPeripheralDelegate`
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        defer {
            readHandler = nil
        }
        // It's assumed that if someone performed a read request, we'll ignore calling a notification for this value.
        guard let handler = readHandler, error == nil else {
            let wrapped = configuration.characteristic(matching: characteristic)
            wrapped?.notifyHandler?(characteristic.value)
            return
        }
        guard let error = error else {
            handler(characteristic.value, nil)
            return
        }
        handler(nil, .auxiliaryError(error))
    }
}
