//
//  FlightFilterViewController.swift
//  FlightAggregatorApp
//
//  Created by Alexandra Makey on 29.09.25.
//

import UIKit
import Combine

// MARK: - FlightFilterViewController
class FlightFilterViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: FlightFilterDelegate?
    var currentFilters: FlightFilters?

    private let viewModel = FlightFilterViewModel()
    private var cancellables = Set<AnyCancellable>()
    private var currentSuggestions: [City] = []
  
    // MARK: - UI Elements
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var fromTextField: UITextField!
    private var toTextField: UITextField!
    private var departureDateField: UITextField!
    private var returnDateField: UITextField!
    private var applyButton: UIButton!
    private var clearButton: UIButton!
    private var suggestionsTableView: UITableView!
    private var activeSuggestionField: UITextField?
    
    private var suggestionsHeightConstraint: NSLayoutConstraint!
  
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupViewModelBindings()
        populateCurrentFilters()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateContentEntry()
    }
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "navigation.filters".localized
    
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        
        // Scroll view
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Text fields
        fromTextField = createTextField(placeholder: "filters.from.placeholder".localized)
        toTextField = createTextField(placeholder: "filters.to.placeholder".localized)
        departureDateField = createTextField(placeholder: "filters.departure.placeholder".localized)
        returnDateField = createTextField(placeholder: "filters.return.placeholder".localized)
        
        fromTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
        toTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
        
        // date pickers
        departureDateField.inputView = createDatePicker()
        returnDateField.inputView = createDatePicker()
        
        [fromTextField, toTextField, departureDateField, returnDateField].forEach {
            contentView.addSubview($0)
        }
        
        // apply button
        applyButton = UIButton(type: .system)
        applyButton.setTitle("filters.apply".localized, for: .normal)
        applyButton.backgroundColor = .systemBlue
        applyButton.setTitleColor(.white, for: .normal)
        applyButton.layer.cornerRadius = 8
        applyButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        applyButton.translatesAutoresizingMaskIntoConstraints = false
        applyButton.addTarget(self, action: #selector(applyFilters), for: .touchUpInside)
        contentView.addSubview(applyButton)
        // clear button
        clearButton = UIButton(type: .system)
        clearButton.setTitle("filters.clear".localized, for: .normal)
        clearButton.setTitleColor(.systemRed, for: .normal)
        clearButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.addTarget(self, action: #selector(clearFilters), for: .touchUpInside)
        contentView.addSubview(clearButton)
    }
    
    private func createTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .systemBackground
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        //  toolbar
        let toolbar = UIToolbar()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "done".localized, style: .done, target: self, action: #selector(datePickerDone))
        toolbar.setItems([flexSpace, doneButton], animated: false)
        toolbar.sizeToFit()
        textField.inputAccessoryView = toolbar
        
        return textField
    }
    
    // MARK: - ViewModel Bindings
    private func setupViewModelBindings() {
        // validation
        viewModel.$isValidForm
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isValid in
                self?.animateButtonStateChange(isEnabled: isValid)
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
        
        // departure
        viewModel.$departureDate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] date in
                self?.departureDateField.text = date.mediumString
                
                if let returnDatePicker = self?.returnDateField.inputView as? UIDatePicker {
                    let calendar = Calendar.current
                    returnDatePicker.minimumDate = calendar.startOfDay(for: date)
                    
                    if returnDatePicker.date < date {
                        returnDatePicker.date = date
                    }
                }
            }
            .store(in: &cancellables)
        
        viewModel.$returnDate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] date in
                self?.returnDateField.text = date?.mediumString ?? ""
            }
            .store(in: &cancellables)
    }
    //MARK: - Pickers
    private func createDatePicker() -> UIDatePicker {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        
        let calendar = Calendar.current
        datePicker.minimumDate = calendar.startOfDay(for: Date())
        
        datePicker.addTarget(self, action: #selector(datePickerChanged(_:)), for: .valueChanged)
        
        return datePicker
    }
    
    @objc private func datePickerChanged(_ picker: UIDatePicker) {
        if picker == departureDateField.inputView {
            viewModel.setDepartureDate(picker.date)
        } else if picker == returnDateField.inputView {
            viewModel.setReturnDate(picker.date)
        }
    }
    //MARK: - Constraints
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
            // field from
            fromTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            fromTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            fromTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            fromTextField.heightAnchor.constraint(equalToConstant: 44),
            // field to
            toTextField.topAnchor.constraint(equalTo: fromTextField.bottomAnchor, constant: 16),
            toTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            toTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            toTextField.heightAnchor.constraint(equalToConstant: 44),
            //field departure date
            departureDateField.topAnchor.constraint(equalTo: toTextField.bottomAnchor, constant: 16),
            departureDateField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            departureDateField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            departureDateField.heightAnchor.constraint(equalToConstant: 44),
            //field return date
            returnDateField.topAnchor.constraint(equalTo: departureDateField.bottomAnchor, constant: 16),
            returnDateField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            returnDateField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            returnDateField.heightAnchor.constraint(equalToConstant: 44),
            //apply button
            applyButton.topAnchor.constraint(equalTo: returnDateField.bottomAnchor, constant: 32),
            applyButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            applyButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            applyButton.heightAnchor.constraint(equalToConstant: 50),
            //clear button
            clearButton.topAnchor.constraint(equalTo: applyButton.bottomAnchor, constant: 16),
            clearButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            clearButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }
   
    private func populateCurrentFilters() {
        viewModel.loadFilters(currentFilters)
        
        fromTextField.text = viewModel.originInput
        toTextField.text = viewModel.destinationInput
        
        if let departurePicker = departureDateField.inputView as? UIDatePicker {
            departurePicker.date = viewModel.departureDate
        }
        
        if let returnPicker = returnDateField.inputView as? UIDatePicker,
           let returnDate = viewModel.returnDate {
            returnPicker.date = returnDate
        }
    }
    //MARK: - private Actions
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func textFieldChanged(_ textField: UITextField) {
        switch textField {
        case fromTextField:
            viewModel.originInput = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        case toTextField:
            viewModel.destinationInput = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        default:
            break
        }
    }
    
    @objc private func datePickerDone() {
        view.endEditing(true)
        
        if let datePicker = departureDateField.inputView as? UIDatePicker, departureDateField.isFirstResponder {
            viewModel.setDepartureDate(datePicker.date)
        } else if let datePicker = returnDateField.inputView as? UIDatePicker, returnDateField.isFirstResponder {
            viewModel.setReturnDate(datePicker.date)
        }
    }
    
    @objc private func applyFilters() {
        animateButtonPress(applyButton) { [weak self] in
            self?.viewModel.originInput = self?.fromTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            self?.viewModel.destinationInput = self?.toTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            
            guard let filters = self?.viewModel.createFilters() else { return }
            
            self?.delegate?.didApplyFilters(filters)
            self?.dismiss(animated: true)
        }
    }
    
    @objc private func clearFilters() {
        animateButtonPress(clearButton) { [weak self] in
            self?.animateClearFields()
            
            self?.viewModel.resetToDefaults()
            self?.delegate?.didClearFilters()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self?.dismiss(animated: true)
            }
        }
    }
    // MARK: - Alerts
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localized, style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Animations
    private func animateContentEntry() {
        let allViews = [fromTextField, toTextField, departureDateField, returnDateField, applyButton, clearButton]
        
        for view in allViews {
            view?.alpha = 0
            view?.transform = CGAffineTransform(translationX: 0, y: 30)
        }
        
        for (index, view) in allViews.enumerated() {
            UIView.animate(
                withDuration: 0.6,
                delay: Double(index) * 0.1,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.5,
                options: [.allowUserInteraction]
            ) {
                view?.alpha = 1
                view?.transform = .identity
            }
        }
    }
    
    private func animateButtonPress(_ button: UIButton, completion: @escaping () -> Void) {
        UIView.animate(
            withDuration: 0.1,
            animations: {
                button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                button.alpha = 0.8
            },
            completion: { _ in
                UIView.animate(
                    withDuration: 0.1,
                    animations: {
                        button.transform = .identity
                        button.alpha = 1.0
                    },
                    completion: { _ in
                        completion()
                    }
                )
            }
        )
    }
    
    private func animateClearFields() {
        let textFields = [fromTextField, toTextField, departureDateField, returnDateField]
        
        for textField in textFields {
            let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
            animation.timingFunction = CAMediaTimingFunction(name: .linear)
            animation.duration = 0.3
            animation.values = [-10.0, 10.0, -8.0, 8.0, -5.0, 5.0, 0.0]
            textField?.layer.add(animation, forKey: "shake")
            
            UIView.animate(withDuration: 0.2) {
                textField?.alpha = 0.5
            } completion: { _ in
                textField?.text = ""
                UIView.animate(withDuration: 0.2) {
                    textField?.alpha = 1.0
                }
            }
        }
    }
    
    private func animateFieldValidation(_ textField: UITextField, isValid: Bool) {
        let color = isValid ? UIColor.systemGreen : UIColor.systemRed
        let originalColor = textField.backgroundColor
        
        UIView.animate(
            withDuration: 0.2,
            animations: {
                textField.backgroundColor = color.withAlphaComponent(0.1)
                textField.layer.borderWidth = 1
                textField.layer.borderColor = color.cgColor
            },
            completion: { _ in
                UIView.animate(withDuration: 0.3) {
                    textField.backgroundColor = originalColor
                    textField.layer.borderWidth = 0
                    textField.layer.borderColor = UIColor.clear.cgColor
                }
            }
        )
    }
    
    private func animateButtonStateChange(isEnabled: Bool) {
        UIView.animate(
            withDuration: 0.3, delay: 0.1,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: [.allowUserInteraction]
        ) {
            self.applyButton.isEnabled = isEnabled
            self.applyButton.alpha = isEnabled ? 1.0 : 0.6
            self.applyButton.transform = isEnabled ? .identity : CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
}
