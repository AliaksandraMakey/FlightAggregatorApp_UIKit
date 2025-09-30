//
//  FlightViewModel.swift
//  FlightAggregatorApp
//
//  Created by Alexandra Makey on 29.09.25.
//

import Foundation
import Combine

// MARK: - FlightViewModel
class FlightViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var flights: [Flight] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var currentFilters: FlightFilters?
    @Published var hasMoreFlights: Bool = false
    
    // MARK: - Public Properties
    var totalAvailableFlights: Int {
        return allGeneratedFlights.count
    }
    
    // MARK: - Private Properties
    private var allGeneratedFlights: [Flight] = []
    private var currentPage = 0
    private let flightsPerPage = 50
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Services
    private let flightGenerationService: FlightGenerationService
    private let dataManager: DataManager
    // MARK: - Publishers
    var isLoadingPublisher: AnyPublisher<Bool, Never> {
        $isLoading.eraseToAnyPublisher()
    }
    var flightsPublisher: AnyPublisher<[Flight], Never> {
        $flights.eraseToAnyPublisher()
    }
    var errorPublisher: AnyPublisher<String?, Never> {
        $errorMessage.eraseToAnyPublisher()
    }
    var uiStatePublisher: AnyPublisher<(flights: [Flight], isLoading: Bool, hasMore: Bool), Never> {
        Publishers.CombineLatest3($flights, $isLoading, $hasMoreFlights)
            .map { (flights: $0, isLoading: $1, hasMore: $2) }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    init(
        flightGenerationService: FlightGenerationService = FlightGenerationService.shared,
        dataManager: DataManager = DataManager.shared
    ) {
        self.flightGenerationService = flightGenerationService
        self.dataManager = dataManager
        
        setupDataObservers()
    }
    
    // MARK: - Public Methods
    func loadFlights() {
        AppLogger.shared.info("ViewModel loadFlights called", category: .flight)
        isLoading = true
        errorMessage = nil
        
        if dataManager.airports.isEmpty || dataManager.airlines.isEmpty {
            AppLogger.shared.info("Waiting for static data to load", category: .flight, metadata: [
                "airports_count": dataManager.airports.count,
                "airlines_count": dataManager.airlines.count
            ])
            waitForStaticData()
        } else {
            AppLogger.shared.info("Static data ready, generating flights", category: .flight)
            Task { @MainActor in
                await generateAndLoadFlights()
            }
        }
    }
    
    func searchFlights(with filters: FlightFilters) {
        currentFilters = filters
        isLoading = true
        errorMessage = nil
        
        Task { @MainActor in
            do {
                allGeneratedFlights = flightGenerationService.generateFilteredFlights(filters: filters)
                resetPagination()
                
                isLoading = false
                loadNextPage()
                
                if allGeneratedFlights.isEmpty {
                    errorMessage = "No flights found for your search."
                }
//                
//                AppLogger.shared.info("Filtered flights loaded", category: .ui, metadata: [
//                    "total_flights": allGeneratedFlights.count,
//                    "origin": filters.origin,
//                    "destination": filters.destination
//                ])
                
            } catch {
                handleError(error)
            }
        }
    }
    
    func clearFilters() {
        currentFilters = nil
        loadFlights()
    }
    
    func loadNextPage() {
        guard !isLoading else {
            AppLogger.shared.debug("LoadNextPage skipped - already loading", category: .ui)
            return
        }
        
        let startIndex = currentPage * flightsPerPage
        let endIndex = min(startIndex + flightsPerPage, allGeneratedFlights.count)
        
        guard startIndex < allGeneratedFlights.count else {
            hasMoreFlights = false
            AppLogger.shared.info("No more flights to load", category: .ui)
            return
        }
        
        let newFlights = Array(allGeneratedFlights[startIndex..<endIndex])
        
        if currentPage == 0 {
            flights = newFlights
        } else {
            flights.append(contentsOf: newFlights)
        }
        
        currentPage += 1
        hasMoreFlights = flights.count < allGeneratedFlights.count
        
//        AppLogger.shared.info("Loaded page of flights", category: .ui, metadata: [
//            "page": currentPage,
//            "flights_on_page": newFlights.count,
//            "total_displayed": flights.count,
//            "total_available": allGeneratedFlights.count,
//            "has_more_flights": hasMoreFlights,
//            "can_load_more": flights.count < allGeneratedFlights.count
//        ])
    }
    
    func refreshFlights() {
        if let filters = currentFilters {
            searchFlights(with: filters)
        } else {
            loadFlights()
        }
    }
    
    // MARK: - Private Methods
    private func setupDataObservers() {
        Publishers.CombineLatest(
            dataManager.$airports,
            dataManager.$airlines
        )
        .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
        .sink { [weak self] airports, airlines in
            if !airports.isEmpty && !airlines.isEmpty {
                AppLogger.shared.debug("Static data ready for flight generation", category: .flight, metadata: [
                    "airports": airports.count,
                    "airlines": airlines.count
                ])
            }
        }
        .store(in: &cancellables)
    }
    
    private func waitForStaticData() {
        Task { @MainActor in
            try await Task.sleep(nanoseconds: 500_000_000)
            await generateAndLoadFlights()
        }
    }
    
    @MainActor
    private func generateAndLoadFlights() async {
        do {
            allGeneratedFlights = flightGenerationService.generateFlightsFromCachedData()
            resetPagination()
            
            isLoading = false
            loadNextPage()
//            
//            AppLogger.shared.info("All flights generated from cached data", category: .ui, metadata: [
//                "total_flights": allGeneratedFlights.count,
//                "showing_page": currentPage
//            ])
//            
        } catch {
            handleError(error)
        }
    }
    
    private func resetPagination() {
        currentPage = 0
        flights.removeAll()
        hasMoreFlights = !allGeneratedFlights.isEmpty
    }
    
    private func handleError(_ error: Error) {
        isLoading = false
        errorMessage = error.localizedDescription
        AppLogger.shared.error("ViewModel error", category: .ui, metadata: [
            "error": error.localizedDescription
        ])
    }
}

