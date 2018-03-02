//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import CoreBluetooth

internal final class AdvertisementService: NSObject {
    
    private lazy var peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    
    private var peripheral: Peripheral<Advertisable>?
    
    private var subsribedCentrals = [CBCentral]()
    
    internal func startAdvertising(_ peripheral: Peripheral<Advertisable>) {
        self.peripheral = peripheral
        peripheralManager.startAdvertising(peripheral.advertisementData?.data)
    }
}

extension AdvertisementService: CBPeripheralManagerDelegate {
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        do {
            try peripheral.validateState()
            if !peripheralManager.isAdvertising {
                peripheralManager.startAdvertising(self.peripheral?.advertisementData?.data)
            }
        } catch {
            print("Error in peripheral manager state.")
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        
    }
}
