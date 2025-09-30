//
//  FlightModels.swift
//  FlightAggregatorApp
//
//  Created by Alexandra Makey on 29.09.25.
//

import Foundation

// MARK: - Flight
struct Flight: Codable, Identifiable {
    let id = UUID()
    let value: Int
    let tripClass: Int
    let showToAffiliates: Bool
    let origin: String
    let destination: String
    let gateId: String?
    let departDate: String
    let returnDate: String?
    let numberOfChanges: Int
    let foundAt: String
    let duration: Int?
    let distance: Int
    let actual: Bool
    let expiresAt: String
    let airline: String?
    
    enum CodingKeys: String, CodingKey {
        case value
        case tripClass = "trip_class"
        case showToAffiliates = "show_to_affiliates"
        case origin
        case destination
        case gateId = "gate_id"
        case departDate = "depart_date"
        case returnDate = "return_date"
        case numberOfChanges = "number_of_changes"
        case foundAt = "found_at"
        case duration
        case distance
        case actual
        case expiresAt = "expires_at"
        case airline
    }
    
    // MARK: - Properties
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "RUB"
        return formatter.string(from: NSNumber(value: value)) ?? "\(value) ₽"
    }
    
    var departureDate: Date? {
        return departDate.apiDate
    }
    
    var returnDateFormatted: Date? {
        guard let returnDate = returnDate else { return nil }
        return returnDate.apiDate
    }
    
    // MARK: - FlightDetailViewModel
    var price: Int {
        return value
    }

    var departureTime: Date {
        return departureDate ?? Date()
    }
    
    var arrivalTime: Date {
        guard let duration = duration else {
            return departureTime.addingTimeInterval(2 * 3600)
        }
        return departureTime.addingTimeInterval(TimeInterval(duration * 60))
    }
    
    var flightNumber: String {
        let airlinePrefix = airline?.prefix(2).uppercased() ?? "FL"
        let routeHash = "\(origin)\(destination)".hash
        let flightNum = abs(routeHash) % 9000 + 1000
        return "\(airlinePrefix)\(flightNum)"
    }
    
    var airlineCode: String {
        return airline ?? "XX"
    }
    
    var status: FlightStatus {
        let now = Date()
        let timeUntilDeparture = departureTime.timeIntervalSince(now)
        let timeUntilArrival = arrivalTime.timeIntervalSince(now)
        
        if timeUntilArrival < -1800 {
            return .arrived
        }
        
        if timeUntilDeparture < -1800 && timeUntilArrival > 0 {
            return .departed
        }
        
        if timeUntilDeparture > 0 && timeUntilDeparture < 1800 {
            return .boarding
        }
        
        let flightHash = abs(flightNumber.hashValue)
        
        if flightHash % 50 == 0 {
            return .cancelled
        }
        
        if flightHash % 10 == 0 {
            return .delayed
        }
        
        return .scheduled
    }
    
    var isRoundTrip: Bool {
        return returnDate != nil
    }
    
    var changesDescription: String {
        switch numberOfChanges {
        case 0:
            return "flights.direct".localized
        case 1:
            return "flights.one.stop".localized
        default:
            return "flights.multiple.stops".localized(with: numberOfChanges)
        }
    }
    
    // MARK: - Formatted Properties
    func getFormattedAirlineName() -> String {
        return FlightFormattingService.shared.formatAirlineName(code: airline)
    }
    
    func getFormattedRoute() -> String {
        return FlightFormattingService.shared.formatRoute(origin: origin, destination: destination)
    }
   
    func getFormattedFlightInfo() -> String {
        return FlightFormattingService.shared.formatFlightInfo(flight: self)
    }
}





