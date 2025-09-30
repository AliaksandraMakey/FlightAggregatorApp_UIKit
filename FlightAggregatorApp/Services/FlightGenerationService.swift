//
//  FlightGenerationService.swift
//  FlightAggregatorApp
//
//  Created by Alexandra Makey on 29.09.25.
//

import Foundation

// MARK: - FlightGenerationService
class FlightGenerationService {
    // MARK: - Singleton
    static let shared = FlightGenerationService()
    // MARK: - Configuration
    private struct GenerationConfig {
        static let maxAirportsForGeneration = 25
        static let maxDestinationsPerOrigin = 30
        static let flightsPerRouteRange = 2...4
        static let priceRange = 4000...20000
        static let durationRange = 60...300
        static let changesRange = 0...2
        static let daysOffsetRange = 1...7
        static let distanceRange = 200...3000
        static let expirationTimeInterval: TimeInterval = 3600
    }
    
    private let formattingService: FlightFormattingService
    
    private init(formattingService: FlightFormattingService = FlightFormattingService.shared) {
        self.formattingService = formattingService
    }
    
    // MARK: - Public Methods
    func generateFlightsFromCachedData() -> [Flight] {
        AppLogger.shared.info("Generating flights from cached static data", category: .flight)
        
        let availableAirports = getAvailableAirports()
        let availableAirlines = getAvailableAirlines()
        
        guard !availableAirports.isEmpty, !availableAirlines.isEmpty else {
            AppLogger.shared.warning("No airports or airlines available for flight generation", category: .flight, metadata: [
                "airports_count": availableAirports.count,
                "airlines_count": availableAirlines.count
            ])
            return []
        }
        
        let flights = generateFlightsBetweenAirports(
            airports: availableAirports,
            airlines: availableAirlines
        )
        
        let sortedFlights = flights.sorted { $0.value < $1.value }
        
        AppLogger.shared.success("Generated flights from cached data", category: .flight, metadata: [
            "flights_count": sortedFlights.count,
            "airports_used": availableAirports.count,
            "airlines_available": availableAirlines.count
        ])
        
        return sortedFlights
    }
    
    func generateFilteredFlights(filters: FlightFilters) -> [Flight] {
        AppLogger.shared.info("Generating filtered flights from cached data", category: .flight, metadata: [
            "origin": filters.origin,
            "destination": filters.destination
        ])
        
        guard let originAirport = findAirport(by: filters.origin),
              let destinationAirport = findAirport(by: filters.destination) else {
            AppLogger.shared.warning("Airports not found in cache", category: .flight, metadata: [
                "origin": filters.origin,
                "destination": filters.destination,
                "available_airports_count": DataManager.shared.airports.count
            ])
            return []
        }
        
        let availableAirlines = getAvailableAirlines()
        let flights = generateFlightsForRoute(
            origin: originAirport,
            destination: destinationAirport,
            airlines: availableAirlines,
            filters: filters
        )
        
        return flights.sorted { $0.value < $1.value }
    }
    
    // MARK: - Private Methods
    private func getAvailableAirports() -> [Airport] {
        let popularAirportCodes = [
            "MOW", "LED", "AER", "KZN", "UFA", "ROV", "KRR", "VOG", "SVX", "OVB",
            "JFK", "LAX", "ORD", "DFW", "DEN", "ATL", "BOS", "SFO", "SEA", "MIA",
            "LHR", "CDG", "FRA", "AMS", "MAD", "FCO", "LGW", "MUC", "ZUR", "VIE",
            "DXB", "DOH", "AUH", "CAI", "JED", "RUH", "KWI", "BAH", "MCT", "AMM",
            "NRT", "ICN", "SIN", "BKK", "HKG", "PVG", "PEK", "DEL", "BOM", "CCU",
            "CMB", "CGK", "KUL", "MNL", "TPE", "HAN", "SGN", "RGN", "DAD", "CAN",
            "SYD", "MEL", "YYZ", "YVR", "GRU", "EZE", "LIM", "BOG", "SCL", "PTY"
        ]
        
        var availableAirports: [Airport] = []
        for code in popularAirportCodes {
            if let airport = DataManager.shared.airports.first(where: { $0.code == code }) {
                availableAirports.append(airport)
            }
        }
        
        if availableAirports.isEmpty {
            availableAirports = Array(DataManager.shared.airports.filter { 
                $0.cityName != nil && !$0.cityName!.isEmpty
            }.prefix(30))
        }
        
        return availableAirports
    }
    
    private func getAvailableAirlines() -> [Airline] {
        return DataManager.shared.airlines.filter { !$0.name.isEmpty }
    }
    
