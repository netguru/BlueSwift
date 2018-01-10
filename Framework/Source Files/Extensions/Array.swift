//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import CoreBluetooth

internal extension Array {
    
    internal func matchingElementsWith<T>(_ array: [T], comparison: @escaping (Element, T) -> Bool) -> [(Element, T)] {
        return flatMap { element in
            guard let index = array.index(where: { comparison(element, $0) }) else { return nil }
            return (element, array[index])
        }
    }
}

internal extension Array where Element == Service {
    
    internal func matchingElementsWith(_ array: [CBService]) -> [(Service, CBService)] {
        return matchingElementsWith(array, comparison: { (service, cbService) -> Bool in
            return cbService.uuid == service.bluetoothUUID
        })
    }
}

internal extension Array where Element == Characteristic {
    
    internal func matchingElementsWith(_ array: [CBCharacteristic]) -> [(Characteristic, CBCharacteristic)] {
        return matchingElementsWith(array, comparison: { (characteristic, cbCharacteristic) -> Bool in
            return characteristic.bluetoothUUID == cbCharacteristic.uuid
        })
    }
}

internal extension Array where Element == Peripheral {
    
    internal func matchingElementsWith(_ array: [CBPeripheral]) -> [(Peripheral, CBPeripheral)] {
        return matchingElementsWith(array, comparison: { (peripheral, cbPeripheral) -> Bool in
            return peripheral.deviceIdentifier == cbPeripheral.identifier.uuidString
        })
    }
}

