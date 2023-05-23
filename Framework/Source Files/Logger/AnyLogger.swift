//
//  AnyLogger.swift
//  BlueSwift
//

import Foundation

/// A type-erased `Logger`, which behavior is defined by given closure.
final class AnyLogger: Logger {

    typealias EventHandler = (Event, EventContext) -> Void
    private let eventHandler: EventHandler

    init(_ eventHandler: @escaping EventHandler) {
        self.eventHandler = eventHandler
    }

    func log(event: Event, context: EventContext) {
        eventHandler(event, context)
    }

    static func compose(loggers: [Logger]) -> Logger? {
        return loggers.reduce(AnyLogger.empty) { partialResult, nextLogger in
            return partialResult.compose(with: nextLogger)
        }
    }

    static var empty: AnyLogger {
        AnyLogger { _,_ in }
    }
}
