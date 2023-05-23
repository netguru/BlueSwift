//
//  Logger.swift
//  BlueSwift
//

import Foundation

/// A composable logger type which gathers log events and errors. A `Logger` type can be responsible for sending events to standard output (console), or to file, server etc.
/// Two loggers can be composed together using ``Logger/compose(with:)``.
public protocol Logger {
    typealias Event = Any

    /// Logs an event with its meta-data.
    /// - Logger event is embeded in `autoclosure` to delay event evaluation until it is needed. This should increase performance, because logger can filter out an event, and when it does event doesn't have to be evaluated.
    /// To "unpack" the event, call `event()`.
    /// - Parameters:
    ///   - event: event to log.
    ///   - type: type of log, e.g. error, debug, etc.
    ///   - category: category of the event, e.g. `BlueSwift`.
    ///   - file: source file name where event was recorded.
    ///   - function: function name where event was recorded.
    func log(event: Event, context: EventContext)
}

public struct EventContext {
    /// Optional additional information for event.
    let data: Any?
    let type: LogType
    let category: String
    let file: String
    let function: String
}

extension Logger {
    
    /// Convenience method for logging. It provides default values for `file` and `function` names.
    func log(_ type: LogType, _ event: Event, data: Any? = nil, category: String = LogCategory.blueSwift.rawValue, file: String = #fileID, function: String = #function) {
        let context = EventContext(data: data, type: type, category: category, file: file, function: function)
        log(event: event, context: context)
    }

    /// Creates a type-erased equivalent logger.
    /// - Returns: new `AnyLogger` instance.
    func eraseToAnyLogger() -> AnyLogger {
        AnyLogger { event, context in
            self.log(event: event, context: context)
        }
    }
}

public extension Logger {

    /// Composes logger with another logger, so events are delivered to both of them.
    /// - Parameter other: other logger.
    /// - Returns: a new logger combining both loggers.
    func compose(with other: Logger) -> Logger {
        AnyLogger { event, context in
            self.log(event: event, context: context)
            other.log(event: event, context: context)
        }
    }

    /// Applies a transformation function to each emitted event.
    /// - Parameter transform: transform function.
    /// - Returns: a new logger which transforms events.
    func mapEvent(_ transform: @escaping (Event, EventContext) -> Event) -> Logger {
        AnyLogger { event, context in
            self.log(event: { transform(event, context) }, context: context)
        }
    }

    /// Applies a transformation function to each emitted event.
    /// - Parameter transform: transform function.
    /// - Returns: a new logger which transforms events.
    func mapContext(_ transform: @escaping (Event, EventContext) -> EventContext) -> Logger {
        AnyLogger { event, context in
            self.log(event: event, context: transform(event, context))
        }
    }

    /// Projects logger arguments to new logger.
    /// - Parameter transform: transforming closure.
    /// - Returns: new `Logger` instance.
    func flatMap(_ transform: @escaping (Event, EventContext) -> Logger) -> Logger {
        AnyLogger { event, context in
            transform(event, context).log(event: event, context: context)
        }
    }

    /// Filters event and context based on a predicate.
    /// - Parameter predicate: a predicate function. If returns `true`, then event is passed further.
    /// - Returns: new `Logger` instance passing down events only when predicate is satisfied.
    func filter(_ predicate: @escaping (Event, EventContext) -> Bool) -> Logger {
        AnyLogger { event, context in
            guard predicate(event, context) else { return }
            self.log(event: event, context: context)
        }
    }
}

/// Category of log event.
public enum LogCategory: String {
    case blueSwift
}

/// Type of log event.
enum LogType {
    case info
    case debug
    case warning
    case error
}

extension LogType {

    var symbol: String {
        switch self {
        case .info:
            return "🪵"
        case .debug:
            return "🛠"
        case .warning:
            return "⚠️"
        case .error:
            return "❌"
        }
    }
}
