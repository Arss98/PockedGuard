//
//  CoreDataService.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 28.06.2025.
//

import Foundation
import CoreData
import RxSwift

// MARK: - Protocols
protocol CoreDataNotificationProtocol {
    func fetchNotifications() -> Observable<[NotificationDomainModel]>
    func addNotification(_ notification: NotificationDomainModel) -> Completable
    func deleteNotification(id: UUID) -> Completable
    func updateNotification(id: UUID, newTitle: String?, newNotes: String?, newDate: Date?,
                            newIsActive: Bool?, newReminderType: ReminderType?) -> Single<NotificationDomainModel?>
}

protocol CoreDataTransactionProtocol {
    // MARK: - Templates
    func fetchTemplates(by type: TransactionType?) -> Observable<[TemplatesDomainModel]>
    func addTemplate(_ template: TemplatesDomainModel) -> Completable
    func deleteTemplate(with id: UUID) ->Completable
    func updateTemplate(id: UUID, newIcon: String?, newType: TransactionType?, newAmount: Double?,
                        newCategoryID: UUID?) -> Single<TemplatesDomainModel?>
    
    // MARK: - Categories
    func fetchCategories(by type: TransactionType?) -> Observable<[CategoryDomainModel]>
    func addCategory(_ category: CategoryDomainModel, isSystem: Bool) -> Completable
    func deleteCategories(id: UUID) -> Completable
    func updateCategory(id: UUID, newName: String?, newColor: String?) -> Single<CategoryDomainModel?>
    
    // MARK: - Account
    func fetchAccounts(by type: TransactionType?) -> Observable<[AccountDomainModel]>
    func addAccount(_ account: AccountDomainModel) -> Completable
    func deleteAccount(id: UUID) -> Completable
    func updateAccount(id: UUID, newName: String?, newBalance: Double?) -> Single<AccountDomainModel?>
    
    // MARK: - Transaction
    func fetchTransactions(by type: TransactionType?, periodType: PeriodType?, accountId: UUID?, categotyId: UUID?) -> Observable<[TransactionDomainModel]>
    func addTransaction(_ transaction: TransactionDomainModel) -> Completable
    func deleteTransaction(id: UUID) -> Completable
    
    // MARK: - Default Data methods
    func isFirstLaunch() -> Bool
    func markFirstLaunch()
    func createDefaultData() -> Completable
}

final class CoreDataService {
    private let firstLaunchKey = "isFirstLaunch"
    static let shared = CoreDataService()
    private init() {}
    
