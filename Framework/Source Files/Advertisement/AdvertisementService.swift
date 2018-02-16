//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import CoreBluetooth

internal final class AdvertisementService: NSObject {
    
    private lazy var peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
}

extension AdvertisementService: CBPeripheralManagerDelegate {
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
    }
}
