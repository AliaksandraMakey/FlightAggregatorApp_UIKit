//
//  TabBarController.swift
//  FlightAggregatorApp
//
//  Created by Alexandra Makey on 26.09.25.
//

import UIKit

class TabBarController: UITabBarController {
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupTabBar()
    }
    
    private func setupTabBar() {
        viewControllers = [
            generateNavigationController(
                rootViewController: FlightViewController(),
                title: "tab.flights".localized,
                image: UIImage(systemName: "airplane")!
            ),
            generateNavigationController(
                rootViewController: SettingsViewController(),
                title: "tab.settings".localized,
                image: UIImage(systemName: "slider.horizontal.3")!
            )
        ]
    }
    
    private func generateNavigationController(
        rootViewController: UIViewController,
        title: String,
        image: UIImage
    ) -> UIViewController {
        let navigationVC = UINavigationController(rootViewController: rootViewController)
        navigationVC.tabBarItem.title = title
        navigationVC.tabBarItem.image = image
        return navigationVC
    }
    
}
