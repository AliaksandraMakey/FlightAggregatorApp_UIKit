//
//  LoadMoreCell.swift
//  FlightAggregatorApp
//
//  Created by Alexandra Makey on 27.09.25.
//

import UIKit

// MARK: - LoadMoreCell
class LoadMoreCell: UICollectionViewCell {
    static let identifier = "LoadMoreCell"
    
    private let button = UIButton(type: .system)
    private var onTap: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = .systemGray6
        contentView.layer.cornerRadius = 12
        
        button.setTitle("flights.load.more".localized, for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        contentView.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(remainingCount: Int, onTap: @escaping () -> Void) {
        self.onTap = onTap
        button.setTitle(String(format: "flights.remaining.count".localized, remainingCount), for: .normal)
    }
    
    @objc private func buttonTapped() {
        onTap?()
    }
}
