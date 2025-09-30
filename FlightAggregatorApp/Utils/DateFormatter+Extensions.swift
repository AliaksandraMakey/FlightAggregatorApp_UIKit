//
//  DateFormatter+Extensions.swift
//  FlightAggregatorApp
//
//  Created by Alexandra Makey on 29.09.25.
//

import Foundation

extension DateFormatter {
    static let apiDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    static let displayDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        formatter.locale = Locale.current
        return formatter
    }()
    
    static let mediumDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale.current
        return formatter
    }()
    
    static let fullDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale.current
        return formatter
    }()
    
    static let logTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    static let logDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}

// MARK: - Date Extensions
extension Date {
    
    var apiString: String {
        return DateFormatter.apiDate.string(from: self)
    }
    
    var displayString: String {
        return DateFormatter.displayDate.string(from: self)
    }
    
    var mediumString: String {
        return DateFormatter.mediumDate.string(from: self)
    }
    
    var logString: String {
        return DateFormatter.logDateTime.string(from: self)
    }
}

extension Date {
    var timeString: String {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        return timeFormatter.string(from: self)
    }
}

// MARK: - String Extensions
extension String {
    var apiDate: Date? {
        return DateFormatter.apiDate.date(from: self)
    }
    
    var displayDate: String {
        guard let date = self.apiDate else { return self }
        return date.displayString
    }

    var mediumDate: Date? {
        return DateFormatter.mediumDate.date(from: self)
    }
}

