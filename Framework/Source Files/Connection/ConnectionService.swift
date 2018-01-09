//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import CoreBluetooth

/// Wrapper around native Apple CentralManager API
internal class ConnectionService: NSObject {
    
    internal var advertisementValidationHandler: ((Peripheral, String, [String: Any]) -> (Bool))?
    
    /// CBCentralManager instance. Allows peripheral connection
    private lazy var centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)

    /// Connection options - means you will be notified on connection and disconnection of devices.
    private lazy var connectionOptions = [CBConnectPeripheralOptionNotifyOnConnectionKey: true,
                                          CBConnectPeripheralOptionNotifyOnDisconnectionKey: true]
    
    /// Scanning options. Means that one device can be discovered multiple times without connecting.
    private lazy var scanningOptions = [CBCentralManagerScanOptionAllowDuplicatesKey : true]
    
    /// Set of advertisement UUID central manager should scan for.
    private var scanParameters : Set<CBUUID> = Set()

    /// Set of peripherals the manager should connect.
    private var peripherals = [Peripheral]()
    
    private var connectionHandler: ((Peripheral, Bool, BluetoothConnection.ConnectionError) -> ())?
    
    private weak var connectingPeripheral: Peripheral?
}

internal extension ConnectionService {
    
    internal func connect(_ peripheral: Peripheral, handler: @escaping (Bool, BluetoothConnection.ConnectionError?) -> ()) {
        peripherals.append(peripheral)
        scanParameters.insert(peripheral.configuration.advertisementUUID)
    }
    
    private func reloadScanning() {
        if centralManager.isScanning {
            centralManager.stopScan()
        }
        centralManager.scanForPeripherals(withServices: Array(scanParameters), options: scanningOptions)
    }
}

extension ConnectionService: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOff, .resetting, .unauthorized:
            break
        case .poweredOn:
            break
        case .unsupported, .unknown:
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let handler = advertisementValidationHandler,
            let matchingPeripheral = peripherals.filter({ $0.configuration.matches(advertisement: advertisementData) }).first,
            !handler(matchingPeripheral, peripheral.identifier.uuidString, advertisementData),
            connectingPeripheral == nil
            else {
                return
        }
        connectingPeripheral = matchingPeripheral
        centralManager.connect(peripheral, options: connectionOptions)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(connectingPeripheral?.configuration.services.map({ $0.bluetoothUUID }))
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        central.connect(peripheral, options: connectionOptions)
    }
}

extension ConnectionService: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        centralManager.connect(peripheral, options: connectionOptions)
    }
}
