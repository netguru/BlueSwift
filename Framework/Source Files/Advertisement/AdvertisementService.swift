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
    
    internal var readCallback: ((Data) -> (Void))?
    
    private var errorHandler: ((BluetoothError) -> (Void))?
    
    internal func startAdvertising(_ peripheral: Peripheral<Advertisable>, errorHandler: @escaping (BluetoothError) -> (Void)) {
        self.peripheral = peripheral
        self.errorHandler = errorHandler
        peripheralManager.startAdvertising(peripheral.advertisementData?.combined())
    }
    
    internal func updateValue(_ value: Data, characteristic: Characteristic, errorHandler: @escaping (BluetoothError.AdvertisementError) -> (Void)) {
        
    }
}

extension AdvertisementService: CBPeripheralManagerDelegate {
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        do {
            try peripheral.validateState()
            if !peripheralManager.isAdvertising {
                peripheralManager.startAdvertising(self.peripheral?.advertisementData?.combined())
            }
        } catch let error {
            guard let error = error as? BluetoothError else { return }
            errorHandler?(error)
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
