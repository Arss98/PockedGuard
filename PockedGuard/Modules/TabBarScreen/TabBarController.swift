//
//  TabBarController.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 08.03.2025.
//

import RxSwift
import RxCocoa

final class TabBarController: UITabBarController {
    // MARK: - Properties
    var isHiddenTabBar: Bool = false {
        didSet {
            animateTabBatVisibility()
        }
    }
    
    private lazy var customTabBar: CustomTabBar = .init()
    private let disposeBag: DisposeBag = .init()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupBindings()
        setFirstNavigationController()
        setConstraints()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tabBar.isHidden = true
    }
}

// MARK: - Setup tabbar methods
private extension TabBarController {
    func setupTabBar() {
        view.backgroundColor = .appBackground
        viewControllers = AppRouter.shared.configureTabBarControllers()
        view.addSubview(customTabBar)
    }
    
    func setupBindings() {
        customTabBar.buttonTapped
            .subscribe(onNext: { [weak self] index in
                guard let self else { return }
                self.selectedIndex = index
                self.customTabBar.selectButton(at: index)
            })
            .disposed(by: disposeBag)
        
        customTabBar.addButtonTapped
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                AppRouter.shared.presentAddViewController(from: self)
            })
            .disposed(by: disposeBag)
    }
    
    func setFirstNavigationController() {
        guard let navigationVC = viewControllers?.first as? UINavigationController else { return }
        AppRouter.shared.setCurrentNavigationController(navigationVC)
    }
}

// MARK: - Setup UI tabBar
private extension TabBarController {
    func animateTabBatVisibility() {
        UIView.animate(withDuration: Constants.animationDuration, delay: .zero,
                       options: [.curveEaseInOut]) { [weak self] in
            guard let self else { return }
            if self.isHiddenTabBar {
                self.customTabBar.transform = CGAffineTransform(
                    translationX: .zero,
                    y: self.customTabBar.frame.height + Constants.tabBarBottomPadding
                )
                self.customTabBar.alpha = .zero
            } else {
                self.customTabBar.transform = .identity
                self.customTabBar.alpha = 1
            }
        }
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            customTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.tabBarSidePadding),
            customTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.tabBarSidePadding),
            customTabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.tabBarBottomPadding)
        ])
    }
}

// MARK: - Constants
private enum Constants {
    static let tabBarSidePadding: CGFloat = 12
    static let tabBarBottomPadding: CGFloat = 8
    static let animationDuration: TimeInterval = 0.3
}
