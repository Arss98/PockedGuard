//
//  AddViewModel.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 08.03.2025.
//

import RxSwift
import RxCocoa

protocol AddViewModelProtocol {
    var input: AddViewModel.Input { get }
    var output: AddViewModel.Output { get }
    func fetchData(by type: TransactionType?)
}

final class AddViewModel: AddViewModelProtocol {
    // MARK: - Public properties
    let input: AddViewModel.Input
    let output: AddViewModel.Output
    
    // MARK: - Private properties
    private let disposeBag: DisposeBag = .init()
    private let coreDataService: CoreDataTransactionProtocol
    
    // MARK: - Init
    init(coreDataService: CoreDataTransactionProtocol = CoreDataService.shared) {
        self.coreDataService = coreDataService
        self.input = .init()
        self.output = .init()
        setupBinding()
    }
}

// MARK: - Publick methods
extension AddViewModel {
    func setupBinding() {
        input.selectedTemplate
            .subscribe(onNext: { [weak self] template in
                if let category: CategoryDomainModel = template?.category {
                    self?.input.selectedCategory.accept(category)
                }
                
                if let amount: Double = template?.amount, amount > 0 {
                    self?.input.amount.accept(amount)
                }
            })
            .disposed(by: disposeBag)
        
        input.transactionType
            .subscribe { [weak self] type in
                self?.fetchData(by: type)
            }
            .disposed(by: disposeBag)
        
        input.saveAction
            .subscribe(onNext: { [weak self] in
                self?.saveTransaction()
            })
            .disposed(by: disposeBag)
    }
    
    func fetchData(by type: TransactionType? = nil) {
        fetchAccounts(by: type)
        fetchTemplates(by: type)
        fetchCategories(by: type)
    }
}

// MARK: - Private methods
private extension AddViewModel {
    func validateData() throws {
        guard input.amount.value > 0 else { throw CustomError.invalidAmount }
        guard input.selectedCategory.value != nil else { throw CustomError.categoryNotSelected }
    }
    
    func saveTransaction() {
        do {
            try self.validateData()
            
            let transaction: TransactionDomainModel = .init(
                id: UUID(),
                amount: input.amount.value,
                date: Date(),
                type: input.transactionType.value ?? .income,
                paymentMethod: .card,
                notes: input.notes.value,
                category: input.selectedCategory.value,
                account: input.selectedAccount.value
            )
            
            self.coreDataService.addTransaction(transaction)
                .observe(on: MainScheduler.instance)
                .subscribe { [weak self] in
                    self?.input.dismiss.onNext(())
                    DataUpdateService.shared.notifyModalDismissed()
                } onError: { [weak self] error in
                    self?.output.error.onNext(error)
                }
                .disposed(by: disposeBag)
        } catch {
            output.error.onNext(error)
        }
    }
    
    func fetchAccounts(by type: TransactionType?) {
        coreDataService.fetchAccounts(by: type)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] accounts in
                guard !accounts.isEmpty else {
                    self?.output.error.onNext(CustomError.accountNotFound)
                    return
                }
                
                self?.output.accounts.accept(accounts)
                
                if let defaultAccount = accounts.first(
                    where: {$0.name == .Localized.Common.accountTitle.localized}) {
                    self?.input.selectedAccount.accept(defaultAccount)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func fetchTemplates(by type: TransactionType?) {
        coreDataService.fetchTemplates(by: type)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] templates in
                guard !templates.isEmpty else {
                    self?.output.error.onNext(CustomError.templatesEmpty)
                    return
                }
                
                self?.output.templates.accept(templates)
            })
            .disposed(by: disposeBag)
    }
    
    func fetchCategories(by type: TransactionType?) {
        coreDataService.fetchCategories(by: type)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] categories in
                guard !categories.isEmpty else {
                    self?.output.error.onNext(CustomError.categoriesEmpty)
                    return
                }
                
                self?.output.categories.accept(categories)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Input, Output struct
extension AddViewModel {
    struct Input {
        let saveAction: PublishSubject<Void> = .init()
        let amount: BehaviorRelay<Double> = .init(value: 0)
        let notes: BehaviorRelay<String> = .init(value: "")
        let transactionType: BehaviorRelay<TransactionType?> = .init(value: nil)
        let selectedCategory: BehaviorRelay<CategoryDomainModel?> = .init(value: nil)
        let selectedTemplate: BehaviorRelay<TemplatesDomainModel?> = .init(value: nil)
        let selectedAccount: BehaviorRelay<AccountDomainModel?> = .init(value: nil)
        let dismiss: PublishSubject<Void> = .init()
    }
    
    struct Output {
        let error: PublishSubject<Error> = .init()
        let accounts: BehaviorRelay<[AccountDomainModel]> = .init(value: [])
        let templates: BehaviorRelay<[TemplatesDomainModel]> = .init(value: [])
        let categories: BehaviorRelay<[CategoryDomainModel]> = .init(value: [])
    }
}

// MARK: - Errors
private enum CustomError: Error, LocalizedError {
    case invalidAmount
    case categoryNotSelected
    case accountNotFound
    case templatesEmpty
    case categoriesEmpty
    case coreDataFailure(String)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidAmount:
            return .Localized.Error.amountError.localized
        case .categoryNotSelected:
            return .Localized.Add.categoryNotSelectedError.localized
        case .accountNotFound:
            return .Localized.Error.accountEmpty.localized
        case .templatesEmpty:
            return .Localized.Error.templatesEmpty.localized
        case .categoriesEmpty:
            return .Localized.Error.categoriesEmpty.localized
        case .coreDataFailure(let message):
            return message
        case .unknown:
            return .Localized.Error.unknown.localized
        }
    }
}
