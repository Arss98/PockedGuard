//
//  CategoriesCoordinator.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 20.07.2025.
//

import RxSwift

final class CategoriesCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController?
    private let dataProvider: DataProviderProtocol
    private let disposeBag: DisposeBag = .init()
    
    init(dataProvider: DataProviderProtocol) {
        self.dataProvider = dataProvider
        self.navigationController = .init()
    }
    
    func start() {
        showCategoriesScreen()
    }
}

// MARK: - Private methods
private extension CategoriesCoordinator {
    func showCategoriesScreen() {
        let viewModel: CategoriesViewModelProtocol = CategoriesViewModel(dataProvider: dataProvider)
        let viewController: CategoriesViewController = .init(viewModel: viewModel)
        
        navigationController?.pushViewController(viewController, animated: true)
        
        viewModel.input.addAccountTapped
            .subscribe(onNext: { [weak self] in
                self?.showCreateAccountScreen()
            })
            .disposed(by: disposeBag)
        
        viewModel.input.editAccountTapped
            .subscribe(onNext: { [weak self] account in
                self?.showEditAccountScreen(with: account)
            })
            .disposed(by: disposeBag)
        
        viewModel.input.addCategoryTapped
            .subscribe(onNext: { [weak self] in
                self?.showCreateCategoryScreen()
            })
            .disposed(by: disposeBag)
        
        viewModel.input.editCategoryTapped
            .subscribe(onNext: { [weak self] category in
                self?.showEditCategoryScreen(with: category)
            })
            .disposed(by: disposeBag)
        
        viewModel.input.addTemplateTapped
            .subscribe(onNext: { [weak self] in
                self?.showCreateTemplateScreen()
            })
            .disposed(by: disposeBag)
        
        viewModel.input.editTemplateTapped
            .subscribe(onNext: { [weak self] template in
                self?.showEditTemplateScreen(with: template)
            })
            .disposed(by: disposeBag)
    }
    
    func showCreateAccountScreen() {
        let viewModel: CreateAccountViewModelProtocol = CreateAccountViewModel(dataProvider: dataProvider)
        let viewController: CreateAccountViewController = .init(viewModel: viewModel)
        
        navigationController?.present(viewController, animated: true)
        
        viewModel.output.dismiss
            .subscribe(onNext: { [weak self] in
                self?.finish()
            })
            .disposed(by: disposeBag)
    }
    
    func showEditAccountScreen(with account: AccountDomainModel) {
        let viewModel: CreateAccountViewModelProtocol = CreateAccountViewModel(mode: .edit(account), dataProvider: dataProvider)
        let viewController: CreateAccountViewController = .init(viewModel: viewModel)
        
        navigationController?.present(viewController, animated: true)
        
        viewModel.output.dismiss
            .subscribe(onNext: { [weak self] in
                self?.finish()
            })
            .disposed(by: disposeBag)
    }
    
    func showCreateCategoryScreen() {
        let viewModel: CreateCategoryViewModelProtocol = CreateCategoryViewModel(dataProvider: dataProvider)
        let viewController: CreateCategoryViewController = .init(viewModel: viewModel)
        
        navigationController?.present(viewController, animated: true)
        
        viewModel.output.dismiss
            .subscribe(onNext: { [weak self] in
                self?.finish()
            })
            .disposed(by: disposeBag)
    }
    
    func showEditCategoryScreen(with category: CategoryDomainModel) {
        let viewModel: CreateCategoryViewModelProtocol = CreateCategoryViewModel(mode: .edit(category),
                                                                                 dataProvider: dataProvider)
        let viewController: CreateCategoryViewController = .init(viewModel: viewModel)
        
        navigationController?.present(viewController, animated: true)
        
        viewModel.output.dismiss
            .subscribe(onNext: { [weak self] in
                self?.finish()
            })
            .disposed(by: disposeBag)
    }
    
    func showCreateTemplateScreen() {
        
    }
    
    func showEditTemplateScreen(with template: TemplateDomainModel) {
        
    }
    
    func finish() {
        navigationController?.dismiss(animated: true)
    }
}
