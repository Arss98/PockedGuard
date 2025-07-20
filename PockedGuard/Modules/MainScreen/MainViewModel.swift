//
//  MainViewModel.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 08.03.2025.
//

import RxSwift
import RxCocoa

protocol MainViewModelProtocol: AnyObject {
    var segmentsDiagram: BehaviorRelay<[SegmentDataModel]> { get }
    var sections: BehaviorRelay<[TransactionSection]> { get }
    var accounts: BehaviorRelay<[AccountDomainModel]> { get }
    var showDatePickerTrigger: PublishRelay<Void> { get }
    var periodText: BehaviorSubject<String> { get }
    var selectedAccount: BehaviorRelay<AccountDomainModel?> { get }
    var currentTransactionType: BehaviorRelay<TransactionType?> { get }
    func fetchData()
    func handlePeriodSelection(index: Int)
    func updateCustomPeriod(start: Date, end: Date)
}

final class MainViewModel: MainViewModelProtocol {
    // MARK: - Public properties
    let segmentsDiagram: BehaviorRelay<[SegmentDataModel]> = .init(value: [])
    let sections: BehaviorRelay<[TransactionSection]> = .init(value: [])
    let accounts: BehaviorRelay<[AccountDomainModel]> = .init(value: [])
    let selectedAccount: BehaviorRelay<AccountDomainModel?> = .init(value: nil)
    let periodText: BehaviorSubject<String> = .init(value: PeriodType.day.description)
    let showDatePickerTrigger: PublishRelay<Void> = .init()
    let currentTransactionType: BehaviorRelay<TransactionType?> = .init(value: nil)
    
    // MARK: - Private properties
    private let coreDataService: CoreDataTransactionProtocol
    private let disposeBag: DisposeBag = .init()
    private var currentPeriod: PeriodType = .day {
        didSet {
            updateDisplayedPeriod()
            fetchTransactions()
        }
    }
    
    // MARK: - init
    init(coreDataService: CoreDataTransactionProtocol = CoreDataService.shared) {
        self.coreDataService = coreDataService
        setupDefaultTemplatesIfNeeded()
        updateDisplayedPeriod()
        setupBindings()
    }
}

// MARK: - MainViewModelProtocol
extension MainViewModel {
    func fetchData() {
        fetchAccounts()
        fetchTransactions()
    }
    
    func handlePeriodSelection(index: Int) {
        switch index {
        case 0: currentPeriod = .day
        case 1: currentPeriod = .week
        case 2: currentPeriod = .month
        case 3: showDatePickerTrigger.accept(())
        default:
            break
        }
    }
    
    func updateCustomPeriod(start: Date, end: Date) {
        currentPeriod = .custom(start: start, end: end)
    }
}

// MARK: - Private methods
private extension MainViewModel {
    func setupDefaultTemplatesIfNeeded() {
        let coreDataService = CoreDataService.shared
        if !coreDataService.isFirstLaunch() {
            coreDataService.createDefaultCategories()
                .andThen(coreDataService.createDefaultAccount())
                .andThen(coreDataService.createDefaultTemplate())
                .subscribe(onCompleted: {
                    coreDataService.markFirstLaunch()
                })
                .disposed(by: disposeBag)
        }
    }

    func setupBindings() {
        currentTransactionType
            .subscribe(with: self, onNext: { viewModel, _ in
                viewModel.fetchData()
            })
            .disposed(by: disposeBag)
        
        selectedAccount
            .subscribe(with: self, onNext: { viewModel, account in
                viewModel.fetchTransactions()
            })
            .disposed(by: disposeBag)
    }
    
    func fetchTransactions() {
        coreDataService.fetchTransactions(
            by: currentTransactionType.value,
            periodType: currentPeriod,
            accountId: selectedAccount.value?.id,
            categotyId: nil
        )
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
        .observe(on: MainScheduler.asyncInstance)
        .subscribe(with: self, onNext: { viewModel, transactions in
            viewModel.groupTransactionsBySegments(transactions)
            viewModel.groupTransactionsByCategory(transactions)
        })
        .disposed(by: disposeBag)
    }
    
    func fetchAccounts() {
        coreDataService.fetchAccounts(by: currentTransactionType.value)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self, onNext: { viewModel, accounts in
                viewModel.accounts.accept(accounts)
                
                if let defaultAccount = accounts.first(
                    where: {$0.name == .Localized.Common.accountTitle.localized}) {
                    viewModel.selectedAccount.accept(defaultAccount)
                }
            })
            .disposed(by: disposeBag)
    }

    func updateDisplayedPeriod() {
        periodText.onNext(currentPeriod.description)
    }
    
    func groupTransactionsByCategory(_ transactions: [TransactionDomainModel]) {
        let totalAmount: Double = transactions.reduce(0) { $0 + $1.amount }
        let groupTransactions: [String: [TransactionDomainModel]] = Dictionary(grouping: transactions, by: { $0.category?.name ?? .Localized.TransactionCategories.other.localized })
        let arrayGroupTransactions: [TransactionSection] =
        groupTransactions.map { key, value in
            let categoryAmount: Double = value.reduce(0) { $0 + $1.amount }
            let percentage: Double = (categoryAmount / totalAmount) * 100
            
            return TransactionSection(
                categoryName: key,
                percentage: String(format: "%.0f% %", percentage),
                transactions: value
            )
        }
        .sorted { $0.categoryName < $1.categoryName}
        
        sections.accept(arrayGroupTransactions)
    }
    
    func groupTransactionsBySegments(_ transactions: [TransactionDomainModel]) {
        let groupTransactrions: [String : [TransactionDomainModel]] = Dictionary(grouping: transactions, by: { $0.category?.name ?? "" })
        let segments: [SegmentDataModel] = groupTransactrions.map { key, value in
            let total: Double = value.reduce(.zero) { $0 + $1.amount }
            let color: String? = value.first?.category?.color
            
            return SegmentDataModel(value: CGFloat(total), color: color, categoryName: key)
        }
        .sorted { $0.value > $1.value }
        
        segmentsDiagram.accept(segments)
    }
}

// MARK: - PeriodType
enum PeriodType {
    case day, week, month
    case custom(start: Date, end: Date)
    
    var description: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        
        switch self {
        case .day:
            return .Localized.Common.today.localized
        case .week:
            formatter.dateFormat = "dd.MM.yyyy"
            let start = Date.currentWeekDates().start
            let end = Date.currentWeekDates().end
            return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
        case .month:
            formatter.dateFormat = "MMMM"
            formatter.monthSymbols = Constants.monthSymbols
            return formatter.string(from: Date())
        case .custom(let start, let end):
            formatter.dateFormat = "dd.MM.yyyy"
            return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
        }
    }
}

// MARK: - Constants
private enum Constants {
    static let monthSymbols: [String] = [
        .Localized.Month.january.localized,
        .Localized.Month.february.localized,
        .Localized.Month.march.localized,
        .Localized.Month.april.localized,
        .Localized.Month.may.localized,
        .Localized.Month.june.localized,
        .Localized.Month.july.localized,
        .Localized.Month.august.localized,
        .Localized.Month.september.localized,
        .Localized.Month.october.localized,
        .Localized.Month.november.localized,
        .Localized.Month.december.localized
    ]
}
