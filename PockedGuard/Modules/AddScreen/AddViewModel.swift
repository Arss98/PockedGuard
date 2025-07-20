//
//  AddViewModel.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 08.03.2025.
//

import RxSwift
import RxCocoa

protocol AddViewModelProtocol {
    var error: Observable<Error> { get }
    var amount: BehaviorRelay<Double> { get }
    var notes: BehaviorRelay<String> { get }
    var transactionType: BehaviorRelay<TransactionType?> { get }
    var accounts: BehaviorRelay<[AccountDomainModel]> { get }
    var templates: BehaviorRelay<[TemplatesDomainModel]> { get }
    var categories: BehaviorRelay<[CategoryDomainModel]> { get }
    var selectedCategory: BehaviorRelay<CategoryDomainModel?> { get }
    var selectedTemplate: BehaviorRelay<TemplatesDomainModel?> { get }
    var selectedAccount: BehaviorRelay<AccountDomainModel?> { get }
    func fetchData(by type: TransactionType?)
    func saveTransaction() -> Completable
}

final class AddViewModel: AddViewModelProtocol {
    // MARK: - Public properties
    let amount: BehaviorRelay<Double> = .init(value: 0)
    let notes: BehaviorRelay<String> = .init(value: "")
    let transactionType: BehaviorRelay<TransactionType?> = .init(value: nil)
    let accounts: BehaviorRelay<[AccountDomainModel]> = .init(value: [])
    let templates: BehaviorRelay<[TemplatesDomainModel]> = .init(value: [])
    let categories: BehaviorRelay<[CategoryDomainModel]> = .init(value: [])
    let selectedCategory: BehaviorRelay<CategoryDomainModel?> = .init(value: nil)
    let selectedTemplate: BehaviorRelay<TemplatesDomainModel?> = .init(value: nil)
    let selectedAccount: BehaviorRelay<AccountDomainModel?> = .init(value: nil)
    
    var error: Observable<Error> {
        return errorSubject.asObservable()
    }
    
    // MARK: - Private properties
    private let errorSubject = PublishSubject<Error>()
    private let disposeBag: DisposeBag = .init()
    private let coreDataService: CoreDataTransactionProtocol
    
    // MARK: - Init
    init(coreDataService: CoreDataTransactionProtocol = CoreDataService.shared) {
        self.coreDataService = coreDataService
        selectTemplate()
    }
}

// MARK: - Publick methods
extension AddViewModel {
    func selectTemplate() {
        selectedTemplate
            .subscribe(onNext: { [weak self] template in
                if let category: CategoryDomainModel = template?.category {
                    self?.selectedCategory.accept(category)
                }
                
                if let amount: Double = template?.amount, amount > 0 {
                    self?.amount.accept(amount)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func saveTransaction() -> Completable {
        return Completable.create { [weak self] complateble in
            guard let self else {
                complateble(.error(CustomError.unknown))
                return Disposables.create()
            }
            
            do {
                try self.validateData()
                
                let transaction: TransactionDomainModel = .init(
                    id: UUID(),
                    amount: amount.value,
                    date: Date(),
                    type: transactionType.value ?? .income,
                    paymentMethod: .card,
                    notes: notes.value,
                    category: selectedCategory.value,
                    account: selectedAccount.value
                )
                
                self.coreDataService.addTransaction(transaction)
                    .subscribe {
                        complateble(.completed)
                    } onError: { error in
                        complateble(.error(error))
                    }
                    .disposed(by: self.disposeBag)
            } catch {
                complateble(.error(error))
            }
            
            return Disposables.create()
        }
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
        guard amount.value > 0 else {
            throw CustomError.invalidAmount
        }
        
        guard selectedCategory.value != nil else {
            throw CustomError.categoryNotSelected
        }
    }
    
    func fetchAccounts(by type: TransactionType?) {
        coreDataService.fetchAccounts(by: type)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] accounts in
                guard !accounts.isEmpty else {
                    self?.errorSubject.onNext(CustomError.accountNotFound)
                    return
                }
                
                self?.accounts.accept(accounts)
                
                if let defaultAccount = accounts.first(
                    where: {$0.name == .Localized.Common.accountTitle.localized}) {
                    self?.selectedAccount.accept(defaultAccount)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func fetchTemplates(by type: TransactionType?) {
        coreDataService.fetchTemplates(by: type)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] templates in
                guard !templates.isEmpty else {
                    self?.errorSubject.onNext(CustomError.templatesEmpty)
                    return
                }
                
                self?.templates.accept(templates)
            })
            .disposed(by: disposeBag)
    }
    
    func fetchCategories(by type: TransactionType?) {
        coreDataService.fetchCategories(by: type)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] categories in
                guard !categories.isEmpty else {
                    self?.errorSubject.onNext(CustomError.categoriesEmpty)
                    return
                }
                
                self?.categories.accept(categories)
            })
            .disposed(by: disposeBag)
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
            return .Localized.Add.amountError.localized
        case .categoryNotSelected:
            return .Localized.Add.categoryNotSelectedError.localized
        case .accountNotFound:
            return .Localized.Common.accountNotFoundError.localized
        case .templatesEmpty:
            return .Localized.Common.templatesEmptyError.localized
        case .categoriesEmpty:
            return .Localized.Common.categoriesEmptyError.localized
        case .coreDataFailure(let message):
            return message
        case .unknown:
            return .Localized.Common.unknownError.localized
        }
    }
}
