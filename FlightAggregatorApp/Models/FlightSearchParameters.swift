//
//  FlightSearchParameters.swift
//  FlightAggregatorApp
//
//  Created by Alexandra Makey on 29.09.25.
//

import UIKit

// MARK: - Search Parameters
struct FlightSearchParameters {
    let origin: String
    let destination: String
    let departDate: Date
    let returnDate: Date?
    let currency: String
    let language: String
    
    init(origin: String,
         destination: String,
         departDate: Date,
         returnDate: Date? = nil,
         currency: String = APIConfiguration.defaultCurrency,
         language: String = APIConfiguration.defaultLanguage) {
        self.origin = origin
        self.destination = destination
        self.departDate = departDate
        self.returnDate = returnDate
        self.currency = currency
        self.language = language
    }
    
    var queryParameters: [String: String] {
        var parameters: [String: String] = [
            "origin": origin,
            "destination": destination,
            "depart_date": departDate.apiString,
            "currency": currency,
            "token": APIConfiguration.apiToken
        ]
        
        if let returnDate = returnDate {
            parameters["return_date"] = returnDate.apiString
        }
        
        return parameters
    }
}

extension FlightSearchParameters: Codable {
    enum CodingKeys: String, CodingKey {
        case origin, destination, departDate, returnDate, currency, language
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        origin = try container.decode(String.self, forKey: .origin)
        destination = try container.decode(String.self, forKey: .destination)
        departDate = try container.decode(Date.self, forKey: .departDate)
        returnDate = try container.decodeIfPresent(Date.self, forKey: .returnDate)
        currency = try container.decode(String.self, forKey: .currency)
        language = try container.decode(String.self, forKey: .language)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(origin, forKey: .origin)
        try container.encode(destination, forKey: .destination)
        try container.encode(departDate, forKey: .departDate)
        try container.encodeIfPresent(returnDate, forKey: .returnDate)
        try container.encode(currency, forKey: .currency)
        try container.encode(language, forKey: .language)
    }
}
