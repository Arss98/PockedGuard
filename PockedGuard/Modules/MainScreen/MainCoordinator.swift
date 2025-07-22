//
//  MainCoordinator.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 20.07.2025.
//

import RxSwift

final class MainCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController?
    private let disposeBag: DisposeBag = .init()
    
    init() {
        self.navigationController = .init()
    }
    
    func start() {
        showMainScreen()
    }
}

// MARK: - Private methods
private extension MainCoordinator {
    func showMainScreen() {
        let viewModel: MainViewModelProtocol = MainViewModel()
        let viewController: MainViewController = .init(viewModel: viewModel)
        
        viewModel.output.showNotification
            .subscribe(with: self) { controller, _ in
                controller.showNotificationScreen()
            }
            .disposed(by: disposeBag)
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func showNotificationScreen() {
        let viewModel: NotificationViewModelProtocol = NotificationViewModel()
        let viewController: NotificationViewController = .init(viewModel: viewModel)
        
        viewModel.input.createNotificationTapped
            .subscribe(with: self) { controller, _ in
                controller.showCreateNotificationScreen(mode: .add)
            }
            .disposed(by: disposeBag)
        
        viewModel.input.selectedNotification
            .subscribe(with: self) { controller, notification in
                controller.showCreateNotificationScreen(mode: .edit(notification))
            }
            .disposed(by: disposeBag)
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func showCreateNotificationScreen(mode: CreateNotificationViewModel.Mode) {
        let viewModel: CreateNotificationViewModelProtocol = CreateNotificationViewModel(mode: mode)
        let viewController: CreateNotificationViewController = .init(viewModel: viewModel)
        
        viewModel.output.didFinish
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { controller, _ in
                controller.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        navigationController?.pushViewController(viewController, animated: true)
    }
}
