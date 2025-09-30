//
//  AppError.swift
//  FlightAggregatorApp
//
//  Created by Alexandra Makey on 29.09.25.
//

    
import Foundation

// MARK: - App Error
enum AppError: LocalizedError {
    case unknown(String)
    case requestTimeout(String)
    case networkError(String)
    case invalidURL(String)
    case invalidToken(String)
    case noInternetConnection(String)
    case dataDecodingFailed(String)
   
    var errorDescription: String? {
        localizedDescription
    }
    
    var localizedDescription: String {
        switch self {
        case .unknown(let message):
            return "Unknown error: \(message)"
        case .requestTimeout(let message):
            return "Request timeout: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .invalidURL(let message):
            return "Invalid URL: \(message)"
        case .invalidToken(let message):
            return "Invalid token: \(message)"
        case .noInternetConnection(let message):
            return "No internet connection: \(message)"
        case .dataDecodingFailed(let message):
            return "Data decoding failed: \(message)"
        }
    }
    
    var logCategory: LogCategory {
        switch self {
        case .unknown:
            return .general
        case .networkError, .invalidURL, .noInternetConnection:
            return .network
        case .invalidToken, .requestTimeout:
            return .api
        case .dataDecodingFailed:
            return .data
        }
    }
}

// MARK: - Error Conversion
extension AppError {
    static func from(error: Error) -> AppError {
        if let appError = error as? AppError {
            return appError
        }
        
        let nsError = error as NSError
        
        switch nsError.domain {
        case NSURLErrorDomain:
            return handleURLError(nsError)
        case "NSCocoaErrorDomain":
            return handleCocoaError(nsError)
        default:
            return .unknown("Code: \(nsError.code), Description: \(nsError.localizedDescription)")
        }
    }
    
    private static func handleURLError(_ error: NSError) -> AppError {
        switch error.code {
        case NSURLErrorNotConnectedToInternet:
            return .noInternetConnection("No internet connection available")
        case NSURLErrorTimedOut:
            return .requestTimeout("Request timed out")
        case NSURLErrorBadURL:
            return .invalidURL("Invalid URL format")
        case NSURLErrorCannotConnectToHost:
            return .networkError("Cannot connect to host")
        default:
            return .networkError("URL error: \(error.localizedDescription)")
        }
    }
    
    private static func handleCocoaError(_ error: NSError) -> AppError {
        switch error.code {
        case 3840:
            return .dataDecodingFailed("JSON parsing failed: \(error.localizedDescription)")
        default:
            return .unknown("Cocoa error: \(error.localizedDescription)")
        }
    }
}

// MARK: - Logging
extension AppError {
    func log() {
        AppLogger.shared.log(.error, category: logCategory, content: LogContent(localizedDescription))
    }
}