    // MARK: CoreData stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container: NSPersistentContainer = NSPersistentContainer(name: "PockedGuard")
        container.loadPersistentStores(completionHandler: { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return container
    }()
    
    func newBackgroundContext() -> NSManagedObjectContext {
        let context: NSManagedObjectContext = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - UserDefaults methods
    func isFirstLaunch() -> Bool {
        UserDefaults.standard.bool(forKey: firstLaunchKey)
    }
    
    func markFirstLaunch() {
        UserDefaults.standard.set(true, forKey: firstLaunchKey)
    }
    
    func createDefaultData() -> Completable {
        createDefaultAccount()
            .andThen(createDefaultTemplate())
            .andThen(createDefaultCategories())
    }
}

// MARK: - Create default entity
extension CoreDataService {
    func createDefaultAccount() -> Completable {
        let context: NSManagedObjectContext = newBackgroundContext()
        
        return Completable.create { completable in
            context.perform {
                do {
                    let incomeAccount: Account = Account(context: context)
                    incomeAccount.id = UUID()
                    incomeAccount.name = .Localized.Common.accountTitle.localized
                    incomeAccount.balance = 0
                    incomeAccount.type = TransactionType.income.rawValue
                    
                    let expenseAccount: Account = Account(context: context)
                    expenseAccount.id = UUID()
                    expenseAccount.name = .Localized.Common.accountTitle.localized
                    expenseAccount.balance = 0
                    expenseAccount.type = TransactionType.expense.rawValue
                    
                    if context.hasChanges {
                        try context.save()
                    }
                    completable(.completed)
                } catch {
                    completable(.error(error))
                }
            }
            
            return Disposables.create {
                context.reset()
            }
        }
    }
    
    func createDefaultTemplate() -> Completable {
        let context: NSManagedObjectContext = newBackgroundContext()
        return Completable.create { completable in
            context.perform {
                do {
                    let defaultIcons = ["icon1", "icon2", "icon3", "icon4", "icon5",
                                        "icon6", "icon7", "icon8", "icon9", "icon10"]
                    
                    for icon in defaultIcons {
                        let template: Templates = Templates(context: context)
                        template.id = UUID()
                        template.icon = icon
                        template.type = TransactionType.income.rawValue
                        template.amount = 0
                        template.category = nil
                    }
                    
                    for icon in defaultIcons {
                        let template: Templates = Templates(context: context)
                        template.id = UUID()
                        template.icon = icon
                        template.type = TransactionType.expense.rawValue
                        template.amount = 0
                        template.category = nil
                    }
                    
                    if context.hasChanges {
                        try context.save()
                    }
                    completable(.completed)
                } catch {
                    completable(.error(error))
                }
            }
            
            return Disposables.create {
                context.reset()
            }
        }
    }
    
    func createDefaultCategories() -> Completable {
        let context: NSManagedObjectContext = newBackgroundContext()
        return Completable.create { completable in
            context.perform {
                do {
                    let incomeCategories: [(nameKey: String, color: String)] = [
                        (.Localized.IncomeCategories.salary.localized, "#4CAF50"),
                        (.Localized.IncomeCategories.investments.localized, "#2196F3"),
                        (.Localized.IncomeCategories.gifts.localized, "#FF9800"),
                        (.Localized.IncomeCategories.otherIncome.localized, "#607D8B")
                    ]
                    
                    for category in incomeCategories {
                        let categoryEntity = Category(context: context)
                        categoryEntity.id = UUID()
                        categoryEntity.name = NSLocalizedString(category.nameKey, comment: "")
                        categoryEntity.color = category.color
                        categoryEntity.type = TransactionType.income.rawValue
                        categoryEntity.isSystem = true
                    }
                    
                    let expenseCategories: [(nameKey: String, color: String)] = [
                        (.Localized.TransactionCategories.health.localized, "#FF5252"),
                        (.Localized.TransactionCategories.products.localized, "#4CAF50"),
                        (.Localized.TransactionCategories.clothes.localized, "#2196F3"),
                        (.Localized.TransactionCategories.leisure.localized, "#FF9800"),
                        (.Localized.TransactionCategories.housing.localized, "#9C27B0"),
                        (.Localized.TransactionCategories.other.localized, "#607D8B")
                    ]
                    
                    for category in expenseCategories {
                        let categoryEntity = Category(context: context)
                        categoryEntity.id = UUID()
                        categoryEntity.name = NSLocalizedString(category.nameKey, comment: "")
                        categoryEntity.color = category.color
                        categoryEntity.type = TransactionType.expense.rawValue
                        categoryEntity.isSystem = true
                    }
                    
                    if context.hasChanges {
                        try context.save()
                    }
                    completable(.completed)
                } catch {
                    completable(.error(error))
                }
            }
            
            return Disposables.create {
                context.reset()
            }
        }
    }
}

// MARK: - CoreDataTransactionProtocol
// MARK: - Templates methods
extension CoreDataService: CoreDataTransactionProtocol {
    func fetchTemplates(by type: TransactionType? = nil) -> Observable<[TemplatesDomainModel]> {
        let context: NSManagedObjectContext = newBackgroundContext()
        let request: NSFetchRequest<Templates> = Templates.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "icon", ascending: true)]
        
        if let type = type {
            request.predicate = NSPredicate(format: "type == %d", type.rawValue)
        }
        
        return Observable.create { observer in
            context.perform {
                do {
                    let results: [Templates] = try context.fetch(request)
                    let domainModels: [TemplatesDomainModel] = results.map { $0.toDomain() }
                    
                    observer.onNext(domainModels)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
            }
            
            return Disposables.create {
                context.reset()
            }
        }
    }
    
    func addTemplate(_ template: TemplatesDomainModel) -> Completable {
        let context: NSManagedObjectContext = newBackgroundContext()
        
        return Completable.create { completable in
            context.perform {
                let templateEntity: Templates = Templates(context: context)
                
                templateEntity.id = template.id
                templateEntity.icon = template.icon
                templateEntity.type = template.type?.rawValue ?? 0
                templateEntity.amount = template.amount ?? 0
                
                if let categoryDomainModel = template.category {
                    let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "id == %@", categoryDomainModel.id as CVarArg)
                    
                    if let existingCategory = try? context.fetch(fetchRequest).first {
                        templateEntity.category = existingCategory
                    } else {
                        templateEntity.category = Category.fromDomain(categoryDomainModel, context: context)
                    }
                } else {
                    templateEntity.category = nil
                }
                
                do {
                    if context.hasChanges {
                        try context.save()
                    }
                    completable(.completed)
                } catch {
                    completable(.error(error))
                }
            }
            
            return Disposables.create {
                context.reset()
            }
        }
    }
    
