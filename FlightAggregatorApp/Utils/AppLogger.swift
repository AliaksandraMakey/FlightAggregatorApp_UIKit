//
//  AppLogger.swift
//  FlightAggregatorApp
//
//  Created by Alexandra Makey on 29.09.25.
//

import Foundation

//MARK: - LogLevel
enum LogLevel: String {
    case debug = "🔍 DEBUG"
    case info = "ℹ️ INFO"
    case success = "✅ SUCCESS"
    case warning = "⚠️ WARNING"
    case error = "❌ ERROR"
  
    var colorCode: String {
        switch self {
            //white
        case .debug: return "\u{001B}[37m"
            //blue
        case .info: return "\u{001B}[34m"
            //green
        case .success: return "\u{001B}[32m"
            //yellow
        case .warning: return "\u{001B}[33m"
            //red
        case .error: return "\u{001B}[31m"
        }
    }

    static let resetColor = "\u{001B}[0m"
}

//MARK: - LogCategory
enum LogCategory: String, CaseIterable {
    case general = "GENERAL"
    case network = "NETWORK"
    case api = "API"
    case data = "DATA"
    case cache = "CACHE"
    case flight = "FLIGHT"
    case airport = "AIRPORT"
    case ui = "UI"
}

//MARK: - LogContent
struct LogContent {
    var message: String
    var metadata: [String: Any]?
    
    init(_ message: String, metadata: [String: Any]? = nil) {
        self.message = message
        self.metadata = metadata
    }
}

//MARK: - AppLogger
final class AppLogger {
    static let shared = AppLogger()
    private var minimumLogLevel: LogLevel = .debug
    private var isLoggingEnabled = true
    private var shouldPrintMetadata = true
    private var showDate = true
    private var showTime = true
    private var showCategory = true

    enum LogDestination {
        case console
        case file(URL)
        case custom((String) -> Void)
    }
    
    private var destinations: [LogDestination] = [.console]
    
    private init() {
        #if DEBUG
        configure(minLogLevel: .debug, enabled: true)
        #else
        configure(minLogLevel: .info, enabled: true)
        #endif
    }
    
    ///MARK: - Configure
    func configure(
        minLogLevel: LogLevel = .debug,
        enabled: Bool = true,
        printMetadata: Bool = true,
        showDate: Bool = true,
        showTime: Bool = true,
        showCategory: Bool = true,
        destinations: [LogDestination] = [.console]
    ) {
        self.minimumLogLevel = minLogLevel
        self.isLoggingEnabled = enabled
        self.shouldPrintMetadata = printMetadata
        self.showDate = showDate
        self.showTime = showTime
        self.showCategory = showCategory
        self.destinations = destinations
    }
    
    func log(_ level: LogLevel, category: LogCategory, content: LogContent, file: String = #file, function: String = #function, line: Int = #line) {
        guard isLoggingEnabled else { return }
        guard shouldLog(level) else { return }
        
        var logComponents: [String] = []
        
        if showDate || showTime {
            logComponents.append("[\(formattedTimestamp())]")
        }
        
        logComponents.append("[\(level.rawValue)]")
        
        if showCategory {
            logComponents.append("[\(category.rawValue)]")
        }
        
        logComponents.append(content.message)
        
        var logText = "\(level.colorCode)\(logComponents.joined(separator: " "))\(LogLevel.resetColor)"

        if shouldPrintMetadata, let metadata = content.metadata, !metadata.isEmpty {
            let metadataString = formatMetadata(metadata)
            logText += "\n\(level.colorCode)Metadata: \(metadataString)\(LogLevel.resetColor)"
        }
        
        for destination in destinations {
            switch destination {
            case .console:
                print(logText)
            case .file(let url):
                let cleanText = logText.replacingOccurrences(of: "\u{001B}\\[[0-9;]*m", with: "", options: .regularExpression)
                appendToFile(cleanText, at: url)
            case .custom(let handler):
                handler(logText)
            }
        }
        
        #if DEBUG
        if level == .error {
            let fileInfo = extractFileName(file)
            print("\(level.colorCode)At: \(fileInfo):\(line) in \(function)\(LogLevel.resetColor)")
        }
        #endif
    }
    
