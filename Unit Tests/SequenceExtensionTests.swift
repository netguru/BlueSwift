//
//  SequenceExtensionTests.swift
//  Bluetooth
//
//  Created by Filip Zieliński on 08/04/2022.
//  Copyright © 2022 Netguru. All rights reserved.
//

import XCTest
import CoreBluetooth
@testable import BlueSwift

final class SequenceExtensionTests: XCTestCase {

    private let fixtureReference = SimpleClass()
    private let fixtureOptionalReference = SimpleClass()
    private lazy var fixtureTestClass = TestClass(someReference: fixtureReference, someOptionalReference: fixtureOptionalReference)

    func testFirstSequenceElement_withIdenticalProperty() {
        // given:
        var sut: [TestClass] = [
            TestClass(someReference: .init(), someOptionalReference: nil),
            TestClass(someReference: .init(), someOptionalReference: .init()),
            fixtureTestClass,
            TestClass(someReference: .init(), someOptionalReference: .init()),
        ]

        // then:
        testFindingElement_withMatchingIdenticalProperty(sut: sut)

        // given
        sut = [
            fixtureTestClass,
            TestClass(someReference: .init(), someOptionalReference: .init()),
            TestClass(someReference: .init(), someOptionalReference: .init()),
            TestClass(someReference: .init(), someOptionalReference: nil)
        ]

        // then:
        testFindingElement_withMatchingIdenticalProperty(sut: sut)

        // given
        sut = [
            TestClass(someReference: .init(), someOptionalReference: .init()),
            TestClass(someReference: .init(), someOptionalReference: nil),
            TestClass(someReference: .init(), someOptionalReference: .init()),
            fixtureTestClass
        ]

        // then:
        testFindingElement_withMatchingIdenticalProperty(sut: sut)
    }
}

private extension SequenceExtensionTests {

    func testFindingElement_withMatchingIdenticalProperty(sut: [TestClass]) {
        XCTAssert(sut.first(where: \.someReference, isIdenticalTo: fixtureReference) === fixtureTestClass, "Should find object with matching identical (`===`) property")
        XCTAssert(sut.first(where: \.someOptionalReference, isIdenticalTo: fixtureOptionalReference) === fixtureTestClass, "Should find object with matching identical (`===`) property")
        XCTAssertNil(sut.first(where: \.someReference, isIdenticalTo: fixtureOptionalReference), "Should not find any object with matching identical (`===`) property")
        XCTAssertNil(sut.first(where: \.someOptionalReference, isIdenticalTo: fixtureReference), "Should not find any object with matching identical (`===`) property")
        XCTAssertNil(sut.first(where: \.someReference, isIdenticalTo: .init()), "Should not find any object with matching identical (`===`) property")
        XCTAssertNil(sut.first(where: \.someOptionalReference, isIdenticalTo: .init()), "Should not find any object with matching identical (`===`) property")
    }
}

private final class TestClass: Identifiable {

    let someReference: SimpleClass
    let someOptionalReference: SimpleClass?
    
    init(someReference: SimpleClass, someOptionalReference: SimpleClass?) {
        self.someReference = someReference
        self.someOptionalReference = someOptionalReference
    }
}

private final class SimpleClass {}
