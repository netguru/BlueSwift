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
    
    internal var readCallback: ((Characteristic) -> (Data))?
    
    internal var writeCallback: ((Characteristic, Data?) -> ())?
    
    private var errorHandler: ((BluetoothError) -> ())?
    
    internal func startAdvertising(_ peripheral: Peripheral<Advertisable>, errorHandler: @escaping (BluetoothError) -> ()) {
        self.peripheral = peripheral
        self.errorHandler = errorHandler
        peripheralManager.startAdvertising(peripheral.advertisementData?.combined())
    }
    
    internal func updateValue(_ value: Data, characteristic: Characteristic, errorHandler: @escaping (BluetoothError.AdvertisementError) -> ()) {
        guard let advertisementCharacteristic = characteristic.advertisementCharacteristic else {
            errorHandler(.deviceNotAdvertising)
            return
        }
        peripheralManager.updateValue(value, for: advertisementCharacteristic, onSubscribedCentrals: subsribedCentrals)
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
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        let rawCharacteristic = request.characteristic
        guard let characteristic = self.peripheral?.configuration.characteristic(matching: rawCharacteristic) else { return }
        let data = readCallback?(characteristic)
        request.value = data
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        requests.forEach { request in
            let rawCharacteristic = request.characteristic
            guard let characteristic = self.peripheral?.configuration.characteristic(matching: rawCharacteristic) else { return }
            writeCallback?(characteristic, request.value)
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        subsribedCentrals.append(central)
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        guard let index = subsribedCentrals.index(where: { $0 === central }) else { return }
        subsribedCentrals.remove(at: index)
    }
}
