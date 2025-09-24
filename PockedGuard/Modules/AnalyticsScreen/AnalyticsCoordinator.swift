//
//  AnalyticsCoordinator.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 20.07.2025.
//

import UIKit

final class AnalyticsCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController?
    private let dataProvider: DataProviderProtocol
    
    init(dataProvider: DataProviderProtocol) {
        self.dataProvider = dataProvider
        self.navigationController = .init()
    }
    
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
