//
//  DataProvider.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 15.09.2025.
//

import RxSwift
import RxCocoa

protocol DataProviderProtocol {
    var transaction: TransactionRepositoryProtocol { get }
    var template: TemplateRepositoryProtocol { get }
    var categories: CategoryRepositoryProtocol { get }
    var accounts: AccountRepositoryProtocol { get }
    var notifications: NotificationRepositoryProtocol { get }
}

final class DataProvider: DataProviderProtocol {
    // MARK: - Public properties
    let transaction: TransactionRepositoryProtocol
    let template: TemplateRepositoryProtocol
    let categories: CategoryRepositoryProtocol
    let accounts: AccountRepositoryProtocol
    let notifications: NotificationRepositoryProtocol
    
    // MARK: - Private properties
    private let coreDataService: CoreDataServiceProtocol
    private let disposeBag: DisposeBag = .init()
    
    init(coreDataService: CoreDataServiceProtocol) {
        self.transaction = TransactionRepository(coreDataService: coreDataService)
        self.template = TemplateRepository(coreDataService: coreDataService)
        self.categories = CategoryRepository(coreDataService: coreDataService)
        self.accounts = AccountRepository(coreDataService: coreDataService)
        self.notifications = NotificationRepository(coreDataService: coreDataService)
        self.coreDataService = coreDataService
        createDefaultDataIfNeeded()
    }
}

// MARK: - initialize default data
private extension DataProvider {
    func createDefaultDataIfNeeded() {
        let hasDefaultData = UserDefaults.standard.bool(forKey: "hasDefaultData")
        if !hasDefaultData {
            coreDataService.initializeDefaultData()
                .observe(on: MainScheduler.instance)
                .subscribe(onCompleted: { [weak self] in
                    UserDefaults.standard.set(true, forKey: "hasDefaultData")
                    self?.accounts.dataInitialized.accept(())
                    self?.categories.dataInitialized.accept(())
                }, onError: { error in
                    print("Ошибка при создании данных по умолчанию: \(error)")
                })
                .disposed(by: disposeBag)
        }
    }
}
