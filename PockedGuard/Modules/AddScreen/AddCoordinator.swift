//
//  AddCoordinator.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 20.07.2025.
//

import RxSwift

final class AddCoordinator: Coordinator {
    // MARK: - Public properties
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController? { nil }
    
    // MARK: - Private properties
    private weak var presentingViewController: UIViewController?
    private let dataProvider: DataProviderProtocol
    private let disposeBag: DisposeBag = .init()
    
    init(dataProvider: DataProviderProtocol, presentingViewController: UIViewController?) {
        self.dataProvider = dataProvider
        self.presentingViewController = presentingViewController
    }
    
    func start() {
        showAddScreen()
    }
}

// MARK: - Private methods
private extension AddCoordinator {
    func showAddScreen() {
        let viewModel: AddViewModelProtocol = AddViewModel(dataProvider: dataProvider)
        let viewController: AddViewController = .init(viewModel: viewModel)
        
        viewController.modalPresentationStyle = .pageSheet
        presentingViewController?.present(viewController, animated: true)
        
        viewModel.input.dismiss
            .subscribe(onNext: { [weak self] in
                self?.finish()
            })
            .disposed(by: disposeBag)
    }
    
    func finish() {
        presentingViewController?.dismiss(animated: true)
    }
}
