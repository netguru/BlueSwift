//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

public final class BluetoothAdvertisement {
    
    /// Advertisement service.
    /// SeeAlso: AdvertisementService
    private lazy var advertisementService = AdvertisementService()
    
    /// A singleton instance.
    public static let shared = BluetoothAdvertisement()
    
    /// Default initializer
    public init() { }
    
    /// Start advertising peripheral with parameters given by a configuration of passed peripheral.
    /// Parameter peripheral:
    /// Parameter errorHandler:
    /// SeeAlso: AdvertisementError
    public func advertise(peripheral: Peripheral<Advertisable>, errorHandler: @escaping (AdvertisementError) -> ()) {
        advertisementService.startAdvertising(peripheral, errorHandler: errorHandler)
    }
    
    public func updateValue(_ value: Data, characteristic: Characteristic, errorHandler: @escaping (AdvertisementError) -> (Void)) {
        advertisementService.updateValue(value, characteristic: characteristic, errorHandler: errorHandler)
    }
    
    public var writeRequestCallback: ((Characteristic, Data?) -> ())? {
        didSet {
            advertisementService.writeCallback = writeRequestCallback
        }
    }
    
    public var readRequestCallback: ((Characteristic) -> (Data))? {
        didSet {
            advertisementService.readCallback = readRequestCallback
        }
    }
}
