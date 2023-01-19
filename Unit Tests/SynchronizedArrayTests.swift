//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
import CoreBluetooth.CBUUID
@testable import BlueSwift

class SynchronizedArrayTests: XCTestCase {

    func testInitializers() {
        // given
        var sut = SynchronizedArray<Int>()

        // then
        XCTAssertTrue(sut.isEmpty)
        XCTAssertEqual(sut.count, 0)

        // given
        sut = .init(arrayLiteral: 1, 2, 3)

        // then
        XCTAssertEqual(sut.count, 3)
        XCTAssertEqual(sut[0], 1)
        XCTAssertEqual(sut[1], 2)
        XCTAssertEqual(sut[2], 3)

        // given
        sut = .init(contentsOf: [3, 4])

        // then
        XCTAssertEqual(sut.count, 2)
        XCTAssertEqual(sut[0], 3)
        XCTAssertEqual(sut[1], 4)
    }

    func testSubscript() {
        // given
        let queue = MockDispatchQueue()
        let sut: SynchronizedArray<Int> = .init(queue: queue)
        sut.append(contentsOf: [1, 2, 3])

        // then
        XCTAssertEqual(sut[0], 1)
        XCTAssertEqual(sut[1], 2)
        XCTAssertEqual(sut[2], 3)

        // when
        sut[0] = 4
        sut[1] = 5
        sut[2] = 6

        // then
        XCTAssertEqual(sut, [4, 5, 6])
    }

    func testFirstAndLast() {
        // given
        var sut: SynchronizedArray<Int> = []

        // then
        XCTAssertNil(sut.first)
        XCTAssertNil(sut.last)

        // given
        sut = [2]

        // then
        XCTAssertEqual(sut.first, 2)
        XCTAssertEqual(sut.last, 2)

        // given
        sut = [1, 2, 3]

        // then
        XCTAssertEqual(sut.first, 1)
        XCTAssertEqual(sut.last, 3)

        // when
        let element = sut.first(where: { $0 == 2 })

        // then
        XCTAssertEqual(element, 2)
    }

    func testEquality() {
        // given
        var sut1: SynchronizedArray<String> = []
        var sut2: SynchronizedArray<String> = []

        // then
        XCTAssertEqual(sut1, sut2)

        // given
        sut1 = ["string"]
        sut2 = []

        // then
        XCTAssertNotEqual(sut1, sut2)

        // given
        sut1 = ["fixture", "string"]
        sut2 = ["fixture", "string"]

        // then
        XCTAssertEqual(sut1, sut2)
    }

    func testAppend() {
        // given
        let queue = MockDispatchQueue()
        let sut: SynchronizedArray<Int> = .init(queue: queue)

        // when
        sut.append(1)

        // then
        XCTAssert(sut == [1])

        // when
        sut.append(2)

        // then
        XCTAssertEqual(sut, [1, 2])

        // when
        sut.append(contentsOf: [3, 4, 5])

        // then
        XCTAssertEqual(sut, [1, 2, 3, 4, 5])
    }

    func testRemove() {
        // given
        let queue = MockDispatchQueue()
        let sut: SynchronizedArray<Int> = .init(queue: queue)

        // when
        sut.removeAll(where: { _ in true })

        // then
        XCTAssert(sut.isEmpty)

        // given
        sut.append(contentsOf: [1, 2, 3])

        // when
        sut.removeAll(where: { _ in false })

        // then
        XCTAssertEqual(sut, [1, 2, 3])

        // when
        sut.removeAll(where: { $0 == 2 })

        // then
        XCTAssertEqual(sut, [1, 3])

        // when
        sut.removeAll(where: { _ in true })

        // then
        XCTAssertEqual(sut, [])

        // given
        sut.append(contentsOf: [1, 2, 3, 4, 5])

        // when
        sut.safelyRemove(at: 5)

        // then
        XCTAssertEqual(sut, [1, 2, 3, 4, 5])

        // when
        sut.safelyRemove(at: 4)

        // then
        XCTAssertEqual(sut, [1, 2, 3, 4])

        // when
        sut.remove(at: 3)

        // then
        XCTAssertEqual(sut, [1, 2, 3])

        // when
        sut.remove(at: 0)

        // then
        XCTAssertEqual(sut, [2, 3])
    }

    func testConcurrentAppend() {
        let sut = SynchronizedArray<Int>()
        let iterations = 1000

        // Regular Swift `Array` would crash here (`EXC_BAD_ACCESS`):
        DispatchQueue.concurrentPerform(iterations: iterations) { index in
            sut.append(index)
        }

        XCTAssertEqual(sut.count, iterations)
    }
}
