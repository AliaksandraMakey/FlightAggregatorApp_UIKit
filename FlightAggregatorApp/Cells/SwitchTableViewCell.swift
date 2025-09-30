//
//  SwitchTableViewCell.swift
//  FlightAggregatorApp
//
//  Created by Alexandra Makey on 29.09.25.
//

import UIKit

// MARK: - SwitchTableViewCell
class SwitchTableViewCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let toggleSwitch = UISwitch()
    private var toggleAction: ((Bool) -> Void)?
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        toggleSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(toggleSwitch)
        
        toggleSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            toggleSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            toggleSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with title: String, isOn: Bool, toggleAction: @escaping (Bool) -> Void) {
        titleLabel.text = title
        toggleSwitch.isOn = isOn
        self.toggleAction = toggleAction
    }
    
    @objc private func switchValueChanged() {
        toggleAction?(toggleSwitch.isOn)
    }
}