    func updateTemplate(
        id: UUID,
        newIcon: String?,
        newType: TransactionType?,
        newAmount: Double?,
        newCategoryID: UUID?
    ) -> Single<TemplatesDomainModel?> {
        let context: NSManagedObjectContext = newBackgroundContext()
        let request: NSFetchRequest<Templates> = Templates.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        return Single.create { single in
            do {
                guard let template: Templates = try context.fetch(request).first else {
                    throw NSError(domain: "", code: 0, userInfo: nil)
                }
                
                newIcon.map { template.icon = $0 }
                newType.map { template.type = $0.rawValue }
                newAmount.map { template.amount = $0 }
                
                if let newCategoryID = newCategoryID {
                    let categoryRequest: NSFetchRequest<Category> = Category.fetchRequest()
                    categoryRequest.predicate = NSPredicate(format: "id == %@", newCategoryID as CVarArg)
                    
                    guard let category: Category = try context.fetch(categoryRequest).first else {
                        throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Category not found"])
                    }
                    template.category = category
                } else {
                    template.category = nil
                }
                
                if context.hasChanges {
                    try context.save()
                }
                let updateModel: TemplatesDomainModel = template.toDomain()
                single(.success(updateModel))
            } catch {
                single(.failure(error))
            }
            
            return Disposables.create {
                context.reset()
            }
        }
    }
    
    func deleteTemplate(with id: UUID) ->Completable {
        let context: NSManagedObjectContext = newBackgroundContext()
        let request: NSFetchRequest<Templates> = Templates.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        return Completable.create { completable in
            context.perform {
                do {
                    guard let template: Templates = try context.fetch(request).first else {
                        throw NSError(domain: "", code: 0, userInfo: nil)
                    }
                    
                    context.delete(template)
                    if context.hasChanges {
                        try context.save()
                    }
                    completable(.completed)
                } catch {
                    completable(.error(error))
                }
            }
            
            return Disposables.create {
                context.reset()
            }
        }
    }
}

