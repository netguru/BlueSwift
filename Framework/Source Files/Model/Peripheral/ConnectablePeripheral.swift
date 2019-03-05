//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import CoreBluetooth

public extension Peripheral where Type == Connectable {
    
    /// Enum for distinguishing which transmission action was taken.
    private enum TransmissionAction {
        case read, write
    }
    
    /// Deafult initializer for Perpipheral.
    ///
    /// - Parameters:
    ///     - configuration: previously created configuration containing all desired services and characteristics.
    ///     - deviceIdentifier: optional parameter. If device identifier is cached locally then it should be passed here. When set, connection to peripheral is much quicker.
    /// - SeeAlso: `Configuration`
    public convenience init(configuration: Configuration, deviceIdentifier: String? = nil) {
        self.init(configuration: configuration, deviceIdentifier: deviceIdentifier, advertisementData: nil)
    }
    
    /// Indicates if device is currently connected.
    public var isConnected: Bool {
        guard let peripheral = peripheral else { return false }
        return peripheral.state == .connected
    }
    
    /// Method used for writing to the peripheral after it's connected.
    ///
    /// - Parameters:
    ///     - command: a command to write to the device.
    ///     - characteristic: a characteristic the command should be directed to.
    ///     - handler: a completion handler indicating if reuqest was successfull.
    ///     - type: type of write request
    /// - SeeAlso: `Command`
    /// - SeeAlso: `Characteristic`
    /// - SeeAlso: `CBCharacteristicWriteType`
    /// - SeeAlso: `Peripheral.TransmissionError`
    public func write(command: Command, characteristic: Characteristic, type: CBCharacteristicWriteType = .withResponse, handler: ((TransmissionError?) -> ())?) {
        do {
            let unwrapped = try validateForTransmission(characteristic, action: .write)
            writeHandler = handler
            try peripheral?.writeValue(command.convertedData(), for: unwrapped, type: type)
        } catch let error {
            guard let conversionError = error as? Command.ConversionError else {
                handler?(error as? TransmissionError)
                return
            }
            handler?(TransmissionError.incorrectInputFormat(conversionError))
        }
    }
    
    /// Method used to perform read request from peripheral after it's connected.
    ///
    /// - Parameters:
    ///     - characteristic: a characteristic you wish to read.
    ///     - handler: completion handler returning Data retrieved from characteristic or error if it failed.
    /// - SeeAlso: `Characteristic`
    /// - SeeAlso: `Peripheral.TransmissionError`
    public func read(_ characteristic: Characteristic, handler: ((Data?, TransmissionError?) -> ())?) {
        do {
            let unwrapped = try validateForTransmission(characteristic, action: .read)
            readHandler = handler
            peripheral?.readValue(for: unwrapped)
        } catch let error {
            handler?(nil, error as? TransmissionError)
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
        if action == .read && characteristic.validateForRead() {
            throw TransmissionError.invalidCharacteristicPermissions(characteristic.properties)
        }
        if action == .write && characteristic.validateForWrite() {
            throw TransmissionError.invalidCharacteristicPermissions(characteristic.properties)
        }
        return characteristic
    }
}
