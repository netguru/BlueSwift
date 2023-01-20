//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import BlueSwift

class MockDispatchQueue: DispatchQueueProtocol {

    func sync<T>(execute work: () throws -> T) rethrows -> T {
        try work()
    }

    func async(flags: DispatchWorkItemFlags, execute work: @escaping @convention(block) () -> Void) {
        work()
    }
}
