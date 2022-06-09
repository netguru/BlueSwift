//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import CoreBluetooth

/// The current authorization state of a Core Bluetooth manager.
@objc public enum BluetoothAuthorizationStatus: Int {
    /// Bluetooth authorization status is not determined.
    case notDetermined = 0

    /// Bluetooth connection is restricted.
    case restricted = 1

    /// Bluetooth connection is denied.
    case denied = 2

    /// Bluetooth connection is allowed always.
    case allowedAlways = 3
}

@available(iOS 13.0, *)
extension BluetoothAuthorizationStatus {

    /// `CBManagerAuthorization` representation of current authorization status.
    var cbManagerAuthorization: CBManagerAuthorization {
        switch self {
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .restricted
        case .denied:
            return .denied
        case .allowedAlways:
            return .allowedAlways
        }
    }
}

@available(iOS 13.0, *)
extension CBManagerAuthorization {

    /// `BluetoothAuthorizationStatus` representation of current authorization status.
    var bluetoothAuthorizationStatus: BluetoothAuthorizationStatus {
        switch self {
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .restricted
        case .denied:
            return .denied
        case .allowedAlways:
            return .allowedAlways
        @unknown default:
            return .notDetermined
        }
    }
}

extension BluetoothAuthorizationStatus: CustomStringConvertible {

    /// SeeAlso: `CustomStringConvertible.description`
    public var description: String {
        switch self {
        case .notDetermined:
            return "notDetermined"
        case .restricted:
            return "restricted"
        case .denied:
            return "denied"
        case .allowedAlways:
            return "allowedAlways"
        }
    }
}
