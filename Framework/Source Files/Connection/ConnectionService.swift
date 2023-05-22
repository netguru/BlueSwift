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

    /// Closure used to check given peripheral against advertisement packet of discovered peripheral.
    internal var peripheralValidationHandler: ((Peripheral<Connectable>, CBPeripheral, [String: Any], NSNumber) -> (Bool))? = { _,_,_,_ in return true }

    /// Closure used to manage connection success or failure.
    internal var connectionHandler: ((Peripheral<Connectable>, ConnectionError?) -> ())?

    /// Closure called when disconnecting a peripheral using `disconnect(_:)` is completed.
    internal var peripheralConnectionCancelledHandler: ((Peripheral<Connectable>, CBPeripheral) -> ())?

    /// Called when Bluetooth sensor state for current device was updated.
    internal var centralManagerStateUpdateHandler: ((CBManagerState) -> Void)?

    /// Returns the amount of devices already connected.
    internal var connectedDevicesAmount: Int {
        return peripherals.read { storage in
            storage
                .filter { $0.isConnected }
                .count
        }
    }

    /// Indicates whether connected devices limit has been exceeded.
    internal var exceededDevicesConnectedLimit: Bool {
        return connectedDevicesAmount >= deviceConnectionLimit
    }

    /// Current Bluetooth authorization status.
    internal var bluetoothAuthorizationStatus: BluetoothAuthorizationStatus {
        if #available(iOS 13.1, *) {
            return CBManager.authorization.bluetoothAuthorizationStatus
        } else if #available(iOS 13.0, *) {
            return centralManager.authorization.bluetoothAuthorizationStatus
        } else {
            // Until iOS 12 applications could access Bluetooth without the user’s authorization
            return .allowedAlways
        }
    }

    /// Maximum amount of devices capable of connecting to a iOS device.
    private let deviceConnectionLimit = 8
    
    /// Set of peripherals the manager should connect.
    private var peripherals: SynchronizedArray<Peripheral<Connectable>> = []

    /// Handle to peripherals which were requested to disconnect.
    private var peripheralsToDisconnect: SynchronizedArray<Peripheral<Connectable>> = []

    private weak var connectingPeripheral: Peripheral<Connectable>?
    
    /// Connection options - means you will be notified on connection and disconnection of devices.
    private lazy var connectionOptions = [CBConnectPeripheralOptionNotifyOnConnectionKey: true,
                                           CBConnectPeripheralOptionNotifyOnDisconnectionKey: true]
    
    /// Scanning options. Means that one device can be discovered multiple times without connecting.
    private lazy var scanningOptions = [CBCentralManagerScanOptionAllowDuplicatesKey : true]
    
    /// CBCentralManager instance. Allows peripheral connection.
    /// iOS displays Bluetooth authorization popup when `CBCentralManager` is instantiated and authorization status is not determined.
    private lazy var centralManager: CBCentralManager = {
        let manager = CBCentralManager()
        manager.delegate = self
        return manager
    }()

    /// Set of advertisement UUID central manager should scan for.
    private var scanParameters: Set<CBUUID> = Set()
}

extension ConnectionService {

    enum LogEvent {
        case connect, centralManagerDidUpdateState, centralManagerDidDiscoverPeripheral, didConnectPeripheral, didFailToConnectPeripheral
        case didDisconnectPeripheral, reloadScanning, performDeviceAutoReconnection, didDiscoverServices, didDiscoverCharacteristicsFor
    }
}

extension ConnectionService {
    
    /// Starts connection with passed device. Connection result is passed in handler closure.
    internal func connect(_ peripheral: Peripheral<Connectable>, handler: @escaping (Peripheral<Connectable>, ConnectionError?) -> ()) {
        if connectionHandler == nil {
            connectionHandler = handler
        }
        do {
            BlueSwiftLogger.shared.log(.info, LogEvent.connect, data: peripheral)
            try centralManager.validateState()
            peripherals.append(peripheral)
            reloadScanning()
        } catch let error {
            BlueSwiftLogger.shared.log(.error, LogEvent.connect, data: error)
            if let error = error as? BluetoothError {
                BlueSwiftLogger.shared.log(.error, LogEvent.connect, data: error)
                handler(peripheral, .bluetoothError(error))
            }
        }
    }
    
    /// Disconnects given device.
    internal func disconnect(_ peripheral: CBPeripheral) {
        peripherals.write { storage in
            guard let index = storage.firstIndex(where: { $0.peripheral === peripheral }) else { return }
            let peripheralToDisconnect = storage.remove(at: index)
            self.peripheralsToDisconnect.append(peripheralToDisconnect)
        }
        centralManager.cancelPeripheralConnection(peripheral)
    }

