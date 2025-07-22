//
//  CategoriesCoordinator.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 20.07.2025.
//

import UIKit

final class CategoriesCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController? = .init()
    
    func start() {
        showCategoriesScreen()
    }
}

// MARK: - Private methods
private extension CategoriesCoordinator {
    func showCategoriesScreen() {
        let viewModel: CategoriesViewModelProtocol = CategoriesViewModel()
        let viewController: CategoriesViewController = .init(viewModel: viewModel)
        
        navigationController?.pushViewController(viewController, animated: true)
    }
}
