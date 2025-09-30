//
//  String+Localization.swift
//  FlightAggregatorApp
//
//  Created by Alexandra Makey on 30.09.25.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localized(with arguments: CVarArg...) -> String {
        let format = NSLocalizedString(self, comment: "")
        return String(format: format, arguments: arguments)
    }
}
