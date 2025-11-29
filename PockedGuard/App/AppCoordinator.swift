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
    
    // MARK: - Private properties
    private let window: UIWindow
    private let coreDataService: CoreDataServiceProtocol
    private let dataProvider: DataProviderProtocol
    private let disposeBag: DisposeBag = .init()
    private let animatedDuration: TimeInterval = 0.35
    
    init(window: UIWindow) {
        self.window = window
        self.coreDataService = CoreDataService()
        self.dataProvider = DataProvider(coreDataService: coreDataService)
    }
    
    func start() {
        let hasCompletedOnboarding: Bool = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        let hasPinCreated: Bool = KeychainService.shared.isUserPinSet()
        
        if !hasCompletedOnboarding {
            startOnboardingFlow()
        } else if !hasPinCreated {
            startPinFlow(mode: .createNew)
        } else {
            startPinFlow(mode: .authenticate)
        }
    }
}

// MARK: - Animate methods
private extension AppCoordinator {
    func setRootViewController(
        _ newRoot: UIViewController?,
        animated: Bool = true,
        animationType: UIView.AnimationOptions = .transitionCrossDissolve,
    ) {
        if window.rootViewController == nil {
            window.rootViewController = newRoot
            window.makeKeyAndVisible()
            return
        }
        
        guard animated else {
            window.rootViewController = newRoot
            return
        }
        
        UIView.transition(with: window, duration: animatedDuration, options: animationType) {
            let wasAnimationsEnabled: Bool = UIView.areAnimationsEnabled
            UIView.setAnimationsEnabled(false)
            self.window.rootViewController = newRoot
            UIView.setAnimationsEnabled(wasAnimationsEnabled)
        }
    }
}

// MARK: - Switch root view methods
private extension AppCoordinator {
    func startOnboardingFlow() {
        let onboardingCoordinator: OnboardingCoordinator = .init { [weak self] in
            self?.onboardingCompleted()
        }
        
        addChildCoordinator(onboardingCoordinator)
        onboardingCoordinator.start()
        
        setRootViewController(onboardingCoordinator.navigationController, animated: false)
    }
    
    func onboardingCompleted() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        if let onboardingCoordinator = childCoordinators.first(where: { $0 is OnboardingCoordinator }) {
            removeChildCoordinator(onboardingCoordinator)
        }
        
        startPinFlow(mode: .createNew)
    }
    
    func startPinFlow(mode: PinCoordinator.Mode) {
        let pinCoordinator: PinCoordinator = .init(mode: mode) { [weak self] in
                self?.pinFlowCompleted()
        }
        
        addChildCoordinator(pinCoordinator)
        pinCoordinator.start()
        
        setRootViewController(pinCoordinator.navigationController)
    }
    
    func pinFlowCompleted() {
        if let pinCoordinator = childCoordinators.first(where: { $0 is PinCoordinator }) {
            removeChildCoordinator(pinCoordinator)
        }
        
        startMainFlow()
    }
    
    func startMainFlow() {
        let tabBarCoordinator: TabBarCoordinator = .init(dataProvider: dataProvider)
        addChildCoordinator(tabBarCoordinator)
        tabBarCoordinator.start()
        
        setRootViewController(tabBarCoordinator.tabBarController)
    }
}