    // MARK: - Convenience Methods
    func debug(_ message: String, category: LogCategory = .general, metadata: [String: Any]? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        log(.debug, category: category, content: LogContent(message, metadata: metadata), file: file, function: function, line: line)
    }
    
    func info(_ message: String, category: LogCategory = .general, metadata: [String: Any]? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        log(.info, category: category, content: LogContent(message, metadata: metadata), file: file, function: function, line: line)
    }
    
    func success(_ message: String, category: LogCategory = .general, metadata: [String: Any]? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        log(.success, category: category, content: LogContent(message, metadata: metadata), file: file, function: function, line: line)
    }
    
    func warning(_ message: String, category: LogCategory = .general, metadata: [String: Any]? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        log(.warning, category: category, content: LogContent(message, metadata: metadata), file: file, function: function, line: line)
    }
    
    func error(_ message: String, category: LogCategory = .general, metadata: [String: Any]? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        log(.error, category: category, content: LogContent(message, metadata: metadata), file: file, function: function, line: line)
    }
    
    
    // MARK: - Private helper methods
    private func shouldLog(_ level: LogLevel) -> Bool {
        let levels: [LogLevel] = [.debug, .info, .success, .warning, .error]
        
        guard let minimumIndex = levels.firstIndex(of: minimumLogLevel),
              let currentIndex = levels.firstIndex(of: level) else {
            return true
        }
        
        return currentIndex >= minimumIndex
    }
    
    private func formattedTimestamp() -> String {
        let currentDate = Date()
        
        if showDate && showTime {
            return currentDate.logString
        } else if showDate {
            return currentDate.apiString
        } else if showTime {
            return DateFormatter.logTime.string(from: currentDate)
        } else {
            return ""
        }
    }
    
    private func extractFileName(_ filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        if let fileName = components.last {
            return fileName
        }
        return filePath
    }
    
    private func formatMetadata(_ metadata: [String: Any]) -> String {
        do {
            let sanitizedMetadata = metadata.mapValues { value -> Any in
                if let date = value as? Date {
                    return DateFormatter.fullDateTime.string(from: date)
                } else if let url = value as? URL {
                    return url.absoluteString
                } else if JSONSerialization.isValidJSONObject([value]) {
                    return value
                } else {
                    return String(describing: value)
                }
            }
            
            let data = try JSONSerialization.data(withJSONObject: sanitizedMetadata, options: .prettyPrinted)
            if let prettyJSON = String(data: data, encoding: .utf8) {
                return prettyJSON
            }
        } catch {
            return metadata.description
        }
        return metadata.description
    }

    private func appendToFile(_ text: String, at url: URL) {
        do {
            let fileManager = FileManager.default
            let directoryURL = url.deletingLastPathComponent()
      
            if !fileManager.fileExists(atPath: directoryURL.path) {
                try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            }
       
            let textWithNewline = text + "\n"
            
            if fileManager.fileExists(atPath: url.path) {
                let fileHandle = try FileHandle(forWritingTo: url)
                fileHandle.seekToEndOfFile()
                if let data = textWithNewline.data(using: .utf8) {
                    fileHandle.write(data)
                }
                fileHandle.closeFile()
            } else {
                try textWithNewline.write(to: url, atomically: true, encoding: .utf8)
            }
        } catch {
            print("❌ Error writing to log file: \(error.localizedDescription)")
        }
    }
}

// MARK: - Result Logging Extension
extension Result where Failure == Error {
    @discardableResult
    func logResult(successMessage: String, category: LogCategory = .general, successMetadata: [String: Any]? = nil) -> Self {
        switch self {
        case .success:
            AppLogger.shared.success(successMessage, category: category, metadata: successMetadata)
        case .failure(let error):
            AppError.from(error: error).log()
        }
        return self
    }
}
