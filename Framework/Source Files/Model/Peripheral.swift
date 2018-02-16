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
public final class Peripheral<Type: PeripheralType>: NSObject {

    /// List of errors possible to happen upon a write or read request.
    public enum TransmissionError: Error {
        case invalidCharacteristicPermissions(CBCharacteristicProperties)
        case characteristicNotDiscovered
        case deviceNotConnected
        case incorrectInputFormat(Command.ConversionError)
        case auxiliaryError(Error)
    }
    
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
    /// - SeeAlso: Configuration
    public init(configuration: Configuration, deviceIdentifier: String? = nil) {
        self.configuration = configuration
        self.deviceIdentifier = deviceIdentifier
    }
    
    /// Private instance of Apple native peripheral class. Used to manage write and read requests.
    internal var peripheral: CBPeripheral? {
        didSet {
            peripheral?.delegate = self
        }
    }

    /// Enum for distinguishing which transmission action was taken.
    private enum TransmissionAction {
        case read, write
    }
    
    /// Private variable for storing reference to write completion callback.
    private var writeHandler: ((TransmissionError?) -> ())?
    
    /// Private variable for storing reference to read completion callback.
    private var readHandler: ((Data?, TransmissionError?) -> ())?
}

public extension Peripheral where Type == Connectable {
    
}

public extension Peripheral where Type == Advertisable {
    
}

public extension Peripheral {
    
    /// Method used for writing to the peripheral after it's connected.
    /// - Parameter command: a command to write to the device.
    /// - Parameter characteristic: a characteristic the command should be directed to.
    /// - Parameter handler: a completion handler indicating if reuqest was succesfull.
    /// - SeeAlso: Command
    /// - SeeAlso: Characteristic
    /// - SeeAlso: Peripheral.TransmissionError
    public func write(command: Command, characteristic: Characteristic, handler: @escaping (TransmissionError?) -> ()) {
        do {
            let unwrapped = try validateForTransmission(characteristic, action: .write)
            try peripheral?.writeValue(command.convertedData(), for: unwrapped, type: .withResponse)
            writeHandler = handler
        } catch let error {
            guard let conversionError = error as? Command.ConversionError else {
                handler(error as? TransmissionError)
                return
            }
            handler(TransmissionError.incorrectInputFormat(conversionError))
        }
    }
    
    /// Method used to perform read request from peripheral after it's connected.
    /// - Parameter characteristic: a characteristic you wish to read.
    /// - Parameter handler: completion handler returning Data retrieved from characteristic or error if it failed.
    /// - SeeAlso: Characteristic
    /// - SeeAlso: Peripheral.TransmissionError
    public func read(_ characteristic: Characteristic, handler: @escaping (Data?, TransmissionError?) -> ()) {
        do {
            let unwrapped = try validateForTransmission(characteristic, action: .read)
            peripheral?.readValue(for: unwrapped)
            readHandler = handler
        } catch let error {
            handler(nil, error as? TransmissionError)
        }
    }
    
    /// Performs a general validation if write or read requests can be performed on specified characteristic.
    private func validateForTransmission(_ characteristic: Characteristic, action: TransmissionAction) throws -> CBCharacteristic {
        guard isConnected else {
            throw TransmissionError.deviceNotConnected
        }
        guard let characteristic = characteristic.rawCharacteristic else {
            throw TransmissionError.characteristicNotDiscovered
        }
        guard characteristic.validateForRead() && action == .read else {
            throw TransmissionError.invalidCharacteristicPermissions(characteristic.properties)
        }
        guard characteristic.validateForWrite() && action == .write else {
            throw TransmissionError.invalidCharacteristicPermissions(characteristic.properties)
        }
        return characteristic
    }
}

extension Peripheral: CBPeripheralDelegate {
    
    /// Called after reading data from characteristic.
    /// - SeeAlso: CBPeripheralDelegate
    @nonobjc public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
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
    /// - SeeAlso: CBPeripheralDelegate
    @nonobjc public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        defer {
            readHandler = nil
        }
        // It's assumed that if someone performed a read request, we'll ignore calling a notification for this value.
        guard let handler = readHandler, error != nil else {
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
