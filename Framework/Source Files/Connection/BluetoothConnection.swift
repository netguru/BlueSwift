//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import CoreBluetooth.CBPeripheral

/// Public facing interface granting methods to connect and disconnect devices
public final class BluetoothConnection {
    
    /// List of possible errrors that can happen during connection.
    public enum ConnectionError: Error {
        case bluetoothTurnedOff
        case incompatibleDevice
    }
    
    /// List of possible disconnection errors.
    public enum DisconnectionError: Error {
        case deviceNotScheduledForConnection
    }
    
    /// A singleton instance.
    public static let shared = BluetoothConnection()
    
    /// A private instance of ConnectionService - class implementing default Apple bluetooth LE connection API methods.
    private let connectionService = ConnectionService()
    
    /// Primary method used to connect to a device.
    /// - Parameter peripheral: a configured device you wish to connect to.
    /// - Parameter handler: a comepletion handler called upon succesfull connection or a error.
    /// - SeeAlso: BluetoothConnection.ConnectionError
    /// - SeeAlso: Peripheral
    public func connect(_ peripheral: Peripheral, handler: @escaping (Bool, ConnectionError?) -> ()) {
        // TODO: fill with connection code
    }
    
    /// Primary method to disconnect a device. If it's not yet connected it'll be removed from connection queue, and connection attempts
    /// will stop.
    /// - Parameter peripheral: a peripheral you wish to disconnect. Should be exactly the same instance that was used for connection.
    /// - Throws: BluetoothConnection.ConnectionError in case there was a disconnection problem
    /// - SeeAlso: BluetoothConnection.DisconnectionError
    public func disconnect(_ peripheral: Peripheral) throws {
        // TODO: fill with disconnection code
    }
}