// MARK: - Categories methods
extension CoreDataService {
    func fetchCategories(by type: TransactionType? = nil) -> Observable<[CategoryDomainModel]> {
        let context: NSManagedObjectContext = newBackgroundContext()
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        if let type = type {
            request.predicate = NSPredicate(format: "type == %d", type.rawValue)
        }
        
        return Observable.create { observer in
            context.perform {
                do {
                    let result: [Category] = try context.fetch(request)
                    let domainModels: [CategoryDomainModel] = result.map { $0.toDomain() }
                    observer.onNext(domainModels)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
            }
            
            return Disposables.create {
                context.reset()
            }
        }
    }
    
    func addCategory(_ category: CategoryDomainModel, isSystem: Bool = false) -> Completable {
        let context: NSManagedObjectContext = newBackgroundContext()
        return Completable.create { completable in
            context.perform {
                let categoryEntity: Category = Category(context: context)
                
                categoryEntity.id = category.id
                categoryEntity.name = category.name
                categoryEntity.color = category.color
                categoryEntity.type = category.type.rawValue
                categoryEntity.isSystem = isSystem
                
                do {
                    if context.hasChanges {
                        try context.save()
                    }
                    completable(.completed)
                } catch {
                    completable(.error(error))
                }
            }
            
            return Disposables.create {
                context.reset()
            }
        }
    }
    
    func updateCategory(
        id: UUID,
        newName: String?,
        newColor: String?
    ) -> Single<CategoryDomainModel?> {
        let context: NSManagedObjectContext = newBackgroundContext()
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        return Single.create { single in
            context.perform {
                do {
                    guard let categoryEntity = try context.fetch(request).first else {
                        throw NSError(domain: "", code: 0, userInfo: nil)
                    }
                    
                    newName.map { categoryEntity.name = $0 }
                    newColor.map { categoryEntity.color = $0 }
                    
                    if context.hasChanges {
                        try context.save()
                    }
                    let updateModel: CategoryDomainModel = categoryEntity.toDomain()
                    single(.success(updateModel))
                } catch {
                    single(.failure(error))
                }
            }
            
            return Disposables.create {
                context.reset()
            }
        }
    }
    
    func deleteCategories(id: UUID) -> Completable {
        let context: NSManagedObjectContext = newBackgroundContext()
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        return Completable.create { completable in
            context.perform {
                do {
                    guard let category = try context.fetch(request).first else {
                        throw NSError(domain: "", code: 0, userInfo: nil)
                    }
                    
                    context.delete(category)
                    if context.hasChanges {
                        try context.save()
                    }
                    completable(.completed)
                } catch {
                    completable(.error(error))
                }
            }
            
            return Disposables.create {
                context.reset()
            }
        }
    }
}

// MARK: - Account methods
extension CoreDataService {
    func fetchAccounts(by type: TransactionType? = nil) -> Observable<[AccountDomainModel]> {
        let context: NSManagedObjectContext = newBackgroundContext()
        let request: NSFetchRequest<Account> = Account.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        if let type = type {
            request.predicate = NSPredicate(format: "type == %d", type.rawValue)
        }
        
        return Observable.create { observer in
            context.perform {
                do {
                    let result: [Account] = try context.fetch(request)
                    let domainModel: [AccountDomainModel] = result.map { $0.toDomain() }
                    
                    observer.onNext(domainModel)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
            }
            
            return Disposables.create {
                context.reset()
            }
        }
    }
    
    func addAccount(_ account: AccountDomainModel) -> Completable {
        let context: NSManagedObjectContext = newBackgroundContext()
        
        return Completable.create { completable in
            context.perform {
                let accountEntity: Account = Account(context: context)
                accountEntity.id = account.id
                accountEntity.name = account.name
                accountEntity.balance = account.balance
                accountEntity.currency = account.currency.rawValue
                accountEntity.type = account.type.rawValue
                
                do {
                    if context.hasChanges {
                        try context.save()
                    }
                    completable(.completed)
                } catch {
                    completable(.error(error))
                }
            }
            
            return Disposables.create {
                context.reset()
            }
        }
    }
    
    func updateAccount(
        id: UUID,
        newName: String?,
        newBalance: Double?
    ) -> Single<AccountDomainModel?> {
        let context: NSManagedObjectContext = newBackgroundContext()
        let request: NSFetchRequest<Account> = Account.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        return Single.create { single in
            context.perform {
                do {
                    guard let account: Account = try context.fetch(request).first else {
                        throw NSError(domain: "", code: 0, userInfo: nil)
                    }
                    
                    newName.map { account.name = $0 }
                    newBalance.map { account.balance = $0 }
                    
                    if context.hasChanges {
                        try context.save()
                    }
                    let updateModel: AccountDomainModel = account.toDomain()
                    single(.success(updateModel))
                } catch {
                    single(.failure(error))
                }
            }
            
            return Disposables.create {
                context.reset()
            }
        }
    }
    
    func deleteAccount(id: UUID) -> Completable {
        let context: NSManagedObjectContext = newBackgroundContext()
        let request: NSFetchRequest<Account> = Account.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        return Completable.create { completable in
            context.perform {
                do {
                    guard let account: Account = try context.fetch(request).first else {
                        throw NSError(domain: "", code: 0, userInfo: nil)
                    }
                    
                    context.delete(account)
                    if context.hasChanges {
                        try context.save()
                    }
                    completable(.completed)
                } catch {
                    completable(.error(error))
                }
            }
            
            return Disposables.create {
                context.reset()
            }
        }
    }
}

// MARK: - Transaction methods
extension CoreDataService {
    func fetchTransactions(
        by type: TransactionType?,
        periodType: PeriodType?,
        accountId: UUID?,
        categotyId: UUID?
    ) -> Observable<[TransactionDomainModel]> {
        let context: NSManagedObjectContext = newBackgroundContext()
        let request: NSFetchRequest<Transaction> = configureTransactionFetchRequest(by: type, periodType: periodType, accountId: accountId)
        
        return Observable.create { observer in
            context.perform {
                do {
                    let result: [Transaction] = try context.fetch(request)
                    let domainModels: [TransactionDomainModel] = result.map { $0.toDomain() }
                    
                    observer.onNext(domainModels)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
            }
            
            return Disposables.create {
                context.reset()
            }
        }
    }
    
    
    func addTransaction(_ transaction: TransactionDomainModel) -> Completable {
        let context: NSManagedObjectContext = newBackgroundContext()
        
        return Completable.create { completable in
            context.perform {
                let transactionEntity: Transaction = Transaction(context: context)
                transactionEntity.id = transaction.id
                transactionEntity.amount = transaction.amount
                transactionEntity.date = transaction.date
                transactionEntity.notes = transaction.notes
                transactionEntity.paymentMethod = transaction.paymentMethod.rawValue
                transactionEntity.type = transaction.type.rawValue
                
                if let accountDomainModel = transaction.account {
                    let fetchRequest: NSFetchRequest<Account> = Account.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "id == %@", accountDomainModel.id as CVarArg)
                    if let existingAccount = try? context.fetch(fetchRequest).first {
                        transactionEntity.account = existingAccount
                    } else {
                        transactionEntity.account = Account.fromDomain(accountDomainModel, context: context)
                    }
                }
                
                if let categoryDomainModel = transaction.category {
                    let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "id == %@", categoryDomainModel.id as CVarArg)
                    if let existingCategory = try? context.fetch(fetchRequest).first {
                        transactionEntity.category = existingCategory
                    } else {
                        transactionEntity.category = Category.fromDomain(categoryDomainModel, context: context)
                    }
                }
                
                do {
                    if context.hasChanges {
                        try context.save()
                    }
                    completable(.completed)
                } catch {
                    completable(.error(error))
                }
            }
            
            return Disposables.create {
                context.reset()
            }
        }
    }
    
