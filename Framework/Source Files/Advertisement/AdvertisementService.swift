//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import CoreBluetooth

/// Class implementing peripheral manager delegate. Manages advertisement state.
internal final class AdvertisementService: NSObject {
    
    /// Peripheral manager used for advertisement.
    /// - SeeAlso: `CBPeripheralManager`
    private lazy var peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    
    /// Boolean value indicating whether device should advertise.
    /// Used in Bluetooth state change handler to prevent unwanted advertisement.
    private var shouldAdvertise = false
    
    /// Currently advertising peripheral.
    private var peripheral: Peripheral<Advertisable>?
    
    /// After notify subscribtion, subscribed centrals are stored here.
    private var subsribedCentrals = [CBCentral]()
    
    /// Callback called after receiving read request.
    internal var readCallback: ((Characteristic) -> (Data))?
    
    /// Callback called after receiving write request.
    internal var writeCallback: ((Characteristic, Data?) -> ())?
    
    /// Callback called upon upcoming errors.
    private var errorHandler: ((AdvertisementError) -> ())?
    
    /// Starts advertising peripheral with given configuration of services and characteristics.
    internal func startAdvertising(_ peripheral: Peripheral<Advertisable>, errorHandler: ((AdvertisementError) -> ())?) {
        self.peripheral = peripheral
        self.errorHandler = errorHandler
        peripheralManager.startAdvertising(peripheral.advertisementData?.combined())
        shouldAdvertise = true
    }
    
    /// Stops advertising peripheral.
    internal func stopAdvertising() {
        peripheralManager.stopAdvertising()
        peripheral?.configuration.services
            .compactMap { $0.advertisementService }
            .forEach { peripheralManager.remove($0) }
        shouldAdvertise = false
    }
    
    /// Updates a value on given characteristic.
    internal func updateValue(_ value: Data, characteristic: Characteristic, errorHandler: ((AdvertisementError) -> ())?) {
        guard let advertisementCharacteristic = characteristic.advertisementCharacteristic else {
            errorHandler?(.deviceNotAdvertising)
            return
        }
        peripheralManager.updateValue(value, for: advertisementCharacteristic, onSubscribedCentrals: subsribedCentrals)
    }
}

extension AdvertisementService: CBPeripheralManagerDelegate {
    
    /// - SeeAlso: `CBPeripheralManagerDelegate`
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        do {
            try peripheral.validateState()
            if !peripheralManager.isAdvertising && shouldAdvertise {
                peripheralManager.startAdvertising(self.peripheral?.advertisementData?.combined())
            }
        } catch let error {
            guard let error = error as? BluetoothError else { return }
            errorHandler?(.bluetoothError(error))
        }
    }
    
    /// - SeeAlso: `CBPeripheralManagerDelegate`
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            errorHandler?(.otherError(error))
            return
        }
        self.peripheral?.configuration.services.map({ $0.assignAdvertisementService() }).forEach(peripheralManager.add(_:))
    }
    
    /// - SeeAlso: `CBPeripheralManagerDelegate`
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if let error = error {
            errorHandler?(.otherError(error))
        }
    }

    /// - SeeAlso: `CBPeripheralManagerDelegate`
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        let rawCharacteristic = request.characteristic
        guard let characteristic = self.peripheral?.configuration.characteristic(matching: rawCharacteristic) else { return }
        guard let data = readCallback?(characteristic) else { return }
        request.value = data
        peripheral.respond(to: request, withResult: .success)
    }
    
    /// - SeeAlso: `CBPeripheralManagerDelegate`
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        requests.forEach { request in
            let rawCharacteristic = request.characteristic
            guard let characteristic = self.peripheral?.configuration.characteristic(matching: rawCharacteristic) else { return }
            writeCallback?(characteristic, request.value)
            peripheral.respond(to: request, withResult: .success)
        }
    }
    
    /// - SeeAlso: `CBPeripheralManagerDelegate`
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        subsribedCentrals.append(central)
    }
    
    /// - SeeAlso: `CBPeripheralManagerDelegate`
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        guard let index = subsribedCentrals.index(where: { $0 === central }) else { return }
        subsribedCentrals.remove(at: index)
    }
}
