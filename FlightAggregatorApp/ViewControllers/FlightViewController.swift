//
//  FlightViewController.swift
//  FlightAggregatorApp
//
//  Created by Alexandra Makey on 26.09.25.
//

import UIKit
import Combine

class FlightViewController: UIViewController {
    
    // MARK: - UI Elements
    private var collectionView: UICollectionView!
    private var loadingIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    private var flights: [Flight] = []
    private let viewModel = FlightViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Services
    private let flightGenerationService = FlightGenerationService.shared
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupViewModelBindings()
        loadFlights() 
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "navigation.flights".localized
        
        setupNavigationBar()
        setupCollectionView()
        setupLoadingIndicator()
    }
    
    private func setupNavigationBar() {
        let filterButton = UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal.decrease.circle"),
            style: .plain,
            target: self,
            action: #selector(filterButtonTapped)
        )
        navigationItem.rightBarButtonItem = filterButton
    }
    
    private func setupLoadingIndicator() {
        loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(FlightCell.self, forCellWithReuseIdentifier: FlightCell.identifier)
        collectionView.register(LoadMoreCell.self, forCellWithReuseIdentifier: LoadMoreCell.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshFlights), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        view.addSubview(collectionView)
    }
    
    // MARK: - ViewModel 
    private func setupViewModelBindings() {
        viewModel.$flights
            .receive(on: DispatchQueue.main)
            .sink { [weak self] flights in
                AppLogger.shared.debug("ViewController received flights from ViewModel", category: .ui, metadata: [
                    "flights_count": flights.count
                ])
                self?.updateFlightsWithAnimation(newFlights: flights)
            }
            .store(in: &cancellables)
        
        // loading state 
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.animateLoadingState(isLoading: isLoading)
            }
            .store(in: &cancellables)
        
        // error 
        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.showAlert(title: "error".localized, message: errorMessage)
            }
            .store(in: &cancellables)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Actions
    @objc private func filterButtonTapped() {
        let filterVC = FlightFilterViewController()
        filterVC.currentFilters = viewModel.currentFilters
        filterVC.delegate = self
        
        let navController = UINavigationController(rootViewController: filterVC)
        navController.modalPresentationStyle = .pageSheet
        
        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        
        present(navController, animated: true)
    }
    
    @objc private func refreshFlights() {
        viewModel.refreshFlights()
    }
    
    private func loadFlights() {
        viewModel.loadFlights()
    }
    
    // MARK: - Flights
    private func loadMoreFlights() {
        viewModel.loadNextPage()
    }
    
    private var hasMoreFlights: Bool {
        return viewModel.hasMoreFlights
    }
    
    private func getRemainingFlightsCount() -> Int {
        let totalAvailable = getTotalAvailableFlights()
        let currentlyDisplayed = viewModel.flights.count
        return max(0, totalAvailable - currentlyDisplayed)
    }
    
    private func getTotalAvailableFlights() -> Int {
        return viewModel.totalAvailableFlights
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localized, style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Animations
    private func updateFlightsWithAnimation(newFlights: [Flight]) {
        let oldFlights = self.flights
        self.flights = newFlights
        
//        AppLogger.shared.debug("Updating flights with animation", category: .ui, metadata: [
//            "old_count": oldFlights.count,
//            "new_count": newFlights.count,
//            "change": newFlights.count - oldFlights.count
//        ])
        
        animateCollectionViewFadeReload()
    }
    
    private func animateCollectionViewFadeReload() {
        DispatchQueue.main.async {
            UIView.transition(with: self.collectionView,
                             duration: 0.4,
                             options: [.transitionCrossDissolve, .allowUserInteraction],
                             animations: {
                self.collectionView.reloadData()
            }, completion: { _ in
                self.animateVisibleCellsEntrance()
            })
        }
    }
    
    private func animateVisibleCellsEntrance() {
        let visibleCells = collectionView.visibleCells
        
        for cell in visibleCells {
            cell.alpha = 0
            cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }
        
        for (index, cell) in visibleCells.enumerated() {
            UIView.animate(
                withDuration: 0.5,
                delay: Double(index) * 0.05,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.5,
                options: [.allowUserInteraction]
            ) {
                cell.alpha = 1
                cell.transform = .identity
            }
        }
    }
    
    private func animateLoadingState(isLoading: Bool) {
        if isLoading {
            loadingIndicator.alpha = 0
            loadingIndicator.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            loadingIndicator.startAnimating()
            
            UIView.animate(
                withDuration: 0.3, delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.5
            ) {
                self.loadingIndicator.alpha = 1
                self.loadingIndicator.transform = .identity
            }
            
            UIView.animate(withDuration: 0.2) {
                self.collectionView.alpha = 0.7
            }
        } else {
            UIView.animate(
                withDuration: 0.2,
                animations: {
                    self.loadingIndicator.alpha = 0
                    self.loadingIndicator.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                    self.collectionView.alpha = 1.0
                },
                completion: { _ in
                    self.loadingIndicator.stopAnimating()
                    self.collectionView.refreshControl?.endRefreshing()
                }
            )
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension FlightViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let flightCount = flights.count
        
        if flightCount == 0 {
            return 1
        } else {
            let itemCount = hasMoreFlights ? flightCount + 1 : flightCount
//            AppLogger.shared.debug("CollectionView numberOfItems", category: .ui, metadata: [
//                "flights_count": flightCount,
//                "has_more_flights": hasMoreFlights,
//                "total_items": itemCount
//            ])
            return itemCount
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if flights.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FlightCell.identifier, for: indexPath) as! FlightCell
            cell.configureAsPlaceholder()
            return cell
        }
        
        if indexPath.row < flights.count {
            // flight
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FlightCell.identifier, for: indexPath) as! FlightCell
            cell.configure(with: flights[indexPath.row])
            return cell
        } else if hasMoreFlights {
            // Load more
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LoadMoreCell.identifier, for: indexPath) as! LoadMoreCell
            let remainingFlights = getRemainingFlightsCount()
            cell.configure(remainingCount: remainingFlights) { [weak self] in
                self?.loadMoreFlights()
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FlightCell.identifier, for: indexPath) as! FlightCell
            cell.configureAsPlaceholder()
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !flights.isEmpty, indexPath.row < flights.count else { return }
        
        let flight = flights[indexPath.row]
        presentFlightDetails(for: flight)
    }
    
    private func presentFlightDetails(for flight: Flight) {
        let detailViewController = FlightDetailViewController(flight: flight)
        
        navigationController?.delegate = self
        
        navigationController?.pushViewController(detailViewController, animated: true)
        
//        AppLogger.shared.info("Flight details pushed to navigation stack", category: .ui, metadata: [
//            "flight_number": flight.flightNumber,
//            "origin": flight.origin,
//            "destination": flight.destination
//        ])
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = max(collectionView.frame.width - 32, 100) 
        return CGSize(width: width, height: 120)
    }
}

// MARK: - UINavigationControllerDelegate
extension FlightViewController: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        
        if (operation == .push && toVC is FlightDetailViewController) ||
           (operation == .pop && fromVC is FlightDetailViewController) {
            return FlightDetailTransitionAnimator(isPush: operation == .push)
        }
        
        return nil
    }
}

// MARK: - FlightFilterDelegate
extension FlightViewController: FlightFilterDelegate {
    func didApplyFilters(_ filters: FlightFilters) {
        viewModel.searchFlights(with: filters)
    }
    
    func didClearFilters() {
        viewModel.clearFilters()
    }
}
