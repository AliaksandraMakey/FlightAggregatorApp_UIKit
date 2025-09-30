//
//  SettingsViewController.swift
//  FlightAggregatorApp
//
//  Created by Alexandra Makey on 26.09.25.
//

import UIKit

class SettingsViewController: UIViewController {
    
    // MARK: - UI
    private var tableView: UITableView!
    
    // MARK: - SettingsSection
    private enum SettingsSection: CaseIterable {
        case about
        
        var title: String {
            switch self {
            case .about:
                return "settings.about".localized
            }
        }
    }
    // MARK: - SettingsItem
    private enum SettingsItem {
        case version
        case feedback
        
        var title: String {
            switch self {
            case .version:
                return "settings.version".localized
            case .feedback:
                return "settings.feedback".localized
            }
        }
        
        var subtitle: String? {
            switch self {
            case .version:
                return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
            case .feedback:
                return nil
            }
        }
        
        var accessoryType: UITableViewCell.AccessoryType {
            switch self {
            case  .feedback:
                return .disclosureIndicator
            case .version:
                return .none
            }
        }
    }
    
    private let sections: [SettingsSection] = SettingsSection.allCases
    private let items: [SettingsSection: [SettingsItem]] = [
        .about: [.version, .feedback]
    ]
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "settings.title".localized
        
        setupTableView()
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
        tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: "SwitchCell")
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Actions
    private func handleItemSelection(_ item: SettingsItem) {
        switch item {
        case .feedback:
            showFeedbackOptions()
        case  .version:
            break
        }
    }
    private func showFeedbackOptions() {
        let alert = UIAlertController(
            title: "settings.feedback".localized,
            message: "settings.feedback.choose".localized,
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: "settings.feedback.email".localized, style: .default) { _ in
            self.openEmailComposer()
        })
        
        alert.addAction(UIAlertAction(title: "settings.feedback.rate".localized, style: .default) { _ in
            self.openAppStore()
        })
        
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        }
        
        present(alert, animated: true)
    }
    
    private func openEmailComposer() {
        let alert = UIAlertController(title: "settings.feedback.email".localized, message: "support@flightaggregator.app", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localized, style: .default))
        present(alert, animated: true)
    }
    
    private func openAppStore() {
        let alert = UIAlertController(title: "settings.rate".localized, message: "settings.rate.message".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localized, style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionType = sections[section]
        return items[sectionType]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionType = sections[indexPath.section]
        guard let sectionItems = items[sectionType],
              indexPath.row < sectionItems.count else {
            return UITableViewCell()
        }
        
        let item = sectionItems[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.subtitle
        cell.accessoryType = item.accessoryType
        
        if item == .version {
            cell.selectionStyle = .none
        } else {
            cell.selectionStyle = .default
        }
        
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let sectionType = sections[indexPath.section]
        guard let sectionItems = items[sectionType],
              indexPath.row < sectionItems.count else {
            return
        }
        
        let item = sectionItems[indexPath.row]
        handleItemSelection(item)
    }
}


