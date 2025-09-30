//
//  FlightStatus.swift
//  FlightAggregatorApp
//
//  Created by Alexandra Makey on 30.09.25.
//
import UIKit

// MARK: - Flight Status
enum FlightStatus: String, CaseIterable {
    case scheduled = "scheduled"
    case delayed = "delayed"
    case boarding = "boarding"
    case departed = "departed"
    case arrived = "arrived"
    case cancelled = "cancelled"
    case unknown = "unknown"
    
    var localizedTitle: String {
        switch self {
        case .scheduled: return "flight.status.scheduled".localized
        case .delayed: return "flight.status.delayed".localized
        case .boarding: return "flight.status.boarding".localized
        case .departed: return "flight.status.departed".localized
        case .arrived: return "flight.status.arrived".localized
        case .cancelled: return "flight.status.cancelled".localized
        case .unknown: return "flight.status.unknown".localized
        }
    }
    
    var color: UIColor {
        switch self {
        case .scheduled: return .systemBlue
        case .delayed: return .systemOrange
        case .boarding: return .systemGreen
        case .departed: return .systemPurple
        case .arrived: return .systemGreen
        case .cancelled: return .systemRed
        case .unknown: return .systemGray
        }
    }
    
    var backgroundColor: UIColor {
        return color.withAlphaComponent(0.15)
    }
    
    var icon: String {
        switch self {
        case .scheduled: return "clock"
        case .delayed: return "exclamationmark.triangle"
        case .boarding: return "figure.walk.departure"
        case .departed: return "airplane.departure"
        case .arrived: return "airplane.arrival"
        case .cancelled: return "xmark.circle"
        case .unknown: return "questionmark.circle"
        }
    }
}
