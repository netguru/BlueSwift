//
//  FileLogger.swift
//  BlueSwift
//

import Foundation

// Logger responsible for writing events to file.
final class FileLogger: Logger {

    enum Error: Swift.Error {
        case invalidFileURL
        case couldNotCreateFile
        case couldNotCreateFileOutputStream
    }

    private let stream: TextOutputStream
    private let dateFormatter: DateFormatter

    /// String representing KetoMojo Sync App in logging system.
    let subsystem = Bundle.main.bundleIdentifier ?? "co.netguru.lib.blueswift"

    /// Default initializer of FileLogger.
    /// - Parameters:
    ///   - fileURL: URL to file where logs will be saved to.
    ///   - encoding: text encoding.
    ///   - dateFormatter: date formatter responsible for creating date string for each log entry.
    ///   - fileManager: file manager.
    init(
        fileURL: URL,
        encoding: String.Encoding,
        dateFormatter: DateFormatter,
        fileManager: FileManager
    ) throws {
        do {
            self.stream = try FileOutputStream(fileURL: fileURL, encoding: encoding, fileManager: fileManager)
        } catch FileOutputStream.Error.couldNotCreateFile {
            throw Error.couldNotCreateFile
        } catch {
            throw Error.couldNotCreateFileOutputStream
        }
        self.dateFormatter = dateFormatter
    }

    convenience init(fileName: String) throws {
        let fileManager = FileManager.default
        guard let url = fileManager.documentsDirectoryURL(forFile: fileName) else { throw Error.invalidFileURL }
        try self.init(fileURL: url, encoding: .utf8, dateFormatter: .fileLogger, fileManager: fileManager)
    }

    /// Creates new `FileLogger` using new file in documents directory with name starting with current date and time.
    convenience init() throws {
        let dateString = DateFormatter.logFileName.string(from: Date())
        let fileName = "\(dateString)-BlueSwift.log" // create new log file for each FileLogger instance
        try self.init(fileName: fileName)
    }

    func log(event: @autoclosure () -> Event, context: EventContext) {
        let event = event()
        let eventString = event as? String ?? String(describing: event)
        let date = dateFormatter.string(from: Date())
        let category = context.category
        let string = "\(date) \(subsystem) [\(category)] \(eventString)\n"

        var stream = self.stream
        stream.write(string)
    }
}

extension FileManager {

    var documentsDirectory: URL? {
        urls(for: .documentDirectory, in: .userDomainMask).first
    }

    func documentsDirectoryURL(forFile fileName: String) -> URL? {
        documentsDirectory?.appendingPathComponent(fileName)
    }
}

private extension DateFormatter {

    static var fileLogger: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSZZZZZ"
        return formatter
    }

    static var logFileName: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH:mm:ss.SSSS"
        return formatter
    }
}

private final class FileOutputStream: TextOutputStream {

    enum Error: Swift.Error {
        case couldNotCreateFile
    }

    let encoding: String.Encoding
    private let fileHandle: FileHandle
    private let fileManager: FileManager

    init(fileURL: URL, encoding: String.Encoding = .utf8, fileManager: FileManager = .default) throws {
        self.encoding = encoding
        self.fileManager = fileManager

        let path = fileURL.path
        guard fileManager.createFile(atPath: path, contents: nil) else { throw Error.couldNotCreateFile }
        let fileHandle = try FileHandle(forWritingTo: fileURL)

        if #available(iOSApplicationExtension 13.4, *) {
            try fileHandle.seekToEnd()
        } else {
            fileHandle.seekToEndOfFile()
        }

        self.fileHandle = fileHandle
    }

    func write(_ string: String) {
        guard let data = string.data(using: encoding) else { return }
        fileHandle.write(data)
    }
}
