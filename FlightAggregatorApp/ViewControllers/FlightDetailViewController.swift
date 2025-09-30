//
//  FlightDetailViewController.swift
//  FlightAggregatorApp
//
//  Created by Alexandra Makey on 30.09.25.
//

import UIKit
import Combine

class FlightDetailViewController: UIViewController {
    // MARK: - UI Elements
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    // Header
    private var statusHeaderView: UIView!
    private var statusIconImageView: UIImageView!
    private var statusLabel: UILabel!
    private var flightNumberLabel: UILabel!
    // Flight route
    private var routeCardView: UIView!
    private var routeStackView: UIStackView!
    private var originContainerView: UIView!
    private var originCodeLabel: UILabel!
    private var originNameLabel: UILabel!
    private var originTimeLabel: UILabel!
    
    private var routeLineView: UIView!
    private var airplaneIconImageView: UIImageView!
    private var durationLabel: UILabel!
    
    private var destinationContainerView: UIView!
    private var destinationCodeLabel: UILabel!
    private var destinationNameLabel: UILabel!
    private var destinationTimeLabel: UILabel!
    // Info cards
    private var infoCardsStackView: UIStackView!
    private var priceCardView: UIView!
    private var airlineCardView: UIView!
    private var flightInfoCardView: UIView!

    private var loadingIndicator: UIActivityIndicatorView!
    
    // MARK: - View Model
    private let viewModel: FlightDetailViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(flight: Flight) {
        self.viewModel = FlightDetailViewModel(flight: flight)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupViewModelBindings()
        setupNavigationBar()
        applyDynamicStyling()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateContentEntry()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        setupScrollView()
        setupStatusHeader()
        setupRouteCard()
        setupInfoCards()
        setupLoadingIndicator()
    }
    
    private func setupNavigationBar() {
        title = "navigation.details".localized
        navigationController?.navigationBar.prefersLargeTitles = false
        
        let flightStatus = viewModel.flight.status
        navigationController?.navigationBar.tintColor = flightStatus.color
    }
    
