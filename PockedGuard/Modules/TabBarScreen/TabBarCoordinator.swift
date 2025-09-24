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
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController?
    let tabBarController: TabBarController = .init()
    private let dataProvider: DataProviderProtocol
    
    init(dataProvider: DataProviderProtocol) {
        self.dataProvider = dataProvider
    }
    
    func start() {
        childCoordinators = createViewControllers()
        childCoordinators.forEach { $0.start() }
        tabBarController.setViewControllers(childCoordinators.compactMap { $0.navigationController })
        
        tabBarController.onAddButtonTapped = { [weak self] in
            self?.startAddCoordinator()
        }
    }
    
    func startAddCoordinator() {
        let addCoordinator: AddCoordinator = .init(dataProvider: dataProvider, presentingViewController: tabBarController)
        addCoordinator.start()
        addChildCoordinator(addCoordinator)
    }
}

// MARK: - Private methods
private extension TabBarCoordinator {
    func createViewControllers() -> [Coordinator] {
        let mainCoordinator: MainCoordinator = .init(dataProvider: dataProvider)
        let categoriesCoordinator: CategoriesCoordinator = .init(dataProvider: dataProvider)
        let analyticsCoordinator: AnalyticsCoordinator = .init(dataProvider: dataProvider)
        let profileCoordinator: ProfileCoordinator = .init(dataProvider: dataProvider)
        
        return [mainCoordinator, categoriesCoordinator, analyticsCoordinator, profileCoordinator]
    }
}
