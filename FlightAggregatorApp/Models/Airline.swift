//
//  Airline.swift
//  FlightAggregatorApp
//
//  Created by Alexandra Makey on 29.09.25.
//

import UIKit

// MARK: - Airline
struct Airline: Codable, Identifiable {
    let id = UUID()
    let code: String
    let name: String
    let nameTranslations: [String: String]?
    let isLowcost: Bool?
    let allianceCode: String?
    
    enum CodingKeys: String, CodingKey {
        case code
        case name
        case nameTranslations = "name_translations"
        case isLowcost = "is_lowcost"
        case allianceCode = "alliance_code"
    }
    
    var localizedName: String {
        let currentLanguage = Locale.current.languageCode ?? "en"
        return nameTranslations?[currentLanguage] ?? name
    }
}
