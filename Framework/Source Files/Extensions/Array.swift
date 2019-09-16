//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import CoreBluetooth

internal extension Array {
    
    /// Utility method used for matching elements from two different arrays and returning an array of tuples. Matching is based
    /// on a return value from comparison handler.
    func matchingElementsWith<T>(_ array: [T], comparison: (Element, T) -> Bool) -> [(Element, T)] {
        return compactMap { element in
            #if swift(>=5.0)
            guard let index = array.firstIndex(where: { comparison(element, $0) }) else { return nil }
            #else
            guard let index = array.index(where: { comparison(element, $0) }) else { return nil }
            #endif
            return (element, array[index])
        }
    }
}

internal extension Array where Element == Service {
    
    /// Convenience method for easier matching of Service and CBService objects.
    func matchingElementsWith(_ array: [CBService]) -> [(Service, CBService)] {
        return matchingElementsWith(array, comparison: { (service, cbService) -> Bool in
            return cbService.uuid == service.bluetoothUUID
        })
    }
}

internal extension Array where Element == Characteristic {
    
    /// Convenience method for easier matching of Characteristic and CBCharacteristic objects.
    func matchingElementsWith(_ array: [CBCharacteristic]) -> [(Characteristic, CBCharacteristic)] {
        return matchingElementsWith(array, comparison: { (characteristic, cbCharacteristic) -> Bool in
            return characteristic.bluetoothUUID == cbCharacteristic.uuid
        })
    }
}

internal extension Array where Element == Peripheral<Connectable> {
    
    /// Convenience method for easier matching of Peripheral and CBPeripheral objects.
    func matchingElementsWith(_ array: [CBPeripheral]) -> [(Peripheral<Connectable>, CBPeripheral)] {
        return matchingElementsWith(array, comparison: { (peripheral, cbPeripheral) -> Bool in
            return peripheral.deviceIdentifier == cbPeripheral.identifier.uuidString
        })
    }
}

internal extension Array where Element == AdvertisementData {
    
    /// Convenience method used to generate advertising packet from array of AdvertisementData objects.
    func combined() -> [String: Any] {
        var dictionary = [String: Any]()
        forEach {
            guard let data = $0.data else { return }
            var assignedValue: Any = $0
            if let currentValue = dictionary[$0.key], let newValue = data as? [Any] {
                if var arrayValue = currentValue as? [Any] {
                    arrayValue.append(contentsOf: newValue)
                    assignedValue = arrayValue
                } else {
                    assignedValue = [data, currentValue]
                }
            } else {
                assignedValue = data
            }
            dictionary[$0.key] = assignedValue
        }
        return dictionary
    }
}
