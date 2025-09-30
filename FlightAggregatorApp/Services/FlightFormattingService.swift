//
//  FlightFormattingService.swift
//  FlightAggregatorApp
//
//  Created by Alexandra Makey on 29.09.25.
//

import Foundation

// MARK: - FlightFormattingService
class FlightFormattingService {
    // MARK: - Singleton
    static let shared = FlightFormattingService()
    
    private init() {}
    
    // MARK: - Price Formatting
    func formatPrice(_ price: Int, currency: String = "RUB") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        
        let formattedPrice = formatter.string(from: NSNumber(value: price)) ?? "\(price)"
        
        switch currency {
        case "RUB":
            return "\(formattedPrice) ₽"
        case "USD":
            return "$\(formattedPrice)"
        case "EUR":
            return "€\(formattedPrice)"
        default:
            return "\(formattedPrice) \(currency)"
        }
    }
    
    // MARK: - Airline Formatting
    func formatAirline(code: String?, airlines: [Airline]) -> String {
        guard let code = code else { return "Unknown Airline" }
        
        if let airline = airlines.first(where: { $0.code == code }) {
            return airline.localizedName
        }
        
        return getAirlineFallbackName(for: code)
    }
    
    // MARK: - Location Formatting
    func formatLocation(code: String, airports: [Airport], cities: [City]) -> String {
        if let airport = airports.first(where: { $0.code == code }) {
            return airport.name
        }
        
        if let city = cities.first(where: { $0.code == code }) {
            return city.name
        }
        
        return code
    }
    
    func formatAirlineName(code: String?) -> String {
        guard let code = code else { return "airline.unknown".localized }
        
        if let airline = DataManager.shared.airlines.first(where: { $0.code == code }) {
            return airline.localizedName
        }
        
        return getAirlineFallbackName(for: code)
    }
    
    private func getAirlineFallbackName(for code: String) -> String {
        switch code {
        // Russian
        case "SU": return "Аэрофлот"
        case "S7": return "S7 Airlines"
        case "UT": return "UTair"
        case "FV": return "Россия"
        case "DP": return "Победа"
        case "WZ": return "Red Wings"
        // International
        case "BA": return "British Airways"
        case "LH": return "Lufthansa"
        case "AF": return "Air France"
        case "KL": return "KLM"
        case "EK": return "Emirates"
        case "QR": return "Qatar Airways"
        case "TK": return "Turkish Airlines"
        case "AA": return "American Airlines"
        case "DL": return "Delta Air Lines"
        case "UA": return "United Airlines"
        case "JL": return "Japan Airlines"
        case "NH": return "ANA"
        case "SQ": return "Singapore Airlines"
        case "TG": return "Thai Airways"
        default: return code
        }
    }
    
    // MARK: - City Formatting
    func formatCityName(code: String) -> String {
        if let airport = DataManager.shared.airports.first(where: { $0.code == code }) {
            return airport.cityName ?? airport.name
        }
        
        if let city = DataManager.shared.cities.first(where: { $0.code == code }) {
            return city.name
        }
        
        return getCityFallbackName(for: code)
    }
    
    private func getCityFallbackName(for code: String) -> String {
        switch code {
        // Russia
        case "MOW": return "Москва"
        case "LED": return "Санкт-Петербург"
        case "AER": return "Сочи"
        case "KZN": return "Казань"
        case "UFA": return "Уфа"
        case "ROV": return "Ростов-на-Дону"
        case "KRR": return "Краснодар"
        case "VOG": return "Волгоград"
        case "SVX": return "Екатеринбург"
        case "OVB": return "Новосибирск"
        // USA
        case "JFK": return "Нью-Йорк"
        case "LAX": return "Лос-Анджелес"
        case "ORD": return "Чикаго"
        case "DFW": return "Даллас"
        case "DEN": return "Денвер"
        case "ATL": return "Атланта"
        case "BOS": return "Бостон"
        case "SFO": return "Сан-Франциско"
        case "SEA": return "Сиэтл"
        case "MIA": return "Майами"
        case "YYZ": return "Торонто"
        case "YVR": return "Ванкувер"
        // Europe
        case "LHR": return "Лондон"
        case "CDG": return "Париж"
        case "FRA": return "Франкфурт"
        case "AMS": return "Амстердам"
        case "MAD": return "Мадрид"
        case "FCO": return "Рим"
        case "LGW": return "Лондон"
        case "MUC": return "Мюнхен"
        case "ZUR": return "Цюрих"
        case "VIE": return "Вена"
        case "ARN": return "Стокгольм"
        case "OSL": return "Осло"
        case "CPH": return "Копенгаген"
        // Middle East
        case "DXB": return "Дубай"
        case "DOH": return "Доха"
        case "AUH": return "Абу-Даби"
        case "CAI": return "Каир"
        case "JED": return "Джидда"
        case "RUH": return "Эр-Рияд"
        case "KWI": return "Кувейт"
        case "BAH": return "Бахрейн"
        case "MCT": return "Маскат"
        case "AMM": return "Амман"
        // Asia
        case "NRT": return "Токио"
        case "ICN": return "Сеул"
        case "SIN": return "Сингапур"
        case "BKK": return "Бангкок"
        case "HKG": return "Гонконг"
        case "PVG": return "Шанхай"
        case "PEK": return "Пекин"
        case "DEL": return "Дели"
        case "BOM": return "Мумбаи"
        case "CCU": return "Калькутта"
        // other
        case "SYD": return "Сидней"
        case "MEL": return "Мельбурн"
        case "GRU": return "Сан-Паулу"
        case "EZE": return "Буэнос-Айрес"
        case "LIM": return "Лима"
        case "BOG": return "Богота"
        case "SCL": return "Сантьяго"
        case "PTY": return "Панама"
        default: return code
        }
    }
    
    // MARK: -  Formatters
    func formatFlightDate(_ dateString: String) -> String {
        return dateString.displayDate
    }
    
    func formatDate(_ date: Date) -> String {
        return date.apiString
    }
    
    func formatRoute(origin: String, destination: String) -> String {
        let originCity = formatCityName(code: origin)
        let destinationCity = formatCityName(code: destination)
        return "\(originCity) → \(destinationCity)"
    }
    
    func formatFlightInfo(flight: Flight) -> String {
        let changesText = flight.changesDescription
        let dateText = formatFlightDate(flight.departDate)
        return "\(changesText) • \(dateText)"
    }
}
