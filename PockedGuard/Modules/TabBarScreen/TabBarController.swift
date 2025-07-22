//
//  TabBarController.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 08.03.2025.
//

import RxSwift
import RxCocoa

final class TabBarController: UITabBarController {
    // MARK: - Public properties
    var onAddButtonTapped: (() -> Void)?
    var isHiddenTabBar: Bool = false {
        didSet { animateTabBatVisibility() }
    }
    
    // MARK: - Private properties
    private lazy var customTabBar: CustomTabBar = .init()
    private let disposeBag: DisposeBag = .init()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupBindings()
        setConstraints()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tabBar.isHidden = true
    }
    
    // MARK: - Public method
    func setViewControllers(_ controllers: [UIViewController]) {
        viewControllers = controllers
        customTabBar.selectButton(at: 0)
    }
}

// MARK: - Setup tabbar methods
private extension TabBarController {
    func setupTabBar() {
        view.backgroundColor = .appBackground
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
            .subscribe(with: self, onNext: { controller, _ in
                controller.onAddButtonTapped?()
            })
            .disposed(by: disposeBag)
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
