//
//  CustomFunctionLogger.swift
//  BlueSwift
//

import Foundation

// Logger responsible for sending events to custom function.
final class CustomFunctionLogger: Logger {

    typealias EventHandler = (Event, EventContext) -> Void
    private let eventHandler: EventHandler

    init(_ eventHandler: @escaping EventHandler) {
        self.eventHandler = eventHandler
    }

    /// SeeAlso: ``Logger/log(event:context:)``.
    /// - Logger event is embeded in `autoclosure` to delay event evaluation until it is needed. This should increase performance, because logger can filter out an event, and when it does event doesn't have to be evaluated.
    /// To "unpack" the event, call `event()`.
    func log(event: Event, context: EventContext) {
        eventHandler(event, context)
    }
}
