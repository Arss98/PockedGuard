//
//  TabBarCoordinator.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 20.07.2025.
//

import UIKit

protocol TabCoordinator: Coordinator {
    var tabBarController: TabBarController { get }
}

final class TabBarCoordinator: TabCoordinator {
    let tabBarController: TabBarController = .init()
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController?
    
    func start() {
        childCoordinators = createViewControllers()
        childCoordinators.forEach { $0.start() }
        tabBarController.setViewControllers(childCoordinators.compactMap { $0.navigationController })
        
        tabBarController.onAddButtonTapped = { [weak self] in
            self?.startAddCoordinator()
        }
    }
    
    func startAddCoordinator() {
        let addCoordinator: AddCoordinator = .init(presentingViewController: tabBarController)
        addCoordinator.start()
        addChildCoordinator(addCoordinator)
    }
}

// MARK: - Private methods
private extension TabBarCoordinator {
    func createViewControllers() -> [Coordinator] {
        let mainCoordinator: MainCoordinator = .init()
        let categoriesCoordinator: CategoriesCoordinator = .init()
        let analyticsCoordinator: AnalyticsCoordinator = .init()
        let profileCoordinator: ProfileCoordinator = .init()
        
        return [mainCoordinator, categoriesCoordinator, analyticsCoordinator, profileCoordinator]
    }
}
