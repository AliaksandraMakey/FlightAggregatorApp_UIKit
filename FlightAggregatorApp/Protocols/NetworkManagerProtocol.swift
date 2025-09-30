//
//  NetworkManagerProtocol.swift
//  FlightAggregatorApp
//
//  Created by Alexandra Makey on 28.09.25.
//

import Foundation
import Combine

// MARK: - NetworkManager Protocol
protocol NetworkManagerProtocol {
    func loadAirports() async throws -> [Airport]
    func loadAirlines() async throws -> [Airline]
    func loadCities() async throws -> [City]
    func loadCountries() async throws -> [Country]
}
