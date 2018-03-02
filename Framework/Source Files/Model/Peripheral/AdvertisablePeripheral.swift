//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import CoreBluetooth

public extension Peripheral where Type == Advertisable {
    
    public convenience init(configuration: Configuration, advertisementData: [AdvertisementData]) {
        self.init(configuration: configuration, advertisementData: advertisementData)
        
        
    }
    
    internal func createAdvertisementConfiguration() -> [CBMutableService] {
        let mutableServices = configuration.services.map { service -> CBMutableService in
            let rawService = CBMutableService(type: service.bluetoothUUID, primary: false)
            rawService.characteristics = service.characteristics.map {
                CBMutableCharacteristic(type: $0.bluetoothUUID, properties: .read, value: nil, permissions: .readable)
            }
            return rawService
        }
        return mutableServices
    }
}
