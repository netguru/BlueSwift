//
//  Copyright © 2023 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Protocol describing a `DispatchQueue`.
protocol DispatchQueueProtocol: AnyObject {

    /// Submits a work item for execution and returns the results from that item after it finishes executing.
    /// - Parameter work: The block that contains the work to perform.
    /// - Returns: The return value of the item in the work parameter.
    func sync<T>(execute work: () throws -> T) rethrows -> T

    /// Schedules a block asynchronously for execution
    /// - Parameters:
    ///   - flags: Additional attributes to apply when executing the block. For a list of possible values, see `DispatchWorkItemFlags`.
    ///   - work: The block containing the work to perform. This block has no return value and no parameters.
    func async(flags: DispatchWorkItemFlags, execute work: @escaping @convention(block) () -> Void)
}

extension DispatchQueue: DispatchQueueProtocol {

    /// Convenience version of `DispatchQueue/async(group:qos:flags:execute:)` method.
    /// SeeAlso: ``DispatchQueueProtocol/async(flags:execute:)``
    func async(flags: DispatchWorkItemFlags = [], execute work: @escaping @convention(block) () -> Void) {
        async(group: nil, qos: .unspecified, flags: flags, execute: work)
    }
}