    /// Function called to remove peripheral from queue
    /// - Parameter peripheral: peripheral to remove.
    internal func remove(_ peripheral: Peripheral<Connectable>) {
        peripherals.write { storage in
            guard let index = storage.firstIndex(where: { $0 === peripheral }) else { return }
            storage.remove(at: index)
        }
    }

    /// Function called to stop scanning for devices.
    internal func stopScanning() {
        centralManager.stopScan()
    }

    /// Triggers showing Bluetooth authorization popup by instantiating the central manager.
    internal func requestBluetoothAuthorization() {
        _ = centralManager
    }
}

private extension ConnectionService {
    
    /// Reloads scanning if necessary. Adding scan parameters should be ommited in case of possible peripheral retrive.
    /// In that case connection is available without previous scanning.
    private func reloadScanning() {
        BlueSwiftLogger.shared.log(.info, LogEvent.reloadScanning, data: "isScanning: \(centralManager.isScanning)")
        if centralManager.isScanning {
            centralManager.stopScan()
        }
        performDeviceAutoReconnection()
        let params: [CBUUID] = peripherals.read { storage in
            storage.compactMap { (peripheral) -> CBUUID? in
                guard peripheral.peripheral == nil else { return nil }
                return peripheral.configuration.advertisementUUID
            }
        }
        guard params.count != 0 else {
            return
        }
        scanParameters = Set(params)
        guard case .poweredOn = centralManager.state else {
            BlueSwiftLogger.shared.log(.warning, LogEvent.reloadScanning, data: "central is powered off")
            return
        }
        centralManager.scanForPeripherals(withServices: Array(scanParameters), options: scanningOptions)
    }
    
    /// Tries a peripeheral retrieve for each peripheral model. Peripheral can be retrieved in case the parameter of
    /// deviceIdentifier was passed during initialization. If it's correctly retrieved, scanning is unnecessary and peripheral
    /// can be directly connected.
    private func performDeviceAutoReconnection() {
        BlueSwiftLogger.shared.log(.info, LogEvent.performDeviceAutoReconnection)

        peripherals.read { storage in
            let identifiers = storage
                .filter { !$0.isConnected }
                .compactMap { UUID(uuidString: $0.deviceIdentifier ?? "") }
            guard !identifiers.isEmpty else { return }
            let retrievedPeripherals = centralManager.retrievePeripherals(withIdentifiers: identifiers)
            let matching = storage.matchingElementsWith(retrievedPeripherals)
            matching.forEach { (peripheral, cbPeripheral) in
                peripheral.peripheral = cbPeripheral
                centralManager.connect(cbPeripheral, options: connectionOptions)
            }
        }
    }
}

extension ConnectionService: CBCentralManagerDelegate {
    
    /// Determines Bluetooth sensor state for current device.
    /// - SeeAlso: CBCentralManagerDelegate
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        centralManagerStateUpdateHandler?(central.state)

        guard let handler = connectionHandler,
              let anyDevice = peripherals.first
        else { return }

