//
//  FlightFilterDelegate.swift
//  FlightAggregatorApp
//
//  Created by Alexandra Makey on 29.09.25.
//

import UIKit

// MARK: - FlightFilterDelegate
protocol FlightFilterDelegate: AnyObject {
    func didApplyFilters(_ filters: FlightFilters)
    func didClearFilters()
}
