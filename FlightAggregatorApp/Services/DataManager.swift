//
//  DataManager.swift
//  FlightAggregatorApp
//
//  Created by Alexandra Makey on 29.09.25.
//

import Foundation
import Combine

// MARK: - DataManager
class DataManager: ObservableObject {
    // MARK: - Singleton
    static let shared = DataManager()
    
    // MARK: - Published Properties
    @Published var airports: [Airport] = []
    @Published var airlines: [Airline] = []
    @Published var cities: [City] = []
    @Published var countries: [Country] = []
    @Published var recentSearches: [FlightSearchParameters] = []
    
    // MARK: - Private Properties
    private let networkManager: NetworkManagerProtocol
    private let userDefaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Cache Keys
    private enum CacheKeys {
        static let airports = "cached_airports"
        static let airlines = "cached_airlines"
        static let cities = "cached_cities"
        static let countries = "cached_countries"
        static let recentSearches = "recent_searches"
        static let lastUpdateTime = "last_update_time"
    }
    
    // MARK: - Services
    private let translationService = CityTranslationService.shared
    
    // MARK: - Init
    private init(networkManager: NetworkManagerProtocol = NetworkManager.shared) {
        self.networkManager = networkManager
        loadCachedData()
    }
    
    // MARK: - Public Methods
    func loadAllStaticData() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadAirportsData() }
            group.addTask { await self.loadAirlinesData() }
            group.addTask { await self.loadCitiesData() }
            group.addTask { await self.loadCountriesData() }
        }
    }

    func searchAirports(query: String) -> [Airport] {
        guard !query.isEmpty else { return airports }
        
        let lowercasedQuery = query.lowercased()
        return airports.filter { airport in
            airport.code.lowercased().contains(lowercasedQuery) ||
            airport.name.lowercased().contains(lowercasedQuery) ||
            airport.cityName?.lowercased().contains(lowercasedQuery) == true
        }
    }

    func searchCities(query: String) -> [City] {
        guard !query.isEmpty else { return cities }
        
        let lowercasedQuery = query.lowercased()
        var results: [City] = []

        let translationResults = translationService.searchCities(query: lowercasedQuery)
        for (_, englishName) in translationResults {
            if let city = cities.first(where: { $0.name.lowercased() == englishName.lowercased() }) {
                results.append(city)
            }
        }
    
        let englishResults = cities.filter { city in
            city.code.lowercased().contains(lowercasedQuery) ||
            city.name.lowercased().contains(lowercasedQuery)
        }

        for city in englishResults {
            if !results.contains(where: { $0.code == city.code }) {
                results.append(city)
            }
        }
        
        return Array(results)
    }

    func findCityCode(byName cityName: String) -> String? {
        let trimmedName = cityName.trimmingCharacters(in: .whitespacesAndNewlines)
        let lowercaseName = trimmedName.lowercased()
        
        if let englishName = translationService.translateToEnglish(russianCityName: trimmedName) {
            if let cityWithEnglishName = cities.first(where: { $0.name.lowercased() == englishName.lowercased() }) {
                return cityWithEnglishName.code
            }
        }

        if let exactMatch = cities.first(where: { $0.name.lowercased() == lowercaseName }) {
            return exactMatch.code
        }

        if let prefixMatch = cities.first(where: { $0.name.lowercased().hasPrefix(lowercaseName) }) {
            return prefixMatch.code
        }
  
        if let codeMatch = cities.first(where: { $0.code.lowercased() == lowercaseName }) {
            return codeMatch.code
        }
        
        return nil
    }

    func findCityName(byCode cityCode: String) -> String? {
        return cities.first(where: { $0.code.lowercased() == cityCode.lowercased() })?.name
    }

    func findRussianCityName(byCode cityCode: String) -> String? {
        guard let englishName = findCityName(byCode: cityCode) else { return nil }
        
        if let russianName = translationService.translateToRussian(englishCityName: englishName) {
            return russianName
        }

        return englishName
    }
    // MARK: - Private Methods
    private func loadAirportsData() async {
        do {
            let fetchedAirports = try await networkManager.loadAirports()
            
            await MainActor.run {
                self.airports = fetchedAirports
            }
            
            cacheData(fetchedAirports, forKey: CacheKeys.airports)
            AppLogger.shared.success("Airports loaded and cached", category: .cache, metadata: ["count": fetchedAirports.count])
            
        } catch {
            AppError.from(error: error).log()
            AppLogger.shared.warning("Falling back to cached airports data", category: .cache)
            loadCachedAirports()
        }
    }
    
    private func loadAirlinesData() async {
        do {
            let fetchedAirlines = try await networkManager.loadAirlines()
            
            await MainActor.run {
                self.airlines = fetchedAirlines
            }
            
            cacheData(fetchedAirlines, forKey: CacheKeys.airlines)
            AppLogger.shared.success("Airlines loaded and cached", category: .cache, metadata: ["count": fetchedAirlines.count])
            
        } catch {
            AppError.from(error: error).log()
            AppLogger.shared.warning("Falling back to cached airlines data", category: .cache)
            loadCachedAirlines()
        }
    }
    
    private func loadCitiesData() async {
        do {
            let fetchedCities = try await networkManager.loadCities()
            
            await MainActor.run {
                self.cities = fetchedCities
            }
            
            cacheData(fetchedCities, forKey: CacheKeys.cities)
            AppLogger.shared.success("Cities loaded and cached", category: .cache, metadata: ["count": fetchedCities.count])
            
        } catch {
            AppError.from(error: error).log()
            AppLogger.shared.warning("Falling back to cached cities data", category: .cache)
            loadCachedCities()
        }
    }
    
    private func loadCountriesData() async {
        do {
            let fetchedCountries = try await networkManager.loadCountries()
            
            await MainActor.run {
                self.countries = fetchedCountries
            }
            
            cacheData(fetchedCountries, forKey: CacheKeys.countries)
            AppLogger.shared.success("Countries loaded and cached", category: .cache, metadata: ["count": fetchedCountries.count])
            
        } catch {
            AppError.from(error: error).log()
            AppLogger.shared.warning("Falling back to cached countries data", category: .cache)
            loadCachedCountries()
        }
    }
    
    // MARK: - Caching Methods
    private func cacheData<T: Codable>(_ data: T, forKey key: String) {
        do {
            let encoded = try JSONEncoder().encode(data)
            userDefaults.set(encoded, forKey: key)
            userDefaults.set(Date(), forKey: CacheKeys.lastUpdateTime)
        } catch {
            AppLogger.shared.error("Failed to cache data", category: .cache, metadata: ["key": key, "error": error.localizedDescription])
        }
    }
    
    private func loadCachedData() {
        loadCachedAirports()
        loadCachedAirlines()
        loadCachedCities()
        loadCachedCountries()
        loadRecentSearches()
    }
    
    private func loadCachedAirports() {
        if let data = userDefaults.data(forKey: CacheKeys.airports) {
            do {
                airports = try JSONDecoder().decode([Airport].self, from: data)
                AppLogger.shared.info("Loaded airports from cache", category: .cache, metadata: ["count": airports.count])
            } catch {
                AppLogger.shared.error("Failed to decode cached airports", category: .cache, metadata: ["error": error.localizedDescription])
            }
        }
    }
    
    private func loadCachedAirlines() {
        if let data = userDefaults.data(forKey: CacheKeys.airlines) {
            do {
                airlines = try JSONDecoder().decode([Airline].self, from: data)
                AppLogger.shared.info("Loaded airlines from cache", category: .cache, metadata: ["count": airlines.count])
            } catch {
                AppLogger.shared.error("Failed to decode cached airlines", category: .cache, metadata: ["error": error.localizedDescription])
            }
        }
    }
    
    private func loadCachedCities() {
        if let data = userDefaults.data(forKey: CacheKeys.cities) {
            do {
                cities = try JSONDecoder().decode([City].self, from: data)
                AppLogger.shared.info("Loaded cities from cache", category: .cache, metadata: ["count": cities.count])
            } catch {
                AppLogger.shared.error("Failed to decode cached cities", category: .cache, metadata: ["error": error.localizedDescription])
            }
        }
    }
    
    private func loadCachedCountries() {
        if let data = userDefaults.data(forKey: CacheKeys.countries) {
            do {
                countries = try JSONDecoder().decode([Country].self, from: data)
                AppLogger.shared.info("Loaded countries from cache", category: .cache, metadata: ["count": countries.count])
            } catch {
                AppLogger.shared.error("Failed to decode cached countries", category: .cache, metadata: ["error": error.localizedDescription])
            }
        }
    }
    
    private func loadRecentSearches() {
        if let data = userDefaults.data(forKey: CacheKeys.recentSearches) {
            do {
                recentSearches = try JSONDecoder().decode([FlightSearchParameters].self, from: data)
                AppLogger.shared.info("Loaded recent searches from cache", category: .cache, metadata: ["count": recentSearches.count])
            } catch {
                AppLogger.shared.error("Failed to decode recent searches", category: .cache, metadata: ["error": error.localizedDescription])
            }
        }
    }
}
