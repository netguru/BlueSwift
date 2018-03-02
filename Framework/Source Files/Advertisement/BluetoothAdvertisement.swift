//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

public final class BluetoothAdvertisement {
    
    private lazy var advertisementService = AdvertisementService()
    
    public func advertise(peripheral: Peripheral<Advertisable>, errorHandler: @escaping (BluetoothError) -> (Void)) {
        advertisementService.startAdvertising(peripheral, errorHandler: errorHandler)
    }
    
    public func updateValue(for characteristic: Characteristic) {
        
    }
    
    public var readCallback: ((Data) -> (Void))? {
        didSet {
            advertisementService.readCallback = readCallback
        }
    }
}
