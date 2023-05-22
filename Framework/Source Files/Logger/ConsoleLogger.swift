//
//  ConsoleLogger.swift
//  BlueSwift
//

import Foundation
import os.log

// Logger responsible for sending events to standard output (console).
final class ConsoleLogger: Logger {
    
    /// String representing KetoMojo Sync App in logging system.
    let subsystem = Bundle.main.bundleIdentifier ?? "co.netguru.lib.blueswift"

    func log(event: @autoclosure () -> Event, context: EventContext) {
        let oslog = OSLog(subsystem: subsystem, category: context.category)
        let event = event()
        let logString = event as? String ?? String(describing: event)
        os_log("%{public}@", log: oslog, type: context.type.osLogType, logString)
    }
}

extension LogType {
    
    var osLogType: OSLogType {
        switch self {
        case .info:
            return .info
        case .debug:
            return .debug
        case .warning:
            return .default
        case .error:
            return .error
        }
    }
}
