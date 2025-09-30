//
//  Airport.swift
//  FlightAggregatorApp
//
//  Created by Alexandra Makey on 29.09.25.
//

import UIKit

// MARK: - Airport
struct Airport: Codable, Identifiable {
    let id = UUID()
    let code: String
    let name: String
    let cityCode: String?
    let cityName: String?
    let countryCode: String?
    let countryName: String?
    let timezone: String?
    let coordinates: Coordinates?
    
    enum CodingKeys: String, CodingKey {
        case code
        case name
        case cityCode = "city_code"
        case cityName = "city_name"
        case countryCode = "country_code"
        case countryName = "country_name"
        case timezone
        case coordinates
    }
}
