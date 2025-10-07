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
}

final class AddViewModel: AddViewModelProtocol {
    // MARK: - Public properties
    let input: AddViewModel.Input
    let output: AddViewModel.Output
    
    // MARK: - Private properties
    private let disposeBag: DisposeBag = .init()
    private let dataProvider: DataProviderProtocol
    
    // MARK: - Init
    init(dataProvider: DataProviderProtocol) {
        self.dataProvider = dataProvider
        self.input = .init()
        self.output = .init()
        setupBinding()
    }
}

// MARK: - Private methods
private extension AddViewModel {
    func setupBinding() {
        setupInputBindings()
        dataProviderBindings()
    }
    
    func setupInputBindings() {
        input.selectedTemplate
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] template in
                if let category: CategoryDomainModel = template?.category {
                    self?.input.selectedCategory.accept(category)
                }
                
                if let amount: Double = template?.amount, amount > 0 {
                    self?.input.amountFromTemplate.onNext(amount)
                    self?.input.amount.accept(amount)
                }
            })
            .disposed(by: disposeBag)
        
        input.selectedAccount
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] account in
                let symbol: String = account?.currency.symbol ?? ""
                self?.output.currecySymbol.accept(symbol)
            })
            .disposed(by: disposeBag)
        
        input.transactionType
            .distinctUntilChanged()
            .subscribe { [weak self] type in
                self?.fetchData(type)
                self?.resetSelectedData()
            }
            .disposed(by: disposeBag)
        
        input.saveAction
            .subscribe(onNext: { [weak self] in
                self?.saveTransaction()
            })
            .disposed(by: disposeBag)
    }
    
    func dataProviderBindings() {
        dataProvider.accounts.accounts
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

        
        dataProvider.template.templates
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: output.templates)
            .disposed(by: disposeBag)
        
        dataProvider.categories.categories
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
    
    
    func fetchData(_ type: TransactionType) {
        dataProvider.categories.currentTransactionType.accept(type)
        dataProvider.template.currentTransactionType.accept(type)
    }
    
    func resetSelectedData() {
        self.input.amountFromTemplate.onNext(0)
        self.input.selectedCategory.accept(nil)
        self.input.selectedTemplate.accept(nil)
    }
    
    func validateData() throws {
        guard input.amount.value > 0 else { throw CustomError.invalidAmount }
        guard input.selectedCategory.value != nil else { throw CustomError.categoryNotSelected }
        
        guard let selectedAccount = input.selectedAccount.value else { throw CustomError.accountNotFound }
        if input.transactionType.value == .expense && input.amount.value > selectedAccount.balance {
            throw CustomError.insufficientFunds
        }
    }
    
    func saveTransaction() {
        do {
            try self.validateData()
            
            let transaction: TransactionDomainModel = .init(
                id: UUID(),
                amount: input.amount.value,
                date: Date(),
                type: input.transactionType.value,
                paymentMethod: .card,
                notes: input.notes.value,
                category: input.selectedCategory.value,
                account: input.selectedAccount.value)
            
            self.dataProvider.transaction.createTransaction(transaction)
                .andThen(self.updateAccountBalance(transaction: transaction))
                .observe(on: MainScheduler.instance)
                .subscribe { [weak self] in
                    self?.input.dismiss.onNext(())
                } onError: { [weak self] error in
                    self?.output.error.onNext(error)
                }
                .disposed(by: disposeBag)
        } catch {
            output.error.onNext(error)
        }
    }
    
    func updateAccountBalance(transaction: TransactionDomainModel) -> Completable {
        guard let account = transaction.account else {
            return .error(CustomError.accountNotFound)
        }
        
        let newBalance: Double
        switch transaction.type {
        case .income:
            newBalance = account.balance + transaction.amount
        case .expense:
            newBalance = account.balance - transaction.amount
        }
        
        return dataProvider.accounts.updateAccount(
            id: account.id,
            newName: nil,
            newBalance: newBalance,
            newCurrencyType: nil
        )
        .asCompletable()
    }
}

// MARK: - Input, Output struct
extension AddViewModel {
    struct Input {
        let saveAction: PublishSubject<Void> = .init()
        let amount: BehaviorRelay<Double> = .init(value: 0)
        let amountFromTemplate: PublishSubject<Double> = .init()
        let notes: BehaviorRelay<String> = .init(value: "")
        let transactionType: BehaviorRelay<TransactionType> = .init(value: .expense)
        let selectedCategory: BehaviorRelay<CategoryDomainModel?> = .init(value: nil)
        let selectedTemplate: BehaviorRelay<TemplateDomainModel?> = .init(value: nil)
        let selectedAccount: BehaviorRelay<AccountDomainModel?> = .init(value: nil)
        let dismiss: PublishSubject<Void> = .init()
    }
    
    struct Output {
        let error: PublishSubject<Error> = .init()
        let accounts: BehaviorRelay<[AccountDomainModel]> = .init(value: [])
        let templates: BehaviorRelay<[TemplateDomainModel]> = .init(value: [])
        let categories: BehaviorRelay<[CategoryDomainModel]> = .init(value: [])
        let currecySymbol: BehaviorRelay<String> = .init(value: "")
    }
}

// MARK: - Errors
private enum CustomError: Error, LocalizedError {
    case invalidAmount
    case insufficientFunds
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
        case .insufficientFunds:
            return .Localized.Error.insufficientFunds.localized
        case .categoryNotSelected:
            return .Localized.Error.categoryNotSelectedError.localized
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
