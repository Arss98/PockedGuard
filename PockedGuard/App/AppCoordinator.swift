//
//  AppCoordinator.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 20.07.2025.
//

import UIKit
import RxSwift

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController? { get }
    func start()
}

extension Coordinator {
    func addChildCoordinator(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }
    
    func removeChildCoordinator(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
}

final class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController? { nil }
    private let window: UIWindow
    private let coreDataService: CoreDataServiceProtocol
    private let dataProvider: DataProviderProtocol
    private let disposeBag: DisposeBag = .init()
    
    init(window: UIWindow) {
        self.window = window
        self.coreDataService = CoreDataService()
        self.dataProvider = DataProvider(coreDataService: coreDataService)
    }
    
    func start() {
        let hasCompletedOnboarding: Bool = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        hasCompletedOnboarding ? startMainFlow() : startOnboardingFlow()
    }
}

// MARK: - Private methods
private extension AppCoordinator {
    func startOnboardingFlow() {
        let onboardingCoordinator = OnboardingCoordinator { [weak self] in
            self?.onboardingCompleted()
        }
        
        addChildCoordinator(onboardingCoordinator)
        onboardingCoordinator.start()
        
        window.rootViewController = onboardingCoordinator.navigationController
        window.makeKeyAndVisible()
    }
    
    func onboardingCompleted() {
        if let onboardingCoordinator = childCoordinators.first(where: { $0 is OnboardingCoordinator }) {
            removeChildCoordinator(onboardingCoordinator)
        }
        
        startMainFlow()
    }
    
    func startMainFlow() {
        let tabBarCoordinator: TabBarCoordinator = .init(dataProvider: dataProvider)
        addChildCoordinator(tabBarCoordinator)
        tabBarCoordinator.start()
        
        window.rootViewController = tabBarCoordinator.tabBarController
        window.makeKeyAndVisible()
    }
}