    private func findAirport(by searchString: String) -> Airport? {
        let searchTerm = searchString.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let airport = DataManager.shared.airports.first(where: { $0.code.uppercased() == searchTerm }) {
            AppLogger.shared.info("Airport found by code", category: .flight, metadata: [
                "search_term": searchTerm,
                "found_airport": airport.code,
                "city": airport.cityName ?? "N/A"
            ])
            return airport
        }
        
        if let airport = DataManager.shared.airports.first(where: {
            $0.cityName?.uppercased() == searchTerm
        }) {
            AppLogger.shared.info("Airport found by city name", category: .flight, metadata: [
                "search_term": searchTerm,
                "found_airport": airport.code,
                "city": airport.cityName ?? "N/A"
            ])
            return airport
        }
        
        if let airport = DataManager.shared.airports.first(where: {
            $0.cityName?.uppercased().contains(searchTerm) == true
        }) {
            AppLogger.shared.info("Airport found by city name contains", category: .flight, metadata: [
                "search_term": searchTerm,
                "found_airport": airport.code,
                "city": airport.cityName ?? "N/A"
            ])
            return airport
        }
        
        if let airport = DataManager.shared.airports.first(where: {
            $0.name.uppercased().contains(searchTerm)
        }) {
            AppLogger.shared.info("Airport found by airport name", category: .flight, metadata: [
                "search_term": searchTerm,
                "found_airport": airport.code,
                "airport_name": airport.name
            ])
            return airport
        }
        
        AppLogger.shared.warning("Airport not found", category: .flight, metadata: [
            "search_term": searchTerm,
            "total_airports": DataManager.shared.airports.count
        ])
        return nil
    }
    
    private func generateFlightsBetweenAirports(airports: [Airport], airlines: [Airline]) -> [Flight] {
        var flights: [Flight] = []
        
        for i in 0..<min(airports.count, GenerationConfig.maxAirportsForGeneration) {
            for j in (i+1)..<min(airports.count, GenerationConfig.maxDestinationsPerOrigin) {
                let origin = airports[i]
                let destination = airports[j]
                
                let routeFlights = generateFlightsForSingleRoute(
                    origin: origin,
                    destination: destination,
                    airlines: airlines,
                    routeIndex: (i, j)
                )
                
                flights.append(contentsOf: routeFlights)
            }
        }
        
        return flights
    }
    
    private func generateFlightsForSingleRoute(
        origin: Airport,
        destination: Airport,
        airlines: [Airline],
        routeIndex: (Int, Int)
    ) -> [Flight] {
        let flightsPerRoute = Int.random(in: GenerationConfig.flightsPerRouteRange)
        var flights: [Flight] = []
        
        for flightIndex in 0..<flightsPerRoute {
            let airline = airlines.randomElement()
            let basePrice = Int.random(in: GenerationConfig.priceRange)
            let duration = Int.random(in: GenerationConfig.durationRange)
            let numberOfChanges = Int.random(in: GenerationConfig.changesRange)
            
            let daysOffset = Int.random(in: GenerationConfig.daysOffsetRange)
            let departureDate = Calendar.current.date(byAdding: .day, value: daysOffset, to: Date()) ?? Date()
            
            let flight = Flight(
                value: basePrice,
                tripClass: 0,
                showToAffiliates: true,
                origin: origin.code,
                destination: destination.code,
                gateId: "gate_\(routeIndex.0)_\(routeIndex.1)_\(flightIndex)",
                departDate: formattingService.formatDate(departureDate),
                returnDate: nil,
                numberOfChanges: numberOfChanges,
                foundAt: formattingService.formatDate(Date()),
                duration: duration,
                distance: Int.random(in: GenerationConfig.distanceRange),
                actual: true,
                expiresAt: formattingService.formatDate(Date().addingTimeInterval(GenerationConfig.expirationTimeInterval)),
                airline: airline?.code
            )
            
            flights.append(flight)
        }
        
        return flights
    }
    
    private func generateFlightsForRoute(
        origin: Airport,
        destination: Airport,
        airlines: [Airline],
        filters: FlightFilters
    ) -> [Flight] {
        var flights: [Flight] = []
        
        let flightCount = Int.random(in: 3...8)
        
        for index in 0..<flightCount {
            let airline = airlines.randomElement()
            let basePrice = Int.random(in: 3000...25000)
            let duration = Int.random(in: 60...420)
            let numberOfChanges = Int.random(in: GenerationConfig.changesRange)
            
            let daysOffset = Int.random(in: 0...6)
            let hoursOffset = Int.random(in: 6...23)
            
            var departureDate = Calendar.current.date(byAdding: .day, value: daysOffset, to: filters.departureDate) ?? filters.departureDate
            departureDate = Calendar.current.date(byAdding: .hour, value: hoursOffset, to: departureDate) ?? departureDate
            
            let flight = Flight(
                value: basePrice,
                tripClass: 0,
                showToAffiliates: true,
                origin: filters.origin,
                destination: filters.destination,
                gateId: "cached_\(index)",
                departDate: formattingService.formatDate(departureDate),
                returnDate: filters.returnDate != nil ? formattingService.formatDate(filters.returnDate!) : nil,
                numberOfChanges: numberOfChanges,
                foundAt: formattingService.formatDate(Date()),
                duration: duration,
                distance: Int.random(in: 200...2500),
                actual: true,
                expiresAt: formattingService.formatDate(Date().addingTimeInterval(7200)),
                airline: airline?.code
            )
            
            flights.append(flight)
        }
        
        return flights
    }
}
