//
//  TransactionRepository.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 15.09.2025.
//

import RxSwift
import RxCocoa
import CoreData

protocol TransactionRepositoryProtocol {
    var transactions: BehaviorRelay<[TransactionDomainModel]> { get }
    func setFilters(type: TransactionType?, accountId: UUID?, period: PeriodType?)
    func createTransaction(_ transaction: TransactionDomainModel) -> Completable
    func deleteTransaction(with id: UUID) -> Completable
}

final class TransactionRepository: TransactionRepositoryProtocol {
    // MARK: - Public properties
    let transactions: BehaviorRelay<[TransactionDomainModel]> = .init(value: [])
    
    // MARK: - Private properties
    private let coreDataService: CoreDataServiceProtocol
    private let disposeBag: DisposeBag = .init()
    private let backgroundScheduler = ConcurrentDispatchQueueScheduler(qos: .userInitiated)
    private let currentTransactionType: BehaviorRelay<TransactionType> = .init(value: .expense)
    private let currentPeriod: BehaviorRelay<PeriodType> = .init(value: .day(start: Date()))
    private let currentAccountID: BehaviorRelay<UUID?> = .init(value: nil)

    init(coreDataService: CoreDataServiceProtocol) {
        self.coreDataService = coreDataService
        setupBindings()
        fetchTransactions()
    }
}

// MARK: - TransactionRepositoryProtocol methods
extension TransactionRepository {
    func setFilters(type: TransactionType? = nil, accountId: UUID? = nil, period: PeriodType? = nil) {
        if let type = type { currentTransactionType.accept(type) }
        if let period = period { currentPeriod.accept(period) }
        if let accountId = accountId { currentAccountID.accept(accountId) }
    }
    
    func createTransaction(_ transaction: TransactionDomainModel) -> Completable {
        Completable.create { [weak self] completable in
            guard let self else {
                completable(.error(RepositoryError.deinitialized))
                return Disposables.create()
            }
            
            return self.coreDataService.performBackgroundTask { context in
                let transactionEntity = Transaction(context: context)
                transactionEntity.id = transaction.id
                transactionEntity.date = transaction.date
                transactionEntity.amount = transaction.amount
                transactionEntity.notes = transaction.notes
                transactionEntity.paymentMethod = transaction.paymentMethod.rawValue
                transactionEntity.type = transaction.type.rawValue
                
                if let accountId = transaction.account?.id {
                    let account = try self.coreDataService.fetchEntityByID(Account.self, id: accountId, in: context)
                    transactionEntity.account = account
                }
                
                if let categoryId = transaction.category?.id {
                    let category = try self.coreDataService.fetchEntityByID(Category.self, id: categoryId, in: context)
                    transactionEntity.category = category
                }
                
                return transactionEntity
            }
            .asCompletable()
            .subscribe(on: backgroundScheduler)
            .observe(on: MainScheduler.instance)
            .subscribe(onCompleted: {
                self.fetchTransactions()
                completable(.completed)
            }, onError: { error in
                completable(.error(error))
            })
        }
    }

    func deleteTransaction(with id: UUID) -> Completable {
        Completable.create { [weak self] completable in
            guard let self else {
                completable(.error(RepositoryError.deinitialized))
                return Disposables.create()
            }
            
            return self.coreDataService.delete(Transaction.self, predicate: NSPredicate(format: "id == %@", id as CVarArg))
                .subscribe(on: backgroundScheduler)
                .observe(on: MainScheduler.instance)
                .subscribe(onCompleted: {
                    self.fetchTransactions()
                    completable(.completed)
                }, onError: { error in
                    completable(.error(error))
                })
        }
    }
}

// MARK: - Private methods
private extension TransactionRepository {
    func setupBindings() {
        Observable.combineLatest(
            currentTransactionType.distinctUntilChanged(),
            currentPeriod.distinctUntilChanged(),
            currentAccountID.distinctUntilChanged()
        )
        .subscribe(with: self) { repository, _ in
            repository.fetchTransactions()
        }
        .disposed(by: disposeBag)
    }
    
    func fetchTransactions() {
        let predicate: NSPredicate? = configurePredicate(
            type: currentTransactionType.value,
            periodType: currentPeriod.value,
            accountId: currentAccountID.value
        )
        
        let sortDescriptors: [NSSortDescriptor] = [NSSortDescriptor(key: "date", ascending: false)]
        
        coreDataService.fetch(Transaction.self, predicate: predicate, sortDescriptors: sortDescriptors)
            .subscribe(on: backgroundScheduler)
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] transactions in
                self?.transactions.accept(transactions)
            } onFailure: { error in
                print("Error fetching transactions: \(error)")
            }
            .disposed(by: disposeBag)
    }
    
    func configurePredicate(type: TransactionType? = nil, periodType: PeriodType? = nil, accountId: UUID? = nil) -> NSPredicate? {
        var predicates: [NSPredicate] = []
        
        if let type = type {
            predicates.append(NSPredicate(format: "type == %d", type.rawValue))
        }
        
        if let periodType = periodType {
            let datePredicate = createDatePredicate(for: periodType)
            predicates.append(datePredicate)
        }
        
        if let accountId = accountId {
            predicates.append(NSPredicate(format: "account.id == %@", accountId as CVarArg))
        }
        
        return predicates.isEmpty ? nil : NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
    
    func createDatePredicate(for period: PeriodType) -> NSPredicate {
        let calendar: Calendar = Calendar.current
        
        switch period {
        case .day(let start):
            let startDate: Date = calendar.startOfDay(for: start)
            let endOfDay: Date = calendar.date(byAdding: .day, value: 1, to: startDate)!
            return NSPredicate(format: "date >= %@ AND date < %@",
                               startDate as NSDate, endOfDay as NSDate)
        case .week(let start):
            let dates: (start: Date, end: Date) = Date.weekDates(for: start)
            return NSPredicate(format: "date >= %@ AND date <= %@",
                               dates.start as NSDate, dates.end as NSDate)
            
        case .month(let start):
            let dates: (start: Date, end: Date) = Date.monthDates(for: start)
            return NSPredicate(format: "date >= %@ AND date <= %@",
                               dates.start as NSDate, dates.end as NSDate)
            
        case .custom(let start, let end):
            return NSPredicate(format: "date >= %@ AND date <= %@",
                               start as NSDate, end as NSDate)
        }
    }
}

// MARK: - Error Handling
enum RepositoryError: Error {
    case deinitialized
    case notFound
    case invalidData
}
