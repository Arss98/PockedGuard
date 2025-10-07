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
    private let colorStorageService: ColorStorageServiceProtocol
    private let disposeBag: DisposeBag = .init()
    private var currentModalController: UIViewController?
    
    init(dataProvider: DataProviderProtocol) {
        self.dataProvider = dataProvider
        self.colorStorageService = ColorStorageService()
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
            .withLatestFrom(viewModel.input.transactionType)
            .subscribe(onNext: { [weak self] transactionType in
                self?.showCreateCategoryScreen(with: transactionType)
            })
            .disposed(by: disposeBag)
        
        viewModel.input.editCategoryTapped
            .subscribe(onNext: { [weak self] category in
                self?.showEditCategoryScreen(with: category)
            })
            .disposed(by: disposeBag)
        
        viewModel.input.addTemplateTapped
            .withLatestFrom(viewModel.input.transactionType)
            .subscribe(onNext: { [weak self] TransactionType in
                self?.showCreateTemplateScreen(with: TransactionType)
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
    
    func showCreateCategoryScreen(with transactionType: TransactionType) {
        let viewModel: CreateCategoryViewModelProtocol = CreateCategoryViewModel(
            initialTransactionType: transactionType,
            dataProvider: dataProvider,
            colorStorageService: colorStorageService
        )
        let viewController: CreateCategoryViewController = .init(viewModel: viewModel)
        
        navigationController?.present(viewController, animated: true)
        
        viewModel.output.dismiss
            .subscribe(onNext: { [weak self] in
                self?.finish()
            })
            .disposed(by: disposeBag)
    }
    
    func showEditCategoryScreen(with category: CategoryDomainModel) {
        let viewModel: CreateCategoryViewModelProtocol = CreateCategoryViewModel(
            mode: .edit(category),
            initialTransactionType: category.type,
            dataProvider: dataProvider,
            colorStorageService: colorStorageService
        )
        let viewController: CreateCategoryViewController = .init(viewModel: viewModel)
        
        navigationController?.present(viewController, animated: true)
        
        viewModel.output.dismiss
            .subscribe(onNext: { [weak self] in
                self?.finish()
            })
            .disposed(by: disposeBag)
    }
    
    func showCreateTemplateScreen(with transactionType: TransactionType) {
        let viewModel: CreateTemplateViewModelProtocol = CreateTemplateViewModel(
            initialTransactionType: transactionType,
            dataProvider: dataProvider
        )
        let viewController: CreateTemplateViewController = .init(viewModel: viewModel)
        
        navigationController?.present(viewController, animated: true)
        
        viewModel.output.dismiss
            .subscribe(onNext: { [weak self] in
                self?.finish()
            })
            .disposed(by: disposeBag)
    }
    
    func showEditTemplateScreen(with template: TemplateDomainModel) {
        let viewModel: CreateTemplateViewModelProtocol = CreateTemplateViewModel(
            mode: .edit(template),
            initialTransactionType: template.type,
            dataProvider: dataProvider
        )
        let viewController: CreateTemplateViewController = .init(viewModel: viewModel)
        
        navigationController?.present(viewController, animated: true)
        
        viewModel.output.dismiss
            .subscribe(onNext: { [weak self] in
                self?.finish()
            })
            .disposed(by: disposeBag)
    }
    
    func finish() {
        navigationController?.dismiss(animated: true)
    }
}