    private func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .automatic
        view.addSubview(scrollView)
        
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
    }
    
    private func setupStatusHeader() {
        statusHeaderView = UIView()
        statusHeaderView.translatesAutoresizingMaskIntoConstraints = false
        statusHeaderView.layer.cornerRadius = 16
        statusHeaderView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        contentView.addSubview(statusHeaderView)
        // Status icon
        statusIconImageView = UIImageView()
        statusIconImageView.translatesAutoresizingMaskIntoConstraints = false
        statusIconImageView.contentMode = .scaleAspectFit
        statusIconImageView.tintColor = .white
        statusHeaderView.addSubview(statusIconImageView)
        // Status label
        statusLabel = UILabel()
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        statusLabel.textColor = .white
        statusLabel.textAlignment = .center
        statusHeaderView.addSubview(statusLabel)
        // Flight number
        flightNumberLabel = UILabel()
        flightNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        flightNumberLabel.font = .systemFont(ofSize: 32, weight: .bold)
        flightNumberLabel.textColor = .white
        flightNumberLabel.textAlignment = .center
        statusHeaderView.addSubview(flightNumberLabel)
    }
    
    private func setupRouteCard() {
        routeCardView = createCardView()
        contentView.addSubview(routeCardView)
        // Route stack
        routeStackView = UIStackView()
        routeStackView.translatesAutoresizingMaskIntoConstraints = false
        routeStackView.axis = .horizontal
        routeStackView.distribution = .equalSpacing
        routeStackView.alignment = .center
        routeCardView.addSubview(routeStackView)
        // Origin container
        originContainerView = createLocationContainer()
        originCodeLabel = UILabel()
        originCodeLabel.font = .systemFont(ofSize: 24, weight: .bold)
        originCodeLabel.textAlignment = .center
        
        originNameLabel = UILabel()
        originNameLabel.font = .systemFont(ofSize: 12, weight: .medium)
        originNameLabel.textColor = .secondaryLabel
        originNameLabel.textAlignment = .center
        originNameLabel.numberOfLines = 2
        
        originTimeLabel = UILabel()
        originTimeLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        originTimeLabel.textAlignment = .center
        
        let originStack = UIStackView(arrangedSubviews: [originCodeLabel, originNameLabel, originTimeLabel])
        originStack.axis = .vertical
        originStack.spacing = 4
        originStack.translatesAutoresizingMaskIntoConstraints = false
        originContainerView.addSubview(originStack)
        
        // Route line
        let routeContainer = UIView()
        routeContainer.translatesAutoresizingMaskIntoConstraints = false
        
        routeLineView = UIView()
        routeLineView.translatesAutoresizingMaskIntoConstraints = false
        routeLineView.backgroundColor = .systemGray4
        routeContainer.addSubview(routeLineView)
        
        airplaneIconImageView = UIImageView()
        airplaneIconImageView.translatesAutoresizingMaskIntoConstraints = false
        airplaneIconImageView.image = UIImage(systemName: "airplane")
        airplaneIconImageView.contentMode = .scaleAspectFit
        airplaneIconImageView.backgroundColor = .systemBackground
        routeContainer.addSubview(airplaneIconImageView)
        
        durationLabel = UILabel()
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.font = .systemFont(ofSize: 12, weight: .medium)
        durationLabel.textColor = .secondaryLabel
        durationLabel.textAlignment = .center
        routeContainer.addSubview(durationLabel)

        // Destination
        destinationContainerView = createLocationContainer()
        
        destinationCodeLabel = UILabel()
        destinationCodeLabel.font = .systemFont(ofSize: 24, weight: .bold)
        destinationCodeLabel.textAlignment = .center
        
        destinationNameLabel = UILabel()
        destinationNameLabel.font = .systemFont(ofSize: 12, weight: .medium)
        destinationNameLabel.textColor = .secondaryLabel
        destinationNameLabel.textAlignment = .center
        destinationNameLabel.numberOfLines = 2
        
        destinationTimeLabel = UILabel()
        destinationTimeLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        destinationTimeLabel.textAlignment = .center
        
        let destinationStack = UIStackView(arrangedSubviews: [destinationCodeLabel, destinationNameLabel, destinationTimeLabel])
        destinationStack.axis = .vertical
        destinationStack.spacing = 4
        destinationStack.translatesAutoresizingMaskIntoConstraints = false
        destinationContainerView.addSubview(destinationStack)
        
        routeStackView.addArrangedSubview(originContainerView)
        routeStackView.addArrangedSubview(routeContainer)
        routeStackView.addArrangedSubview(destinationContainerView)
        
        NSLayoutConstraint.activate([
            originStack.topAnchor.constraint(equalTo: originContainerView.topAnchor, constant: 12),
            originStack.leadingAnchor.constraint(equalTo: originContainerView.leadingAnchor, constant: 12),
            originStack.trailingAnchor.constraint(equalTo: originContainerView.trailingAnchor, constant: -12),
            originStack.bottomAnchor.constraint(equalTo: originContainerView.bottomAnchor, constant: -12),
            
            destinationStack.topAnchor.constraint(equalTo: destinationContainerView.topAnchor, constant: 12),
            destinationStack.leadingAnchor.constraint(equalTo: destinationContainerView.leadingAnchor, constant: 12),
            destinationStack.trailingAnchor.constraint(equalTo: destinationContainerView.trailingAnchor, constant: -12),
            destinationStack.bottomAnchor.constraint(equalTo: destinationContainerView.bottomAnchor, constant: -12),
            
            routeContainer.widthAnchor.constraint(equalToConstant: 100),
            routeContainer.heightAnchor.constraint(equalToConstant: 80),
            
            routeLineView.centerYAnchor.constraint(equalTo: routeContainer.centerYAnchor),
            routeLineView.leadingAnchor.constraint(equalTo: routeContainer.leadingAnchor, constant: 10),
            routeLineView.trailingAnchor.constraint(equalTo: routeContainer.trailingAnchor, constant: -10),
            routeLineView.heightAnchor.constraint(equalToConstant: 2),
            
            airplaneIconImageView.centerXAnchor.constraint(equalTo: routeContainer.centerXAnchor),
            airplaneIconImageView.centerYAnchor.constraint(equalTo: routeContainer.centerYAnchor),
            airplaneIconImageView.widthAnchor.constraint(equalToConstant: 24),
            airplaneIconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            durationLabel.topAnchor.constraint(equalTo: airplaneIconImageView.bottomAnchor, constant: 8),
            durationLabel.centerXAnchor.constraint(equalTo: routeContainer.centerXAnchor)
        ])
    }
    
    private func setupInfoCards() {
        infoCardsStackView = UIStackView()
        infoCardsStackView.translatesAutoresizingMaskIntoConstraints = false
        infoCardsStackView.axis = .vertical
        infoCardsStackView.spacing = 16
        contentView.addSubview(infoCardsStackView)
    
        priceCardView = createInfoCard(
            title: "flight.details.price".localized,
            icon: "creditcard",
            value: viewModel.formattedPrice,
            color: .systemGreen
        )
        
        airlineCardView = createInfoCard(
            title: "flight.details.airline".localized,
            icon: "airplane.circle",
            value: viewModel.airlineName,
            color: .systemBlue
        )
   
        let changesText = viewModel.flight.numberOfChanges == 0 ? 
            "flight.details.direct".localized : 
            "flight.details.stops".localized(with: viewModel.flight.numberOfChanges)
        flightInfoCardView = createInfoCard(
            title: "flight.details.info".localized,
            icon: "info.circle",
            value: changesText,
            color: .systemPurple
        )
        
        infoCardsStackView.addArrangedSubview(priceCardView)
        infoCardsStackView.addArrangedSubview(airlineCardView)
        infoCardsStackView.addArrangedSubview(flightInfoCardView)
    }
    
    private func setupLoadingIndicator() {
        loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
    }
    
    // MARK: - Helpers
    private func createCardView() -> UIView {
        let cardView = UIView()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .secondarySystemBackground
        cardView.layer.cornerRadius = 16
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 8
        cardView.layer.shadowOpacity = 0.1
        return cardView
    }
    
    private func createLocationContainer() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .tertiarySystemBackground
        container.layer.cornerRadius = 12
        return container
    }
    
    private func createInfoCard(title: String, icon: String, value: String, color: UIColor) -> UIView {
        let cardView = createCardView()
        
        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = UIImage(systemName: icon)
        iconImageView.tintColor = color
        iconImageView.contentMode = .scaleAspectFit
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        
        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        
        cardView.addSubview(iconImageView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            
            cardView.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        return cardView
    }
    
    // MARK: - Dynamic 
    private func applyDynamicStyling() {
        let flightStatus = viewModel.flight.status
        
        statusHeaderView.backgroundColor = flightStatus.color
        statusIconImageView.image = UIImage(systemName: flightStatus.icon)
        statusLabel.text = flightStatus.localizedTitle
        
        routeLineView.backgroundColor = flightStatus.color.withAlphaComponent(0.6)
        airplaneIconImageView.tintColor = flightStatus.color
        
        navigationController?.navigationBar.tintColor = flightStatus.color
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
         
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Status
            statusHeaderView.topAnchor.constraint(equalTo: contentView.topAnchor),
            statusHeaderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            statusHeaderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            statusHeaderView.heightAnchor.constraint(equalToConstant: 180),
        
            statusIconImageView.topAnchor.constraint(equalTo: statusHeaderView.topAnchor, constant: 24),
            statusIconImageView.centerXAnchor.constraint(equalTo: statusHeaderView.centerXAnchor),
            statusIconImageView.widthAnchor.constraint(equalToConstant: 32),
            statusIconImageView.heightAnchor.constraint(equalToConstant: 32),
           
            statusLabel.topAnchor.constraint(equalTo: statusIconImageView.bottomAnchor, constant: 8),
            statusLabel.leadingAnchor.constraint(equalTo: statusHeaderView.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: statusHeaderView.trailingAnchor, constant: -20),
            // Flight number
            flightNumberLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 8),
            flightNumberLabel.leadingAnchor.constraint(equalTo: statusHeaderView.leadingAnchor, constant: 20),
            flightNumberLabel.trailingAnchor.constraint(equalTo: statusHeaderView.trailingAnchor, constant: -20),
            flightNumberLabel.bottomAnchor.constraint(equalTo: statusHeaderView.bottomAnchor, constant: -24),
            // Route
            routeCardView.topAnchor.constraint(equalTo: statusHeaderView.bottomAnchor, constant: 20),
            routeCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            routeCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
         
            routeStackView.topAnchor.constraint(equalTo: routeCardView.topAnchor, constant: 20),
            routeStackView.leadingAnchor.constraint(equalTo: routeCardView.leadingAnchor, constant: 16),
            routeStackView.trailingAnchor.constraint(equalTo: routeCardView.trailingAnchor, constant: -16),
            routeStackView.bottomAnchor.constraint(equalTo: routeCardView.bottomAnchor, constant: -20),
            // Info
            infoCardsStackView.topAnchor.constraint(equalTo: routeCardView.bottomAnchor, constant: 20),
            infoCardsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            infoCardsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            infoCardsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            // Loading
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - ViewModel Bindings
    private func setupViewModelBindings() {
        // Flight
        viewModel.$flight
            .receive(on: DispatchQueue.main)
            .sink { [weak self] flight in
                self?.updateFlightInfo(flight)
            }
            .store(in: &cancellables)
        // Loading state
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)
        // Error
        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.showAlert(title: "error".localized, message: errorMessage)
            }
            .store(in: &cancellables)
        // Airport
        Publishers.CombineLatest(viewModel.$originAirport, viewModel.$destinationAirport)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] originAirport, destinationAirport in
                self?.updateAirportInfo(origin: originAirport, destination: destinationAirport)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Updates
    private func updateFlightInfo(_ flight: Flight) {
        flightNumberLabel.text = flight.flightNumber
        // Origin
        originCodeLabel.text = flight.origin
        originTimeLabel.text = viewModel.formattedDepartureTime
        // Destination
        destinationCodeLabel.text = flight.destination
        destinationTimeLabel.text = viewModel.formattedArrivalTime
        // Duration
        durationLabel.text = viewModel.flightDuration
        
        applyDynamicStyling()
    }
    
    private func updateAirportInfo(origin: Airport?, destination: Airport?) {
        if let origin = origin {
            originNameLabel.text = origin.name
        }
        
        if let destination = destination {
            destinationNameLabel.text = destination.name
        }
    }
    
    // MARK: - Animations
    private func animateContentEntry() {
        statusHeaderView.transform = CGAffineTransform(translationX: 0, y: -100)
        statusHeaderView.alpha = 0
        
        let cards = [routeCardView, priceCardView, airlineCardView, flightInfoCardView]
        cards.forEach { card in
            card?.alpha = 0
            card?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }
        
        UIView.animate(
            withDuration: 0.6,
            delay: 0.1,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut
        ) {
            self.statusHeaderView.transform = .identity
            self.statusHeaderView.alpha = 1
        }
        
        for (index, card) in cards.enumerated() {
            UIView.animate(
                withDuration: 0.5,
                delay: 0.3 + Double(index) * 0.1,
                usingSpringWithDamping: 0.9,
                initialSpringVelocity: 0.3,
                options: .curveEaseOut
            ) {
                card?.alpha = 1
                card?.transform = .identity
            }
        }
    }
    
    // MARK: - Alerts
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localized, style: .default))
        present(alert, animated: true)
    }
}
