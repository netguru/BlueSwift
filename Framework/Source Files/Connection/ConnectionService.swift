//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import CoreBluetooth

/// A wrapper around CoreBluetooth delegate stack.
internal final class ConnectionService: NSObject {
    
    /// Closure used to check given peripheral against advertisement packet of discovered peripheral.
    internal var advertisementValidationHandler: ((Peripheral<Connectable>, String, [String: Any]) -> (Bool))? = { _,_,_ in return true }

    /// Closure used to manage connection success or failure.
    internal var connectionHandler: ((Peripheral<Connectable>, ConnectionError?) -> ())?
    
    /// Returns the amount of devices already scheduled for connection.
    internal var connectedDevicesAmount: Int {
        return peripherals.count
    }
    
    /// Set of peripherals the manager should connect.
    private var peripherals = [Peripheral<Connectable>]()
    
    private weak var connectingPeripheral: Peripheral<Connectable>?
    
    /// Connection options - means you will be notified on connection and disconnection of devices.
    private lazy var connectionOptions = [CBConnectPeripheralOptionNotifyOnConnectionKey: true,
                                           CBConnectPeripheralOptionNotifyOnDisconnectionKey: true]
    
    /// Scanning options. Means that one device can be discovered multiple times without connecting.
    private lazy var scanningOptions = [CBCentralManagerScanOptionAllowDuplicatesKey : true]
    
    /// CBCentralManager instance. Allows peripheral connection.
    private lazy var centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main, options: nil)
    
    /// Set of advertisement UUID central manager should scan for.
    private var scanParameters: Set<CBUUID> = Set()
}

extension ConnectionService {
    
    /// Starts connection with passed device. Connection result is passed in handler closure.
    internal func connect(_ peripheral: Peripheral<Connectable>, handler: @escaping (Peripheral<Connectable>, ConnectionError?) -> ()) {
        if connectionHandler == nil {
            connectionHandler = handler
        }
        peripherals.append(peripheral)
        reloadScanning()
    }
    
    /// Disconnects given device.
    internal func disconnect(_ peripheral: CBPeripheral) {
        if let index = peripherals.index(where: { $0.peripheral === peripheral }) {
            peripherals.remove(at: index)
        }
        centralManager.cancelPeripheralConnection(peripheral)
    }
}

private extension ConnectionService {
    
    /// Reloads scanning if necessary. Adding scan parameters should be ommited in case of possible peripheral retrive.
    /// In that case connection is available without previous scanning.
    private func reloadScanning() {
        if centralManager.isScanning {
            centralManager.stopScan()
        }
        performDeviceAutoReconnection()
        let params = peripherals.compactMap { (peripheral) -> CBUUID? in
            guard peripheral.peripheral == nil else { return nil }
            return peripheral.configuration.advertisementUUID
        }
        guard params.count != 0 else {
            return
        }
        scanParameters = Set(params)
        centralManager.scanForPeripherals(withServices: Array(scanParameters), options: scanningOptions)
    }
    
    /// Tries a peripeheral retrieve for each peripheral model. Peripheral can be retrieved in case the parameter of
    /// deviceIdentifier was passed during initialization. If it's correctly retrieved, scanning is unnecessary and peripheral
    /// can be directly connected.
    private func performDeviceAutoReconnection() {
        let identifiers = peripherals.compactMap { UUID(uuidString: $0.deviceIdentifier ?? "") }
        guard !identifiers.isEmpty else { return }
        let retrievedPeripherals = centralManager.retrievePeripherals(withIdentifiers: identifiers)
        let matching = peripherals.matchingElementsWith(retrievedPeripherals)
        matching.forEach { (peripheral, cbPeripheral) in
            peripheral.peripheral = cbPeripheral
            centralManager.connect(cbPeripheral, options: connectionOptions)
        }
    }
}

extension ConnectionService: CBCentralManagerDelegate {
    
