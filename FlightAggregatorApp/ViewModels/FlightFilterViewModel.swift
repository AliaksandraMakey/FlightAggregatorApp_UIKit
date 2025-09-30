//
//  FlightFilterViewModel.swift
//  FlightAggregatorApp
//
//  Created by Alexandra Makey on 29.09.25.
//

import Foundation
import Combine


class FlightFilterViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var originInput: String = ""
    @Published var destinationInput: String = ""
    @Published var departureDate: Date = Date()
    @Published var returnDate: Date?
    @Published var isValidForm: Bool = false
    @Published var errorMessage: String?
    @Published var originCitySuggestions: [City] = []
    @Published var destinationCitySuggestions: [City] = []
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    // MARK: - Computed Properties
    var departureDateDisplayString: String {
        return departureDate.mediumString
    }
    var returnDateDisplayString: String? {
        return returnDate?.mediumString
    }
    var minimumReturnDate: Date {
        return departureDate
    }
    // MARK: - Init
    init() {
        setupValidation()
    }
    
    // MARK: - Public Methods
    func loadFilters(_ filters: FlightFilters?) {
        guard let filters = filters else {
            resetToDefaults()
            return
        }

        originInput = DataManager.shared.findRussianCityName(byCode: filters.origin) ?? filters.origin
        destinationInput = DataManager.shared.findRussianCityName(byCode: filters.destination) ?? filters.destination
        departureDate = filters.departureDate
        returnDate = filters.returnDate
        
//        AppLogger.shared.info("Filters loaded to ViewModel", category: .ui, metadata: [
//            "origin": originInput,
//            "destination": destinationInput,
//            "departure_date": departureDate.mediumString
//        ])
    }

    func createFilters() -> FlightFilters? {
        guard isValidForm else {
            errorMessage = "filters.validation.error".localized
            return nil
        }
  
        if DataManager.shared.cities.isEmpty {
            errorMessage = "cities.loading".localized
            return nil
        }
   
        guard let originCode = convertInputToCode(originInput.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            errorMessage = String(format: "origin.not.found".localized, originInput)
            return nil
        }
        
        guard let destinationCode = convertInputToCode(destinationInput.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            errorMessage = String(format: "destination.not.found".localized, destinationInput)
            return nil
        }
        
        let filters = FlightFilters(
            origin: originCode.uppercased(),
            destination: destinationCode.uppercased(),
            departureDate: departureDate,
            returnDate: returnDate
        )
        
        return filters
    }

    func resetToDefaults() {
        originInput = ""
        destinationInput = ""
        departureDate = Date()
        returnDate = nil
        errorMessage = nil
        originCitySuggestions = []
        destinationCitySuggestions = []
        
        AppLogger.shared.info("Filters reset to defaults", category: .ui)
    }

    func setDepartureDate(_ date: Date) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let selectedDay = calendar.startOfDay(for: date)
        
        if selectedDay < today {
            errorMessage = "date.past.error".localized
            AppLogger.shared.warning("Attempted to set past date", category: .ui, metadata: [
                "selected_date": date.mediumString,
                "today": Date().mediumString
            ])
            return
        }
        
        errorMessage = nil
        departureDate = date
        
        if let returnDate = returnDate, returnDate < date {
            self.returnDate = nil
        }
        AppLogger.shared.info("Departure date set", category: .ui, metadata: [
            "date": date.mediumString
        ])
    }
    
    func setReturnDate(_ date: Date?) {
        guard let date = date else {
            returnDate = nil
            return
        }
        if date < departureDate {
            errorMessage = "date.return.before.departure".localized
            AppLogger.shared.warning("Return date before departure date", category: .ui, metadata: [
                "return_date": date.mediumString,
                "departure_date": departureDate.mediumString
            ])
            return
        }
        
        errorMessage = nil
        returnDate = date
        
//        AppLogger.shared.info("Return date set", category: .ui, metadata: [
//            "date": date.mediumString
//        ])
    }
    
    // MARK: - Private Methods
    private func setupValidation() {
        Publishers.CombineLatest3($originInput, $destinationInput, $departureDate)
            .map { [weak self] origin, destination, _ in
                guard let self = self else { return false }
                return !origin.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                       !destination.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
            .assign(to: \.isValidForm, on: self)
            .store(in: &cancellables)
        
        Publishers.CombineLatest($originInput, $destinationInput)
            .sink { [weak self] _, _ in
                self?.errorMessage = nil
            }
            .store(in: &cancellables)
        
        $originInput
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] input in
                self?.updateOriginSuggestions(for: input)
            }
            .store(in: &cancellables)
        
        $destinationInput
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] input in
                self?.updateDestinationSuggestions(for: input)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Helper Methods
    private func convertInputToCode(_ input: String) -> String? {
        guard !input.isEmpty else { return nil }
        
        if let cityCode = DataManager.shared.findCityCode(byName: input) {
            return cityCode
        }
        
        let airports = DataManager.shared.searchAirports(query: input)
        if let airport = airports.first(where: { 
            $0.name.lowercased() == input.lowercased() || 
            $0.code.lowercased() == input.lowercased() 
        }) {
            return airport.code
        }
        
        if input.count == 3 && input.allSatisfy({ $0.isLetter }) {
            return input
        }
        
        return nil
    }
    
    private func updateOriginSuggestions(for input: String) {
        guard input.count >= 2 else {
            originCitySuggestions = []
            return
        }
        
        originCitySuggestions = DataManager.shared.searchCities(query: input)
    }
    
    private func updateDestinationSuggestions(for input: String) {
        guard input.count >= 2 else {
            destinationCitySuggestions = []
            return
        }
        
        destinationCitySuggestions = DataManager.shared.searchCities(query: input)
    }
}

