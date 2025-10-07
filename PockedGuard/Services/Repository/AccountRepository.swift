//
//  AccountRepository.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 15.09.2025.
//

import RxSwift
import RxCocoa

protocol AccountRepositoryProtocol {
    var accounts: BehaviorRelay<[AccountDomainModel]> { get }
    var dataInitialized: PublishRelay<Void> { get }
    func addAccount(_ account: AccountDomainModel) -> Completable
    func updateAccount(id: UUID, newName: String?, newBalance: Double?, newCurrencyType: CurrencyType?) -> Single<AccountDomainModel?>
    func deleteAccount(with id: UUID) -> Completable
    func getAccount(by id: UUID) -> Single<AccountDomainModel?>
    func getAccounts() -> [AccountDomainModel]
}

final class AccountRepository: AccountRepositoryProtocol {
    // MARK: - Public properties
    let accounts: BehaviorRelay<[AccountDomainModel]> = .init(value: [])
    let dataInitialized: PublishRelay<Void> = .init()
    
    // MARK: - Private properties
    private let coreDataService: CoreDataServiceProtocol
    private let disposeBag: DisposeBag = .init()
    private let sortDescriptors: [NSSortDescriptor] = [NSSortDescriptor(key: "date", ascending: false)]
    private let backgroundScheduler: ConcurrentDispatchQueueScheduler = .init(qos: .userInitiated)
    
    init(coreDataService: CoreDataServiceProtocol) {
        self.coreDataService = coreDataService
        setupBinding()
        fetchAccounts()
    }
}

// MARK: - AccountRepositoryProtocol
extension AccountRepository {
    func addAccount(_ account: AccountDomainModel) -> Completable {
        Completable.create { [weak self] completable in
            guard let self else {
                completable(.error(RepositoryError.deinitialized))
                return Disposables.create()
            }
            
            return self.coreDataService.create { context in
                let accountEntity: Account = Account(context: context)
                accountEntity.id = account.id
                accountEntity.name = account.name
                accountEntity.balance = account.balance
                accountEntity.currency = account.currency.rawValue
                return accountEntity
            }
            .subscribe(on: backgroundScheduler)
            .observe(on: MainScheduler.instance)
            .subscribe(onCompleted: {
                self.fetchAccounts()
                completable(.completed)
            }, onError: { error in
                completable(.error(error))
            })
        }
    }
    
    func updateAccount(id: UUID, newName: String?, newBalance: Double?, newCurrencyType: CurrencyType?) -> Single<AccountDomainModel?> {
        Single.create { [weak self] single in
            guard let self else {
                single(.failure(RepositoryError.deinitialized))
                return Disposables.create()
            }
            
            return self.coreDataService.update(Account.self, uuid: id) { accountEntity in
                newName.map { accountEntity.name = $0 }
                newBalance.map { accountEntity.balance = $0 }
                newCurrencyType.map { accountEntity.currency = $0.rawValue }
            }
            .subscribe(on: backgroundScheduler)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { account in
                self.fetchAccounts()
                single(.success(account))
            }, onFailure: { error in
                single(.failure(error))
            })
        }
    }
    
    func deleteAccount(with id: UUID) -> Completable {
        Completable.create { [weak self] completable in
            guard let self else {
                completable(.error(RepositoryError.deinitialized))
                return Disposables.create()
            }
            
            return self.coreDataService.delete(Account.self, predicate: NSPredicate(format: "id == %@", id as CVarArg))
                .subscribe(on: backgroundScheduler)
                .observe(on: MainScheduler.instance)
                .subscribe(onCompleted: {
                    self.fetchAccounts()
                    completable(.completed)
                }, onError: { error in
                    completable(.error(error))
                })
        }
    }
    
    func getAccount(by id: UUID) -> Single<AccountDomainModel?> {
        return Single.create { [weak self] single in
            guard let self = self else {
                single(.success(nil))
                return Disposables.create()
            }
            
            if let account = self.accounts.value.first(where: { $0.id == id }) {
                single(.success(account))
                return Disposables.create()
            }
            
            let predicate = NSPredicate(format: "id == %@", id as CVarArg)
            return self.coreDataService.fetch(Account.self, predicate: predicate, sortDescriptors: [])
                .subscribe(on: self.backgroundScheduler)
                .observe(on: MainScheduler.instance)
                .subscribe { accounts in
                    let account = accounts.first
                    single(.success(account))
                } onFailure: { error in
                    single(.failure(error))
                }
        }
    }
    
    func getAccounts() -> [AccountDomainModel] {
        accounts.value
    }
}

// MARK: - Private methods
private extension AccountRepository {
    func setupBinding() {
        dataInitialized
            .subscribe(onNext: { [weak self] in
                self?.fetchAccounts()
            })
            .disposed(by: disposeBag)
    }
    
    func fetchAccounts() {
        coreDataService.fetch(Account.self, predicate: nil, sortDescriptors: sortDescriptors)
            .subscribe(on: backgroundScheduler)
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] accounts in
                self?.accounts.accept(accounts)
            } onFailure: { error in
                print("Error fetching accounts: \(error)")
            }
            .disposed(by: disposeBag)
    }
}
