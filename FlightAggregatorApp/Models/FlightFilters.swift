//
//  FlightFilters.swift
//  FlightAggregatorApp
//
//  Created by Alexandra Makey on 28.09.25.
//

import UIKit

// MARK: - FlightFilters
struct FlightFilters {
    let origin: String
    let destination: String
    let departureDate: Date
    let returnDate: Date?
    
    init(origin: String, destination: String, departureDate: Date, returnDate: Date? = nil) {
        self.origin = origin
        self.destination = destination
        self.departureDate = departureDate
        self.returnDate = returnDate
    }
}
