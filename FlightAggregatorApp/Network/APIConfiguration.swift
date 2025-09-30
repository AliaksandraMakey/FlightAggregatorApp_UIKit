//
//  APIConfiguration.swift
//  FlightAggregatorApp
//
//  Created by Alexandra Makey on 29.09.25.
//

import Foundation

struct APIConfiguration {
    // MARK: - Settings
    static let baseURL = "https://api.travelpayouts.com"
    
    // API  Travelpayouts (Aviasales)
    // https://www.travelpayouts.com/programs/100/tools/api
    static let apiToken = "f77d861033413718371d3f2ef1902aa3"
    
    static let partnerID = "675796"
    
    // MARK: - Endpoints
    enum Endpoints {
        case cheapestTickets
        case countries
        case cities
        case airports
        case airlines
        case calendar
        
        var path: String {
            switch self {
            case .cheapestTickets:
                return "/v1/prices/cheap"
            case .countries:
                return "/data/countries.json"
            case .cities:
                return "/data/cities.json"
            case .airports:
                return "/data/airports.json"
            case .airlines:
                return "/data/airlines.json"
            case .calendar:
                return "/v1/prices/calendar"
            }
        }
        
        var fullURL: String {
            return APIConfiguration.baseURL + path
        }
    }
    
    // MARK: - HTTP Headers
    static var defaultHeaders: [String: String] {
        return [
            "X-Access-Token": apiToken,
            "Accept-Encoding": "gzip, deflate",
            "Content-Type": "application/json"
        ]
    }
    
    // MARK: - Request Config
    //TODO: - Added other currency
    static let requestTimeout: TimeInterval = 30.0
    static let defaultCurrency = "RUB"
    static let defaultLanguage = "ru"
}

// MARK: - Response Structure
struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let error: String?
}