        do {
            BlueSwiftLogger.shared.log(.info, LogEvent.centralManagerDidUpdateState)
            try central.validateState()
            reloadScanning()
        } catch let error {
            BlueSwiftLogger.shared.log(.error, LogEvent.centralManagerDidUpdateState, data: error)
            if let error = error as? BluetoothError {
                BlueSwiftLogger.shared.log(.error, LogEvent.centralManagerDidUpdateState, data: error)
                handler(anyDevice, .bluetoothError(error))
            }
        }
    }
    
    /// Called when a peripheral with desired advertised service is discovered.
    /// - SeeAlso: CBCentralManagerDelegate
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        BlueSwiftLogger.shared.log(.info, LogEvent.centralManagerDidDiscoverPeripheral, data: "peripheral: \(peripheral), advertisementData: \(advertisementData), rssi: \(RSSI)")
        let matchingPeripheral = peripherals.read { storage in
            storage
                .filter({ $0.configuration.matches(advertisement: advertisementData)})
                .first(where: { $0.peripheral == nil })
        }

        guard let handler = peripheralValidationHandler,
              let matchingPeripheral,
              connectingPeripheral == nil,
              handler(matchingPeripheral, peripheral, advertisementData, RSSI)
        else {
            BlueSwiftLogger.shared.log(
                .warning,
                LogEvent.centralManagerDidDiscoverPeripheral,
                data: """
                will not connect.
                  is handler nil: \(peripheralValidationHandler == nil),
                  matchingPeripheral: \(String(describing: matchingPeripheral)),
                  connectingPeripheral: \(String(describing: connectingPeripheral))
                """
            )
            return
        }

        connectingPeripheral = matchingPeripheral
        connectingPeripheral?.peripheral = peripheral
        connectingPeripheral?.rssi = RSSI
        central.connect(peripheral, options: connectionOptions)
        if exceededDevicesConnectedLimit {
            BlueSwiftLogger.shared.log(.warning, LogEvent.centralManagerDidDiscoverPeripheral, data: "exceededDevicesConnectedLimit is true. Stopping scanning.")
            centralManager.stopScan()
        }
    }
    
    /// Called upon a successfull peripheral connection.
    /// - SeeAlso: CBCentralManagerDelegate
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        let connectingPeripheral = peripherals.read { $0.first(withIdentical: peripheral) }
        BlueSwiftLogger.shared.log(.info, LogEvent.didConnectPeripheral, data: "peripheral: \(peripheral), connectingPeripheral: \(String(describing: connectingPeripheral))")
        guard let connectingPeripheral else {
            // Central manager did connect to a peripheral, which is not on the list of allowed peripherals at this moment.
            // Peripheral might have re-connected unexpectedly. Disconnect it, so it can be discovered.
            BlueSwiftLogger.shared.log(.info, LogEvent.didConnectPeripheral, data: "Connected to peripheral which is not on allow list")
            centralManager.cancelPeripheralConnection(peripheral)
            return
        }
        self.connectingPeripheral = connectingPeripheral
        connectingPeripheral.peripheral = peripheral
        peripheral.delegate = self
        peripheral.discoverServices(connectingPeripheral.configuration.services.map({ $0.bluetoothUUID }))
        BlueSwiftLogger.shared.log(.info, LogEvent.didConnectPeripheral, data: "peripheral connected")
    }
    
    /// Called when peripheral connection fails on its initialization, we'll reconnect it right away.
    /// - SeeAlso: CBCentralManagerDelegate
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        BlueSwiftLogger.shared.log(.info, LogEvent.didFailToConnectPeripheral, data: "peripheral: \(peripheral), error: \(error?.localizedDescription ?? String(describing: error))")
        central.connect(peripheral, options: connectionOptions)
    }
}

extension ConnectionService: CBPeripheralDelegate {

    /// Called upon discovery of services of a connected peripheral. Used to map model services to passed configuration and
    /// discover characteristics for each matching service.
    /// - SeeAlso: CBPeripheralDelegate
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        BlueSwiftLogger.shared.log(.info, LogEvent.didDiscoverServices, data: "error: \(error?.localizedDescription ?? String(describing: error))")
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
        BlueSwiftLogger.shared.log(.info, LogEvent.didDiscoverCharacteristicsFor, data: "service: \(service), error: \(error?.localizedDescription ?? String(describing: error))")
        guard let characteristics = service.characteristics, error == nil else { return }
        let matchingService = connectingPeripheral?.configuration.services.first(where: { $0.bluetoothUUID == service.uuid })
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

    /// Called when device is disconnected.
    /// If connection was cancelled using `disconnect(_:)`, then `peripheralConnectionCancelledHandler(_:)` is called.
    /// Otherwise device is reconnected. Connect method does not have a timeout, so connection will be triggered
    /// anytime in the future when the device is discovered. In case the connection is no longer needed we'll just return.
    /// - SeeAlso: CBPeripheralDelegate
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        /// `error` is nil if disconnect resulted from a call to `cancelPeripheralConnection(_:)`.
        /// SeeAlso: https://developer.apple.com/documentation/corebluetooth/cbcentralmanagerdelegate/1518791-centralmanager
        ///
        BlueSwiftLogger.shared.log(.info, LogEvent.didDisconnectPeripheral, data: "peripheral: \(peripheral), error: \(error?.localizedDescription ?? String(describing: error))")

        if error == nil {
            peripheralsToDisconnect.write { [weak self] storage in
                guard let disconnectedPeripheral = storage.first(withIdentical: peripheral) else {
                    BlueSwiftLogger.shared.log(.warning, LogEvent.didDisconnectPeripheral, data: "disconnected peripheral was not found on the list peripheralsToDisconnect")
                    return
                }
                storage.removeAll(where: { $0 === disconnectedPeripheral })
                self?.peripheralConnectionCancelledHandler?(disconnectedPeripheral, peripheral)
            }
            return
        }

        if let disconnectedPeripheral = peripherals.read({ $0.first(withIdentical: peripheral) }),
           let nativePeripheral = disconnectedPeripheral.peripheral {
            BlueSwiftLogger.shared.log(.info, LogEvent.didDisconnectPeripheral, data: "disconnected peripheral was found on the list of peripherals.")
            disconnectedPeripheral.disconnectionHandler?()
            centralManager.connect(nativePeripheral, options: connectionOptions)
        } else {
            BlueSwiftLogger.shared.log(.info, LogEvent.didDisconnectPeripheral, data: "disconnected peripheral was not found on the list of peripherals.")
        }
    }
}
