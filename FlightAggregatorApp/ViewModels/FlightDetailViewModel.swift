//
//  FlightDetailViewModel.swift
//  FlightAggregatorApp
//
//  Created by Alexandra Makey on 30.09.25.
//

import Foundation
import Combine

class FlightDetailViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var flight: Flight
    @Published var originAirport: Airport?
    @Published var destinationAirport: Airport?
    @Published var airline: Airline?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let dataManager: DataManager
    private let flightFormattingService: FlightFormattingService
    // MARK: - Computed Properties
    var flightDuration: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        
        let duration = flight.arrivalTime.timeIntervalSince(flight.departureTime)
        return formatter.string(from: duration) ?? "N/A"
    }
    
    var formattedPrice: String {
        return flightFormattingService.formatPrice(flight.price, currency: "RUB")
    }
    
    var formattedDepartureTime: String {
        return flight.departureTime.timeString
    }
    
    var formattedArrivalTime: String {
        return flight.arrivalTime.timeString
    }
    
    var formattedDepartureDate: String {
        return flight.departureTime.displayString
    }
    
    var originCityName: String {
        return flightFormattingService.formatLocation(
            code: flight.origin,
            airports: [originAirport].compactMap { $0 },
            cities: dataManager.cities
        )
    }
    
    var destinationCityName: String {
        return flightFormattingService.formatLocation(
            code: flight.destination,
            airports: [destinationAirport].compactMap { $0 },
            cities: dataManager.cities
        )
    }
    
    var airlineName: String {
        return flightFormattingService.formatAirline(
            code: flight.airlineCode,
            airlines: dataManager.airlines
        )
    }
    
    // MARK: - Init
    init(
        flight: Flight,
        dataManager: DataManager = DataManager.shared,
        flightFormattingService: FlightFormattingService = FlightFormattingService.shared
    ) {
        self.flight = flight
        self.dataManager = dataManager
        self.flightFormattingService = flightFormattingService
        
        loadDetailedData()
    }
    
    // MARK: - Public Methods
    func loadDetailedData() {
        isLoading = true
        errorMessage = nil
        
        Task { @MainActor in
            do {
                await loadAirportDetails()
                await loadAirlineDetails()
//                
//                AppLogger.shared.info("Flight details loaded successfully", category: .flight, metadata: [
//                    "flight_number": flight.flightNumber,
//                    "origin": flight.origin,
//                    "destination": flight.destination
//                ])
//                
                isLoading = false
            } catch {
                handleError(error)
            }
        }
    }
    
    func refresh() {
        loadDetailedData()
    }
    
    // MARK: - Private Methods
    @MainActor
    private func loadAirportDetails() async {
        originAirport = dataManager.airports.first { airport in
            airport.code == flight.origin || airport.cityCode == flight.origin
        }
        
        destinationAirport = dataManager.airports.first { airport in
            airport.code == flight.destination || airport.cityCode == flight.destination
        }
        
        //        AppLogger.shared.debug("Airport details loaded", category: .flight, metadata: [
        //            "origin_airport": originAirport?.name ?? "Not found",
        //            "destination_airport": destinationAirport?.name ?? "Not found"
        //        ])
    }
    
    @MainActor
    private func loadAirlineDetails() async {
        airline = dataManager.airlines.first { $0.code == flight.airlineCode }
        
        //        AppLogger.shared.debug("Airline details loaded", category: .flight, metadata: [
        //            "airline": airline?.name ?? "Not found",
        //            "airline_code": flight.airlineCode
        //        ])
    }
    
    private func handleError(_ error: Error) {
        isLoading = false
        errorMessage = error.localizedDescription
        AppLogger.shared.error("Failed to load flight details", category: .flight, metadata: [
            "error": error.localizedDescription
        ])
    }
}

// MARK: - extension
extension FlightDetailViewModel {
    var isLoadingPublisher: AnyPublisher<Bool, Never> {
        $isLoading.eraseToAnyPublisher()
    }
    
    var flightPublisher: AnyPublisher<Flight, Never> {
        $flight.eraseToAnyPublisher()
    }
    
    var errorPublisher: AnyPublisher<String?, Never> {
        $errorMessage.eraseToAnyPublisher()
    }
    
    var detailStatePublisher: AnyPublisher<(flight: Flight, isLoading: Bool, hasError: Bool), Never> {
        Publishers.CombineLatest3($flight, $isLoading, $errorMessage)
            .map { (flight: $0, isLoading: $1, hasError: $2 != nil) }
            .eraseToAnyPublisher()
    }
}
