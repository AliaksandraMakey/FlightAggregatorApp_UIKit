//
//  Country.swift
//  FlightAggregatorApp
//
//  Created by Alexandra Makey on 29.09.25.
//

import UIKit

// MARK: - Country
struct Country: Codable, Identifiable {
    let id = UUID()
    let code: String
    let name: String
    let currency: String?
    let nameTranslations: [String: String]?
    
    enum CodingKeys: String, CodingKey {
        case code
        case name
        case currency
        case nameTranslations = "name_translations"
    }
    
    var localizedName: String {
        let currentLanguage = Locale.current.languageCode ?? "en"
        return nameTranslations?[currentLanguage] ?? name
    }
}

