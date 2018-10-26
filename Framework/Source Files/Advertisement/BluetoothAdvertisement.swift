//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// A public facing class used to setup device as an advertising Bluetooth peripheral.
public final class BluetoothAdvertisement {
    
    /// Advertisement service.
    /// - SeeAlso: `AdvertisementService`
    private lazy var advertisementService = AdvertisementService()
    
    /// A singleton instance.
    public static let shared = BluetoothAdvertisement()
    
    /// Default initializer
    public init() { }
    
    /// Start advertising peripheral with parameters given by a configuration of passed peripheral.
    ///
    /// - Parameters:
    ///     - peripheral: a peripheral containing configuration with specified services and characteristics.
    ///     - errorHandler: an error handler. Will be called only after unsuccessfull advertisement setup.
    /// - SeeAlso: `AdvertisementError`
    /// - SeeAlso: `Peripheral`
    public func advertise(peripheral: Peripheral<Advertisable>, errorHandler: ((AdvertisementError) -> ())?) {
        advertisementService.startAdvertising(peripheral, errorHandler: errorHandler)
    }
    
    /// Stops advertising peripheral.
    public func stopAdvertising() {
        advertisementService.stopAdvertising()
    }
    
    /// Updates a value for specified characteristic with data.
    /// After the request a notify will be called on all subscribed centrals.
    ///
    /// - Parameters:
    ///     - command: a comand to update on characteristic.
    ///     - characteristic: specified characteristic to be updated.
    ///     - errorHandler: an error handler called if data update fails.
    /// - SeeAlso: `AdvertisementError`
    /// - SeeAlso: `Characteristic`
    public func update(_ command: Command, characteristic: Characteristic, errorHandler: @escaping (AdvertisementError) -> (Void)) {
        do {
            try advertisementService.updateValue(command.convertedData(), characteristic: characteristic, errorHandler: errorHandler)
        } catch {
            errorHandler(.incorrectUpdateData)
        }
    }
    
    /// Caled when a connected central submits a write reuqest to a specified characteristic.
    public var writeRequestCallback: ((Characteristic, Data?) -> ())? {
        didSet {
            advertisementService.writeCallback = writeRequestCallback
        }
    }
    
    /// Called when a connected central submits a read request to a specified characteristic.
    public var readRequestCallback: ((Characteristic) -> (Data))? {
        didSet {
            advertisementService.readCallback = readRequestCallback
        }
    }
}
