//
//  NetworkManager.swift
//  FlightAggregatorApp
//
//  Created by Alexandra Makey on 28.09.25.
//

import Foundation
import Combine

// MARK: - NetworkManager
class NetworkManager: NetworkManagerProtocol {
    // MARK: - Singleton
    static let shared = NetworkManager()
    // MARK: - Properties
    private let session: URLSession
    private let decoder: JSONDecoder
    // MARK: - Init
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = APIConfiguration.requestTimeout
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        self.session = URLSession(configuration: config)
        self.decoder = JSONDecoder()
        
        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601)
    }
    
    // MARK: -  Request
    private func request<T: Codable>(
        endpoint: APIConfiguration.Endpoints,
        parameters: [String: String] = [:],
        responseType: T.Type
    ) async throws -> T {
        
        guard var urlComponents = URLComponents(string: endpoint.fullURL) else {
            throw AppError.invalidURL("Failed to create URL components from: \(endpoint.fullURL)")
        }
        
        if !parameters.isEmpty {
            urlComponents.queryItems = parameters.map { 
                URLQueryItem(name: $0.key, value: $0.value) 
            }
        }
        
        guard let url = urlComponents.url else {
            throw AppError.invalidURL("Failed to create URL from components: \(urlComponents)")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        APIConfiguration.defaultHeaders.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                guard 200...299 ~= httpResponse.statusCode else {
                    if httpResponse.statusCode == 401 {
                        throw AppError.invalidToken("API token is invalid or expired")
                    }
                    throw AppError.networkError("HTTP error with status code: \(httpResponse.statusCode)")
                }
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                AppLogger.shared.debug("API Response received", category: .api, metadata: [
                    "url": url.absoluteString,
                    "response_size": data.count,
                    "preview": String(jsonString.prefix(500))
                ])
                
                if endpoint == .cheapestTickets {
                    AppLogger.shared.debug("Flight search raw response", category: .api, metadata: [
                        "full_response": String(jsonString.prefix(2000))
                    ])
                }
            }
            
            return try decoder.decode(responseType, from: data)
            
        } catch let decodingError as DecodingError {
            AppLogger.shared.error("Failed to decode API response", category: .api, metadata: [
                "url": url.absoluteString,
                "error": decodingError.localizedDescription
            ])
            throw AppError.dataDecodingFailed("Failed to decode response: \(decodingError.localizedDescription)")
        } catch let appError as AppError {
            throw appError
        } catch {
            AppLogger.shared.error("Network request failed", category: .network, metadata: [
                "url": url.absoluteString,
                "error": error.localizedDescription
            ])
            throw AppError.networkError("Network request failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Static Data Loading
    func loadAirports() async throws -> [Airport] {
        let airports: [Airport] = try await request(
            endpoint: .airports,
            responseType: [Airport].self
        )
        
        AppLogger.shared.success("Airports data loaded", category: .airport, metadata: ["count": airports.count])
        return airports
    }
    
    func loadAirlines() async throws -> [Airline] {
        let airlines: [Airline] = try await request(
            endpoint: .airlines,
            responseType: [Airline].self
        )
        
        AppLogger.shared.success("Airlines data loaded", category: .data, metadata: ["count": airlines.count])
        return airlines
    }
    
    func loadCities() async throws -> [City] {
        let cities: [City] = try await request(
            endpoint: .cities,
            responseType: [City].self
        )
        
        AppLogger.shared.success("Cities data loaded", category: .data, metadata: ["count": cities.count])
        return cities
    }
    
    func loadCountries() async throws -> [Country] {
        let countries: [Country] = try await request(
            endpoint: .countries,
            responseType: [Country].self
        )
        
        AppLogger.shared.success("Countries data loaded", category: .data, metadata: ["count": countries.count])
        return countries
    }
}

// MARK: -  Extensions
extension NetworkManager {
    func loadAirportsPublisher() -> AnyPublisher<[Airport], AppError> {
        Future { [weak self] promise in
            Task {
                do {
                    let airports = try await self?.loadAirports() ?? []
                    promise(.success(airports))
                } catch {
                    promise(.failure(AppError.from(error: error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

extension URL {
    var debugDescription: String {
        return self.absoluteString
    }
}
