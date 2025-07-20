//
//  AppRouter.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 08.03.2025.
//

import UIKit

protocol RouterProtocol: AnyObject {
    func setCurrentNavigationController(_ navigationController: UINavigationController?)
    func configureTabBarControllers() -> [UIViewController]
    func presentAddViewController(from viewController: UIViewController)
    func push(_ viewController: UIViewController, animated: Bool)
    func present(_ viewController: UIViewController, animated: Bool)
    func pop(animated: Bool)
}

final class AppRouter: RouterProtocol {
    static let shared: RouterProtocol = AppRouter()
    private weak var currentNavigationController: UINavigationController?
    
    private init() {}
}

// MARK: - TabBar navigation
extension AppRouter {
    func setCurrentNavigationController(_ navigationController: UINavigationController?) {
        currentNavigationController = navigationController
    }
    
    func configureTabBarControllers() -> [UIViewController] {
        let homeVC: MainViewController = MainViewController()
        let categoriesVC: CategoriesViewController = CategoriesModuleAssembler.assemble()
        let analyticsVC: AnalyticsViewController = AnalyticsModuleAssembler.assemble()
        let profileVC: ProfileViewController = ProfileModuleAssembler.assemble()
        
        return [
            generateTabBarItem(homeVC),
            generateTabBarItem(categoriesVC),
            generateTabBarItem(analyticsVC),
            generateTabBarItem(profileVC)
        ]
    }
    
    func presentAddViewController(from viewController: UIViewController) {
        let addVC = AddViewController()
        addVC.modalPresentationStyle = .pageSheet
        viewController.present(addVC, animated: true)
    }
}

// MARK: Navigation methods
extension AppRouter {
    func push(_ viewController: UIViewController, animated: Bool) {
        guard let navigationController = currentNavigationController else {
            print("Текущий UINavigationController равен nil")
            return
        }
        
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    func present(_ viewController: UIViewController, animated: Bool) {
        guard let navigationController = currentNavigationController else {
            return
        }
        
        navigationController.present(viewController, animated: animated)
    }
    
    func pop(animated: Bool) {
        guard let navigationController = currentNavigationController else {
            return
        }
        
        navigationController.popViewController(animated: animated)
    }
}

// MARK: - Private mathods
private extension AppRouter {
    func generateTabBarItem(_ rootViewController: UIViewController) -> UIViewController {
        let navigationVC = UINavigationController(rootViewController: rootViewController)
        
        return navigationVC
    }
}
