//
//  Sequence.swift
//  Bluetooth
//
//  Created by Filip Zieliński on 08/04/2022.
//  Copyright © 2022 Netguru. All rights reserved.
//

import Foundation
import CoreBluetooth

internal extension Sequence {

    /// Returns the first element of the sequence where given element property is identical (`===`) to given object instance.
    /// - Parameters:
    ///   - propertyKeyPath: a key path to an element property.
    ///   - instance: an object instance to compare against.
    /// - Returns: The first element of the sequence where given element property is identical (`===`) to given object instance, or `nil` if there is no such element.
    func first<Object: AnyObject>(where propertyKeyPath: KeyPath<Element, Object>, isIdenticalTo instance: Object) -> Element? {
        first { $0[keyPath: propertyKeyPath] === instance }
    }

    /// Returns the first element of the sequence where given element optional property is identical (`===`) to given object instance.
    /// - Parameters:
    ///   - propertyKeyPath: a key path to an element property.
    ///   - instance: an object instance to compare against.
    /// - Returns: The first element of the sequence where given element optional property is identical (`===`) to given object instance, or `nil` if there is no such element.
    func first<Object: AnyObject>(where propertyKeyPath: KeyPath<Element, Object?>, isIdenticalTo instance: Object) -> Element? {
        first { $0[keyPath: propertyKeyPath] === instance }
    }
}

internal extension Sequence where Element == Peripheral<Connectable> {

    /// Convenience method returning the first peripheral of the sequence with `peripheral` property identical (`===`)  to given `CBPeripheral` instance.
    /// - Parameter cbPeripheral: a `CBPeripheral` instance.
    /// - Returns: The first peripheral of the sequence with `peripheral` property identical (`===`)  to given `CBPeripheral` instance, or `nil` if there is no such element.
    func first(withIdentical cbPeripheral: CBPeripheral) -> Element? {
        first(where: \.peripheral, isIdenticalTo: cbPeripheral)
    }
}
