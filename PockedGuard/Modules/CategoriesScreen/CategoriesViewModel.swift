//
//  CategoriesViewModel.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 08.03.2025.
//

import RxSwift
import RxCocoa

protocol CategoriesViewModelProtocol {
    var input: CategoriesViewModel.Input { get }
    var output: CategoriesViewModel.Output { get }
}

final class CategoriesViewModel: CategoriesViewModelProtocol {
    // MARK: - Public properties
    let input: Input
    let output: Output
    
    // MARK: - Private properties
    private let disposeBag: DisposeBag = .init()
    private let dataProvider: DataProviderProtocol
    
    init(dataProvider: DataProviderProtocol) {
        self.dataProvider = dataProvider
        self.input = .init()
        self.output = .init()
        setupBindings()
    }
}

// MARK: - Binding methods
private extension CategoriesViewModel {
    func setupBindings() {
        setupDataBinding()
        setupCategoryBinding()
        setupDeleteBinding()
    }
    
    func setupDataBinding() {
        input.transactionType
            .subscribe(with: self) { viewModel, type in
                viewModel.fetchData(by: type)
            }
            .disposed(by: disposeBag)
        
        dataProvider.accounts.accounts
            .observe(on: MainScheduler.asyncInstance)
            .map { accounts -> [AccountItemType] in
                let accountItems: [AccountItemType] = accounts.map { AccountItemType.account($0)}
                return accountItems + [.add]
            }
            .bind(to: output.accounts)
            .disposed(by: disposeBag)
        
        dataProvider.template.templates
            .observe(on: MainScheduler.asyncInstance)
            .map { templates -> [TemplatesItemType] in
                let templateItems: [TemplatesItemType] = templates.map { TemplatesItemType.template($0)}
                return templateItems + [.add]
            }
            .bind(to: output.templates)
            .disposed(by: disposeBag)
        
        dataProvider.categories.categories
            .observe(on: MainScheduler.asyncInstance)
            .map { categories -> [CategoryItemType] in
                let categoryItems: [CategoryItemType] = categories.map { CategoryItemType.category($0)}
                return categoryItems + [.add]
            }
            .bind(to: output.categories)
            .disposed(by: disposeBag)
    }
    
    func setupCategoryBinding() {
        input.categoryAction
            .subscribe(onNext: { [weak self] data in
                self?.handleCategoryAction(data.category, action: data.action)
            })
            .disposed(by: disposeBag)
        
        input.confirmCategoryAction
            .subscribe(onNext: { [weak self] data in
                self?.executeCategoryAction(data.category, action: data.action)
            })
            .disposed(by: disposeBag)
    }
    
    func setupDeleteBinding() {
        input.deleteAccountTapped
            .subscribe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] id in
                self?.deleteAccount(by: id)
            })
            .disposed(by: disposeBag)
        
        input.deleteTemplateTapped
            .subscribe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] id in
                self?.deleteTemplate(by: id)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Private methods
private extension CategoriesViewModel {
    func fetchData(by type: TransactionType?) {
        guard let type else { return }
        dataProvider.categories.currentTransactionType.accept(type)
        dataProvider.template.currentTransactionType.accept(type)
    }
    
    func handleCategoryAction(_ category: CategoryDomainModel, action: CategoryAction) {
        if category.isSystem {
            output.showSystemCategoryAlert.onNext((category, action))
        } else {
            executeCategoryAction(category, action: action)
        }
    }
    
    func executeCategoryAction(_ category: CategoryDomainModel, action: CategoryAction) {
        switch action {
        case .edit:
            input.editCategoryTapped.onNext(category)
        case .delete:
            deleteCategory(by: category.id)
        }
    }
    
    func deleteAccount(by id: UUID) {
        output.isLoading.accept(true)
        
        dataProvider.accounts.deleteAccount(with: id)
            .subscribe { [weak self] in
                self?.output.isLoading.accept(false)
            } onError: { [weak self] error in
                self?.output.isLoading.accept(false)
                self?.output.error.onNext(error)
            }
            .disposed(by: disposeBag)
    }
    
    func deleteCategory(by id: UUID) {
        output.isLoading.accept(true)
        
        dataProvider.categories.deleteCategory(with: id)
            .subscribe { [weak self] in
                self?.output.isLoading.accept(false)
            } onError: { [weak self] error in
                self?.output.isLoading.accept(false)
                self?.output.error.onNext(error)
            }
            .disposed(by: disposeBag)
    }
    
    func deleteTemplate(by id: UUID) {
        output.isLoading.accept(true)
        
        dataProvider.template.deleteTemplate(with: id)
            .subscribe { [weak self] in
                self?.output.isLoading.accept(false)
            } onError: { [weak self] error in
                self?.output.isLoading.accept(false)
                self?.output.error.onNext(error)
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Input, Output
extension CategoriesViewModel {
    struct Input {
        let transactionType: BehaviorRelay<TransactionType> = .init(value: .expense)
        let addCategoryTapped: PublishSubject<Void> = .init()
        let editCategoryTapped: PublishSubject<CategoryDomainModel> = .init()
        let addAccountTapped: PublishSubject<Void> = .init()
        let editAccountTapped: PublishSubject<AccountDomainModel> = .init()
        let deleteAccountTapped: PublishSubject<UUID> = .init()
        let addTemplateTapped: PublishSubject<Void> = .init()
        let editTemplateTapped: PublishSubject<TemplateDomainModel> = .init()
        let deleteTemplateTapped: PublishSubject<UUID> = .init()
        let categoryAction: PublishSubject<(category: CategoryDomainModel, action: CategoryAction)> = .init()
        let confirmCategoryAction: PublishSubject<(category: CategoryDomainModel, action: CategoryAction)> = .init()
    }
    
    struct Output {
        let error: PublishSubject<Error> = .init()
        let isLoading: BehaviorRelay<Bool> = .init(value: false)
        let accounts: BehaviorRelay<[AccountItemType]> = .init(value: [])
        let templates: BehaviorRelay<[TemplatesItemType]> = .init(value: [])
        let categories: BehaviorRelay<[CategoryItemType]> = .init(value: [])
        let showSystemCategoryAlert: PublishSubject<(category: CategoryDomainModel, action: CategoryAction)> = .init()
    }
    
    enum CategoryAction {
        case delete
        case edit
    }
}

// MARK: - Errors
private enum CustomError: Error, LocalizedError {
    case accountNotFound
    case templatesEmpty
    case categoriesEmpty
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .accountNotFound:
            return .Localized.Error.accountEmpty.localized
        case .templatesEmpty:
            return .Localized.Error.templatesEmpty.localized
        case .categoriesEmpty:
            return .Localized.Error.categoriesEmpty.localized
        case .unknown:
            return .Localized.Error.unknown.localized
        }
    }
}
