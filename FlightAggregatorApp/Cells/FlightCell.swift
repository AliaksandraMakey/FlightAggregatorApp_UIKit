//
//  FlightCell.swift
//  FlightAggregatorApp
//
//  Created by Alexandra Makey on 27.09.25.
//

import UIKit

// MARK: - FlightCell
class FlightCell: UICollectionViewCell {
    static let identifier = "FlightCell"
    
    private let containerView = UIView()
    private let airlineLabel = UILabel()
    private let routeLabel = UILabel()
    private let timeLabel = UILabel()
    private let priceLabel = UILabel()
    private let placeholderLabel = UILabel()
    private let statusBadgeView = UIView()
    private let statusLabel = UILabel()
    private let statusIconImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 12
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.1
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 4
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        // Setup labels
        [airlineLabel, routeLabel, timeLabel, priceLabel, placeholderLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview($0)
        }
        // Setup status badge
        statusBadgeView.translatesAutoresizingMaskIntoConstraints = false
        statusBadgeView.layer.cornerRadius = 8
        containerView.addSubview(statusBadgeView)
        
        statusIconImageView.translatesAutoresizingMaskIntoConstraints = false
        statusIconImageView.contentMode = .scaleAspectFit
        statusBadgeView.addSubview(statusIconImageView)
        
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        statusBadgeView.addSubview(statusLabel)
        // Airline
        airlineLabel.font = UIFont.boldSystemFont(ofSize: 16)
        airlineLabel.numberOfLines = 1
        airlineLabel.lineBreakMode = .byTruncatingTail
        // Route
        routeLabel.font = UIFont.systemFont(ofSize: 14)
        routeLabel.numberOfLines = 2
        routeLabel.lineBreakMode = .byWordWrapping
        // Time
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.textColor = .systemGray
        timeLabel.numberOfLines = 1
        // Price
        priceLabel.font = UIFont.boldSystemFont(ofSize: 18)
        priceLabel.textColor = .systemBlue
        priceLabel.textAlignment = .right
        priceLabel.numberOfLines = 1
        // Set content priorities
        airlineLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        priceLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        priceLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        airlineLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        placeholderLabel.text = "flights.loading.placeholder".localized
        placeholderLabel.textAlignment = .center
        placeholderLabel.numberOfLines = 0
        placeholderLabel.textColor = .systemGray
        placeholderLabel.font = UIFont.systemFont(ofSize: 16)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            // Airline label
            airlineLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            airlineLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            airlineLabel.trailingAnchor.constraint(lessThanOrEqualTo: priceLabel.leadingAnchor, constant: -8),
            // Price label
            priceLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            priceLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 120),
            // Route label
            routeLabel.topAnchor.constraint(equalTo: airlineLabel.bottomAnchor, constant: 12),
            routeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            routeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            // Time label
            timeLabel.topAnchor.constraint(equalTo: routeLabel.bottomAnchor, constant: 8),
            timeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            timeLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusBadgeView.leadingAnchor, constant: -8),
            timeLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            // Status badge
            statusBadgeView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            statusBadgeView.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor),
            statusBadgeView.heightAnchor.constraint(equalToConstant: 20),
            // Status icon
            statusIconImageView.leadingAnchor.constraint(equalTo: statusBadgeView.leadingAnchor, constant: 6),
            statusIconImageView.centerYAnchor.constraint(equalTo: statusBadgeView.centerYAnchor),
            statusIconImageView.widthAnchor.constraint(equalToConstant: 12),
            statusIconImageView.heightAnchor.constraint(equalToConstant: 12),
            // Status label
            statusLabel.leadingAnchor.constraint(equalTo: statusIconImageView.trailingAnchor, constant: 4),
            statusLabel.trailingAnchor.constraint(equalTo: statusBadgeView.trailingAnchor, constant: -6),
            statusLabel.centerYAnchor.constraint(equalTo: statusBadgeView.centerYAnchor),
            // Placeholder
            placeholderLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            placeholderLabel.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 16),
            placeholderLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -16)
        ])
    }
    
    func configure(with flight: Flight) {
        placeholderLabel.isHidden = true
        airlineLabel.isHidden = false
        routeLabel.isHidden = false
        timeLabel.isHidden = false
        priceLabel.isHidden = false
        statusBadgeView.isHidden = false
     
        airlineLabel.text = flight.getFormattedAirlineName()
        routeLabel.text = flight.getFormattedRoute()
        timeLabel.text = flight.getFormattedFlightInfo()
        priceLabel.text = flight.formattedPrice

        let flightStatus = flight.status
// 
//        AppLogger.shared.debug("Flight cell status applied", category: .ui, metadata: [
//            "flight_number": flight.flightNumber,
//            "status": flightStatus.rawValue,
//            "status_title": flightStatus.localizedTitle
//        ])
        
        statusBadgeView.backgroundColor = flightStatus.backgroundColor
        statusIconImageView.image = UIImage(systemName: flightStatus.icon)
        statusIconImageView.tintColor = flightStatus.color
        statusLabel.text = flightStatus.localizedTitle
        statusLabel.textColor = flightStatus.color

        statusBadgeView.layer.borderWidth = 1
        statusBadgeView.layer.borderColor = flightStatus.color.withAlphaComponent(0.3).cgColor
    }
    
    func configureAsPlaceholder() {
        placeholderLabel.isHidden = false
        airlineLabel.isHidden = true
        routeLabel.isHidden = true
        timeLabel.isHidden = true
        priceLabel.isHidden = true
        statusBadgeView.isHidden = true
    }
}
