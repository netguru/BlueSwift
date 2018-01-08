//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import CoreBluetooth.CBPeripheral

public final class BluetoothConnection {
    
    public enum ConnectionError: Error {
        case bluetoothTurnedOff
        case incompatibleDevice
    }
    
    public static let shared = BluetoothConnection()
    
    private let connectionService = ConnectionService()
    
    public func connect(_ peripheral: Peripheral, handler: @escaping (Bool, ConnectionError?) -> ()) {
        // TODO: fill with connection code
    }
    
    public func disconnect(_ peripheral: Peripheral) {
        // TODO: fill with disconnection code
    }
}
