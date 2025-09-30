//
//  City.swift
//  FlightAggregatorApp
//
//  Created by Alexandra Makey on 29.09.25.
//

import UIKit

// MARK: - City
struct City: Codable, Identifiable {
    let id = UUID()
    let code: String
    let name: String
    let countryCode: String
    let timezone: String?
    let coordinates: Coordinates?
    
    enum CodingKeys: String, CodingKey {
        case code
        case name
        case countryCode = "country_code"
        case timezone
        case coordinates
    }
}
