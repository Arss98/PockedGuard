//
//  AnalyticsCoordinator.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 20.07.2025.
//

import UIKit

final class AnalyticsCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController? { nil }
    
    func start() {
        showAnalyticsScreen()
    }
}

// MARK: - Private methods
private extension AnalyticsCoordinator {
    func showAnalyticsScreen() {
        let viewModel: AnalyticsViewModelProtocol = AnalyticsViewModel()
        let viewController: AnalyticsViewController = .init(viewModel: viewModel)
        
        navigationController?.pushViewController(viewController, animated: true)
    }
}