    func deleteTransaction(id: UUID) -> Completable {
        let context: NSManagedObjectContext = newBackgroundContext()
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        return Completable.create { completable in
            context.perform {
                do {
                    guard let transaction = try context.fetch(request).first else {
                        throw NSError(domain: "", code: 0, userInfo: nil)
                    }
                    
                    context.delete(transaction)
                    if context.hasChanges {
                        try context.save()
                    }
                    completable(.completed)
                } catch {
                    completable(.error(error))
                }
            }
            
            return Disposables.create {
                context.reset()
            }
        }
    }
    
    private func configureTransactionFetchRequest(
        by type: TransactionType?,
        periodType: PeriodType?,
        accountId: UUID?
    ) -> NSFetchRequest<Transaction> {
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        var predicate: [NSPredicate] = []
        
        if let type = type {
            predicate.append(NSPredicate(format: "type == %d", type.rawValue))
        }
        
        if let datePredicate = createPeriodPredicate(for: periodType) {
            predicate.append(datePredicate)
        }
        
        if let accountId = accountId {
            predicate.append(NSPredicate(format: "account.id == %@", accountId as CVarArg))
        }
        
        if !predicate.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicate)
        }
        
        return request
    }
    
    private func createPeriodPredicate(for period: PeriodType?) -> NSPredicate? {
        guard let period = period else { return nil }
        
        switch period {
        case .day:
            let startOfDay = Calendar.current.startOfDay(for: Date())
            let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
            return NSPredicate(format: "date >= %@ AND date < %@",
                              startOfDay as NSDate, endOfDay as NSDate)
            
        case .week:
            let dates = Date.currentWeekDates()
            return NSPredicate(format: "date >= %@ AND date <= %@",
                              dates.start as NSDate, dates.end as NSDate)
            
        case .month:
            let dates = Date.currentMonthDates()
            return NSPredicate(format: "date >= %@ AND date <= %@",
                              dates.start as NSDate, dates.end as NSDate)
            
        case .custom(let start, let end):
            return NSPredicate(format: "date >= %@ AND date <= %@",
                              start as NSDate, end as NSDate)
        }
    }
}

