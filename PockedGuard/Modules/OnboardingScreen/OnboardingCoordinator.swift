//
//  OnboardingCoordinator.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 08.10.2025.
//

import UIKit
import RxSwift

final class OnboardingCoordinator: Coordinator {
    
    // MARK: - Public properties
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController?
    
    // MARK: - Private properties
    private let disposeBag: DisposeBag = .init()
    private var onFinish: (() -> Void)?
    
    // MARK: - Init
    init(onFinish: (() -> Void)? = nil) {
        self.navigationController = .init()
        self.onFinish = onFinish
    }
    
    func start() {
        showOnboardingScreen()
    }
}

// MARK: - Private methods
private extension OnboardingCoordinator {
    func showOnboardingScreen() {
        let onboardingPages: [UIViewController] = [
            OnboardingWelcomeViewController(),
            OnboardingAnalyticsViewController(),
            OnboardingTemplatesViewController(),
            OnboardingNotificationsViewController()
        ]
        
        let viewModel: OnboardingViewModelProtocol = OnboardingViewModel(pages: onboardingPages)
        let pageViewController: OnboardingPageViewController = .init(viewModel: viewModel)
        
        viewModel.input.didFinishOnboarding
            .subscribe(onNext: { [weak self] in
                self?.didFinishOnboarding()
            })
            .disposed(by: disposeBag)
        
        navigationController?.setViewControllers([pageViewController], animated: false)
        navigationController?.isNavigationBarHidden = true
    }
    
    func didFinishOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")        
        onFinish?()
    }
}