    /// Determines Bluetooth sensor state for current device.
    /// - SeeAlso: CBCentralManagerDelegate
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard let handler = connectionHandler, let anyDevice = peripherals.first else { return }
        do {
            try central.validateState()
            reloadScanning()
        } catch let error {
            if let error = error as? BluetoothError {
                handler(anyDevice, .bluetoothError(error))
            }
        }
    }
    
    /// Called when a peripheral with desired advertised service is discovered.
    /// - SeeAlso: CBCentralManagerDelegate
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let devices = peripherals.filter({ $0.configuration.matches(advertisement: advertisementData)})
        guard let handler = advertisementValidationHandler,
            let matchingPeripheral = devices.filter({ $0.peripheral == nil }).first,
            handler(matchingPeripheral, peripheral.identifier.uuidString, advertisementData),
            connectingPeripheral == nil
            else {
                return
        }
        connectingPeripheral = matchingPeripheral
        connectingPeripheral?.peripheral = peripheral
        central.connect(peripheral, options: connectionOptions)
    }
    
    /// Called upon a successfull peripheral connection.
    /// - SeeAlso: CBCentralManagerDelegate
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        guard let connectingPeripheral = peripherals.filter({ $0.peripheral === peripheral }).first else { return }
        self.connectingPeripheral = connectingPeripheral
        connectingPeripheral.peripheral = peripheral
        peripheral.delegate = self
        peripheral.discoverServices(connectingPeripheral.configuration.services.map({ $0.bluetoothUUID }))
    }
    
    /// Called when peripheral connection fails on its initialization, we'll reconnect it right away.
    /// - SeeAlso: CBCentralManagerDelegate
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        central.connect(peripheral, options: connectionOptions)
    }
}

extension ConnectionService: CBPeripheralDelegate {
    
    /// Called upon discovery of services of a connected peripheral. Used to map model services to passed configuration and
    /// discover characteristics for each matching service.
    /// - SeeAlso: CBPeripheralDelegate
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services, error == nil else { return }
        let matching = connectingPeripheral?.configuration.services.matchingElementsWith(services)
        guard matching?.count != 0 else {
            centralManager.cancelPeripheralConnection(peripheral)
            return
        }
        matching?.forEach({ (service, cbService) in
            peripheral.discoverCharacteristics(service.characteristics.map({ $0.bluetoothUUID }), for: cbService)
        })
    }
    
    /// Called upon discovery of characteristics of a connected peripheral per each passed service. Used to map CBCharacteristic
    /// instances to passed configuration, assign characteristic raw values and setup notifications.
    /// - SeeAlso: CBPeripheralDelegate
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics, error == nil else { return }
        let matchingService = connectingPeripheral?.configuration.services.filter({ $0.bluetoothUUID == service.uuid }).first
        let matchingCharacteristics = matchingService?.characteristics.matchingElementsWith(characteristics)
        guard matchingCharacteristics?.count != 0 else {
            centralManager.cancelPeripheralConnection(peripheral)
            return
        }
        matchingCharacteristics?.forEach({ (tuple) in
            let (characteristic, cbCharacteristic) = tuple
            characteristic.setRawCharacteristic(cbCharacteristic)
            peripheral.setNotifyValue(characteristic.isObservingValue, for: cbCharacteristic)
        })
        if let connectingPeripheral = self.connectingPeripheral {
            connectingPeripheral.peripheral?.delegate = connectingPeripheral
            self.connectionHandler?(connectingPeripheral, nil)
        }
        connectingPeripheral = nil
    }
    
    /// Called when device is disconnected, inside this method a device is reconnected. Connect method does not have a timeout
    /// so connection will be triggered anytime in the future when the device is discovered. In case the connection is no
    /// longer needed we'll just return.
    /// - SeeAlso: CBPeripheralDelegate
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        guard let disconnectedPeripheral = peripherals.filter({ $0.peripheral === peripheral }).first?.peripheral else { return }
        centralManager.connect(disconnectedPeripheral, options: connectionOptions)
    }
}
