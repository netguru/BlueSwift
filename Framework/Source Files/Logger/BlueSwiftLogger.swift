//
//  BlueSwiftLogger.swift
//  BlueSwiftL
//

import Foundation

/// Default logger for the BlueSwift. It can be used as singleton, by accessing ``BlueSwiftLogger/shared``.
/// By default, the shared instance doesn't do anything. It needs to be set up with actual loggers.
/// To set it up, call `BlueSwiftLogger.shared.setLoggers(loggers: [your-loggers])
/// Loggers can be created using factory methods `BlueSwiftLogger.makeConsoleLogger()`, `BlueSwiftLogger.makeFileLogger()`, `BlueSwiftLogger.makeCustomFunctionLogger(eventHandler:)`.
/// Check code completion for a list of all available loggers.
/// - Logger event is embeded in `autoclosure` to delay event evaluation until it is needed. This should increase performance, because logger can filter out an event, and when it does event doesn't have to be evaluated.
/// To "unpack" the event, call `event()`.
/// - Example: Use this code to setup `BlueSwiftLogger` with console and file loggers:
/// `BlueSwiftLogger.shared.setLoggers(loggers: [BlueSwiftLogger.makeConsoleLogger(), BlueSwiftLogger.makeFileLogger()])`
public final class BlueSwiftLogger: Logger {

    private(set) var loggers: [Logger]
    private var logger: Logger?

    private(set) public static var shared: BlueSwiftLogger = BlueSwiftLogger(loggers: [])

    private init(loggers: [Logger]) {
        self.loggers = loggers
        self.logger = AnyLogger
            .compose(loggers: loggers)?
            .mapEvent { event, context in
                BlueSwiftLogger.eventDescription(event: event(), context: context)
            }
    }

    public func setLoggers(loggers: [Logger]) {
        self.loggers = loggers
        self.logger = AnyLogger
            .compose(loggers: loggers)?
            .mapEvent { event, context in
                BlueSwiftLogger.eventDescription(event: event(), context: context)
            }
    }

    public func log(event: @autoclosure () -> Event, context: EventContext) {
        logger?.log(event: event, context: context)
    }
}

public extension BlueSwiftLogger {

    static func makeConsoleLogger() -> Logger {
        ConsoleLogger()
    }

    static func makeFileLogger() -> Logger {
        let fileLogger = try? FileLogger()
        return fileLogger ?? AnyLogger.empty
    }

    static func makeCustomFunctionLogger(eventHandler: @escaping (@autoclosure () -> Logger.Event, EventContext) -> Void) -> Logger {
        CustomFunctionLogger(eventHandler)
    }
}

private extension BlueSwiftLogger {

    static func eventDescription(event: Event, context: EventContext) -> String {
        let location = "[\(context.file.deletingSuffix(".swift")):\(context.function)]"
        let eventString = BlueSwiftLogger.parseAny(event)
        var description = "\(context.type.symbol) \(location) \(eventString)"

        if let data = context.data,
           case let dataString = BlueSwiftLogger.parseAny(data),
           !dataString.isEmpty {
            description.append(", data: \(dataString)")
        }

        return description
    }

    static func parseAny(_ any: Any) -> String {
        if let error = any as? Error {
            return "\(error) - \(error.localizedDescription)"
        }
        if let string = any as? String {
            return string
        }

        return String(describing: any)
    }
}

private extension String {
    
    /// Deletes given suffix from string (if present).
    /// - Parameter suffix: a suffix to delete.
    /// - Returns: a string without suffix.
    func deletingSuffix(_ suffix: String) -> String {
        guard hasSuffix(suffix) else { return self }
        return String(dropLast(suffix.count))
    }
}
