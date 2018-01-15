//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import CoreBluetooth

/// Class wrapping native Apple's CBPeripheral class. Should be passed as connection parameter and initialized with a
/// Configuration. It presents a clear interface for writing and reading interactions with remote peripherals adding closure reponses.
public final class Peripheral: NSObject {
    
    /// List of errors possible to happen upon a write request.
    public enum WriteError: Error {
        case characteristicNotWriteable
        case characteristicNotDiscovered
        case deviceNotConnected
        case writeError(Error)
    }
    
    /// List of errors possible to happen upon a read request.
    public enum ReadError: Error {
        case characteristicNotDiscovered
        case characteristicNotReadable
        case deviceNotConnected
        case readError(Error)
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
    
    /// Private variable for storing reference to write completion callback.
    private var writeHandler: ((WriteError?) -> ())?
    
    /// Private variable for storing reference to read completion callback.
    private var readHandler: ((Data?, ReadError?) -> ())?
}

public extension Peripheral {
    
    /// Method used for writing to the peripheral after it's connected.
    /// - Parameter command: a command to write to the device.
    /// - Parameter characteristic: a characteristic the command should be directed to.
    /// - Parameter handler: a completion handler indicating if reuqest was succesfull.
    /// - SeeAlso: Command
    /// - SeeAlso: Characteristic
    /// - SeeAlso: Peripheral.WriteError
    public func write(command: Command, characteristic: Characteristic, handler: @escaping (WriteError?) -> ()) {
        writeHandler = handler
        guard isConnected else {
            handler(.deviceNotConnected)
            return
        }
        guard let characteristic = characteristic.rawCharacteristic else {
            handler(.characteristicNotDiscovered)
            return
        }
        guard characteristic.validateForWrite() else {
            handler(.characteristicNotWriteable)
            return
        }
        peripheral?.writeValue(command.data, for: characteristic, type: .withResponse)
    }
    
    /// Method used to perform read request from peripheral after it's connected.
    /// - Parameter characteristic: a characteristic you wish to read.
    /// - Parameter handler: completion handler returning Data retrieved from characteristic or error if it failed.
    /// - SeeAlso: Characteristic
    /// - SeeAlso: Peripheral.ReadError
    public func read(_ characteristic: Characteristic, handler: @escaping (Data?, ReadError?) -> ()) {
        readHandler = handler
        guard isConnected else {
            handler(nil, .deviceNotConnected)
            return
        }
        guard let characteristic = characteristic.rawCharacteristic else {
            handler(nil, .characteristicNotDiscovered)
            return
        }
        guard characteristic.validateForRead() else {
            handler(nil, .characteristicNotReadable)
            return
        }
        peripheral?.readValue(for: characteristic)
    }
}

extension Peripheral: CBPeripheralDelegate {
    
    /// Called after reading data from characteristic.
    /// - SeeAlso: CBPeripheralDelegate
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let handler = writeHandler else { return }
        guard let error = error else {
            handler(nil)
            return
        }
        handler(.writeError(error))
    }
    
    /// Called in two cases:
    /// 1) After performing read request from peripheral.
    /// 2) After peripheral updates value for characteristic with notify turned on.
    /// - SeeAlso: CBPeripheralDelegate
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // It's assumed that if someone performed a read request, we'll ignore calling a notification for this value.
        if let handler = readHandler {
            handler(characteristic.value, nil)
            return
        }
        let wrapped = configuration.characteristic(matching: characteristic)
        if let notifyHandler = wrapped?.notifyHandler {
            notifyHandler(characteristic.value)
        }
    }
}