// MARK: - CoreDataNotificationProtocol
extension CoreDataService: CoreDataNotificationProtocol {
    func fetchNotifications() -> Observable<[NotificationDomainModel]> {
        let context: NSManagedObjectContext = newBackgroundContext()
        let request: NSFetchRequest<NotificationModel> = NotificationModel.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: false)]
        
        return Observable.create { observer in
            context.perform {
                do {
                    let results: [NotificationModel] = try context.fetch(request)
                    let domainModels: [NotificationDomainModel] = results.map { $0.toDomain() }
                    
                    observer.onNext(domainModels)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
            }
            
            return Disposables.create {
                context.reset()
            }
        }
    }
    
    func addNotification(_ notification: NotificationDomainModel) -> Completable {
        let context: NSManagedObjectContext = newBackgroundContext()
        
        return Completable.create { completable in
            context.perform {
                let notificationEntity: NotificationModel = NotificationModel(context: context)
                notificationEntity.id = notification.id
                notificationEntity.title = notification.title
                notificationEntity.date = notification.date
                notificationEntity.isActive = notification.isActive
                notificationEntity.reminderType = notification.reminderType.rawValue
                notificationEntity.notes = notification.notes
                
                do {
                    if context.hasChanges {
                        try context.save()
                    }
                    completable(.completed)
                } catch {
                    completable(.error(error))
                }
            }
            
            return Disposables.create {
                context.reset()
            }
        }
    }
    
    func updateNotification(
        id: UUID,
        newTitle: String?,
        newNotes: String?,
        newDate: Date?,
        newIsActive: Bool?,
        newReminderType: ReminderType?
    ) -> Single<NotificationDomainModel?>  {
        let context: NSManagedObjectContext = newBackgroundContext()
        let request: NSFetchRequest<NotificationModel> = NotificationModel.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        return Single.create { single in
            context.perform {
                do {
                    guard let notification = try context.fetch(request).first else {
                        throw NSError(domain: "", code: 0, userInfo: nil)
                    }
                    
                    newTitle.map { notification.title = $0 }
                    newNotes.map { notification.notes = $0 }
                    newDate.map { notification.date = $0 }
                    newIsActive.map { notification.isActive = $0 }
                    newReminderType.map { notification.reminderType = $0.rawValue }
                    
                    if context.hasChanges {
                        try context.save()
                    }
                    let updateModel: NotificationDomainModel = notification.toDomain()
                    single(.success(updateModel))
                } catch {
                    single(.failure(error))
                }
            }
            
            return Disposables.create {
                context.reset()
            }
        }
    }
    
    func deleteNotification(id: UUID) -> Completable {
        let context: NSManagedObjectContext = newBackgroundContext()
        let request: NSFetchRequest<NotificationModel> = NotificationModel.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        return Completable.create { completable in
            context.perform {
                do {
                    guard let notification = try context.fetch(request).first else {
                        throw NSError(domain: "", code: 0, userInfo: nil)
                    }
                    
                    context.delete(notification)
                    if context.hasChanges {
                        try context.save()
                    }
                    completable(.completed)
                } catch {
                    completable(.error(error))
                }
            }
            
            return Disposables.create {
                context.reset()
            }
        }
    }
}
