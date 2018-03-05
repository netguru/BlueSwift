//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// A public facing class used to setup device as an advertising Bluetooth peripheral.
public final class BluetoothAdvertisement {
    
    /// Advertisement service.
    /// SeeAlso: AdvertisementService
    private lazy var advertisementService = AdvertisementService()
    
    /// A singleton instance.
    public static let shared = BluetoothAdvertisement()
    
    /// Default initializer
    public init() { }
    
    /// Start advertising peripheral with parameters given by a configuration of passed peripheral.
    /// Parameter peripheral: a peripheral containing configuration with specified services and characteristics.
    /// Parameter errorHandler: an error handler. Will be called only after unsuccesfull advertisement setup.
    /// SeeAlso: AdvertisementError
    /// SeeAlso: Peripheral
    public func advertise(peripheral: Peripheral<Advertisable>, errorHandler: @escaping (AdvertisementError) -> ()) {
        advertisementService.startAdvertising(peripheral, errorHandler: errorHandler)
    }
    
    /// Updates a value for specified characteristic with data.
    /// After the reuest a notify will be called on all subscribed centrals.
    /// Parameter value: a data to update on characteristic.
    /// Parameter characteristic: specified characteristic to be updated.
    /// Parameter errorHandler: an error handler called if data update fails.
    /// SeeAlso: AdvertisementError
    /// SeeAlso: Characteristic
    public func updateValue(_ value: Data, characteristic: Characteristic, errorHandler: @escaping (AdvertisementError) -> (Void)) {
        advertisementService.updateValue(value, characteristic: characteristic, errorHandler: errorHandler)
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
