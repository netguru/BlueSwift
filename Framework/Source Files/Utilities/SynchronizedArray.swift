//
//  Copyright © 2023 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// A thread-safe `Array`, which synchronizes access to its elements.
/// To avoid race condition while performing multiple operations on ``SynchronizedArray`` use ``SynchronizedArray/read(_:)`` and ``SynchronizedArray/write(_:)`` methods.
final class SynchronizedArray<Element> {

    /// A queue which manages access to ``SynchronizedArray/storage``. Should be a concurrent queue.
    private let queue: DispatchQueueProtocol
    /// Internal storage of the ``SynchronizedArray``.
    private var storage: [Element]

    /// Initializes new ``SynchronizedArray`` with empty storage.
    /// - Parameter queue: A queue which manages access to internal storage. Concurrent queue is recommended.
    init(
        queue: DispatchQueueProtocol = DispatchQueue(label: "co.netguru.lib.blueswift.SynchronizedArray", attributes: .concurrent)
    ) {
        self.queue = queue
        storage = []
    }

    /// Initializes new ``SynchronizedArray`` with containing provided elements.
    convenience init(contentsOf array: [Element]) {
        self.init()
        storage = array
    }

    /// Allows accessing element by its index.
    subscript(_ index: Int) -> Element {
        get {
            read {
                $0[index]
            }
        }
        set {
            write {
                $0[index] = newValue
            }
        }
    }
}

extension SynchronizedArray {

    /// The number of elements in the array.
    var count: Int {
        read { $0.count }
    }

    /// A Boolean value indicating whether the collection is empty.
    var isEmpty: Bool {
        read { $0.isEmpty }
    }

    /// The first element of the array.
    var first: Element? {
        read { $0.first }
    }

    /// The last element of the collection.
    var last: Element? {
        read { $0.last }
    }

    /// Adds a new element at the end of the array.
    /// - Parameter newElement: The element to append to the array.
    func append(_ newElement: Element) {
        write {
            $0.append(newElement)
        }
    }

    /// Adds a new element at the end of the array.
    /// - Parameter newElement: The element to append to the array.
    func append<S>(contentsOf newElements: S) where Element == S.Element, S : Sequence {
        write {
            $0.append(contentsOf: newElements)
        }
    }

    /// Removes and returns the element at the specified position.
    /// - Parameter index: The position of the element to remove. index must be a valid index of the array.
    func remove(at index: Int) {
        write {
            $0.remove(at: index)
        }
    }

    /// Removes all the elements that satisfy the given predicate.
    /// - Parameter shouldBeRemoved: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the element should be removed from the array.
    func removeAll(where shouldBeRemoved: @escaping (Element) -> Bool) {
        write {
            $0.removeAll(where: shouldBeRemoved)
        }
    }

    /// Removes the element at the specified position, checking if provided position is a valid index of the array.
    /// - Parameter index: The position of the element to remove.
    func safelyRemove(at index: Int) {
        write {
            guard index < $0.count, index >= 0 else { return }
            $0.remove(at: index)
        }
    }

    /// Returns the first element of the sequence that satisfies the given predicate.
    /// - Parameter predicate: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the element is a match.
    /// - Returns: an element from the array.
    func first(where predicate: (Element) -> Bool) -> Element? {
        read {
            $0.first(where: predicate)
        }
    }
}

extension SynchronizedArray {

    /// Use `read` method to execute multiple read-operations on the data.
    /// - Parameter block: block of code which takes the storage (`[Element]`) as argument and returns a value.
    /// - Returns: result of block of code.
    func read<T>(_ block: ([Element]) throws -> T) rethrows -> T {
        try queue.sync {
            try block(storage)
        }
    }
    /// Use `write` method to execute multiple write-operations on the data.
    /// - Parameter block: block of code which takes the storage (`[Element]`) as argument and allows to mutate it.
    func write(_ block: @escaping (inout [Element]) -> Void) {
        queue.async(flags: .barrier) {
            block(&self.storage)
        }
    }
}

extension SynchronizedArray: ExpressibleByArrayLiteral {

    /// SeeAlso: ``ExpressibleByArrayLiteral/init(arrayLiteral:)``.
    convenience init(arrayLiteral elements: Element...) {
        self.init(contentsOf: elements)
    }
}

extension SynchronizedArray: Equatable where Element: Equatable {

    /// SeeAlso: `Equatable/==(lhs:rhs:)`.
    static func == (lhs: SynchronizedArray<Element>, rhs: SynchronizedArray<Element>) -> Bool {
        lhs.storage == rhs.storage
    }
}

extension SynchronizedArray: CustomDebugStringConvertible {

    /// SeeAlso: `CustomDebugStringConvertible/debugDescription`.
    var debugDescription: String {
        storage.debugDescription
    }
}
