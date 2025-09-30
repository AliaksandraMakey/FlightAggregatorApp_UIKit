//
//  Coordinates.swift
//  FlightAggregatorApp
//
//  Created by Alexandra Makey on 29.09.25.
//

import UIKit

// MARK: - Coordinates
struct Coordinates: Codable {
    let latitude: Double
    let longitude: Double
    
    enum CodingKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "lon"
    }
}
