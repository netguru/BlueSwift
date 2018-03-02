//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

public final class BluetoothAdvertisement {
    
    private lazy var advertisementService = AdvertisementService()
    
    public static let shared = BluetoothAdvertisement()
    
    public init() { }
    
    public func advertise(peripheral: Peripheral<Advertisable>, errorHandler: @escaping (BluetoothError) -> ()) {
        advertisementService.startAdvertising(peripheral, errorHandler: errorHandler)
    }
    
    public func updateValue(_ value: Data, characteristic: Characteristic, errorHandler: @escaping (BluetoothError.AdvertisementError) -> (Void)) {
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
