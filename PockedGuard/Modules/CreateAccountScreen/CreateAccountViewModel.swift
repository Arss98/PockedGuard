//
//  CreateAccountViewModel.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 20.09.2025.
//

import RxSwift
import RxCocoa

protocol CreateAccountViewModelProtocol {
    var input: CreateAccountViewModel.Input { get }
    var output: CreateAccountViewModel.Output { get }
    var mode: CreateAccountViewModel.Mode { get }
}

final class CreateAccountViewModel: CreateAccountViewModelProtocol {
    // MARK: - Public properties
    let input: CreateAccountViewModel.Input
    let output: CreateAccountViewModel.Output
    let mode: Mode
    
    // MARK: - Private properties
    private let dataProvider: DataProviderProtocol
    private let disposeBag: DisposeBag = .init()
    
    enum Mode {
        case add
        case edit(AccountDomainModel)
    }
    
    // MARK: - Init
    init(mode: Mode = .add, dataProvider: DataProviderProtocol) {
        self.mode = mode
        self.dataProvider = dataProvider
        self.input = .init()
        self.output = .init()
        setInitialValues()
        setupBindings()
    }
}

// MARK: - Private methods
private extension CreateAccountViewModel {
    func setupBindings() {
        input.saveAction
            .subscribe(onNext: { [weak self] in
                self?.saveAccount()
            })
            .disposed(by: disposeBag)
    }
    
    func setInitialValues() {
        if case .edit(let account) = mode {
            input.title.accept(account.name)
            input.currencyType.accept(account.currency)
        }
    }
    
    func validateInput() throws {
        guard !input.title.value.isEmpty else { throw CustomError.invalidTitle }
        
        if let dublicateError = checkDublicateAccountName() { throw dublicateError}
    }
    
    func saveAccount() {
        output.isLoading.accept(true)
        
        do {
            try validateInput()
            let operation: Completable = {
                switch mode {
                case .add: createAccount()
                case .edit(let account): editAccount(account)
                }
            }()
            
            operation.subscribe { [weak self] in
                self?.output.dismiss.onNext(())
                self?.output.isLoading.accept(false)
            } onError: { [weak self] error in
                self?.output.error.onNext(error)
                self?.output.isLoading.accept(false)
            }
            .disposed(by: disposeBag)
        } catch {
            output.error.onNext(error)
            output.isLoading.accept(false)
        }
    }
    
    func createAccount() -> Completable {
        let account: AccountDomainModel = .init(
            id: UUID(),
            name: input.title.value,
            balance: 0,
            currency: input.currencyType.value,
            isPrimary: false
        )
         
        return dataProvider.accounts.addAccount(account)
    }
    
    func editAccount(_ account: AccountDomainModel) -> Completable {
        dataProvider.accounts.updateAccount(
            id: account.id,
            newName: input.title.value,
            newBalance: nil,
            newCurrencyType: input.currencyType.value
        )
        .asCompletable()
    }
    
    func checkDublicateAccountName() -> CustomError? {
        let currentName: String = input.title.value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !currentName.isEmpty else { return nil }
        
        let accounts: [AccountDomainModel] = dataProvider.accounts.getAccounts()
        
        let dublicateAccount: AccountDomainModel? = accounts.first { account in
            let existingName: String = account.name.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if existingName.caseInsensitiveCompare(currentName) == .orderedSame {
                if case .edit(let currentAccount) = mode {
                    return account.id != currentAccount.id
                }
                return true
            }
            return false
        }
        
        return dublicateAccount != nil ? .duplicateNameAccount : nil
    }
}

// MARK: - Input, Output
extension CreateAccountViewModel {
    struct Input {
        let saveAction: PublishSubject<Void> = .init()
        let title: BehaviorRelay<String> = .init(value: "")
        let currencyType: BehaviorRelay<CurrencyType> = .init(value: .rub)
    }
    
    struct Output {
        let dismiss: PublishSubject<Void> = .init()
        let error: PublishSubject<Error> = .init()
        let isLoading: BehaviorRelay<Bool> = .init(value: false)
    }
}

// MARK: - Error
private enum CustomError: Error, LocalizedError {
    case invalidTitle
    case duplicateNameAccount
    
    var errorDescription: String? {
        switch self {
        case .invalidTitle:
            return .Localized.Error.invalidNameAccount.localized
        case .duplicateNameAccount:
            return .Localized.Error.duplicateAccountName.localized
        }
    }
}
