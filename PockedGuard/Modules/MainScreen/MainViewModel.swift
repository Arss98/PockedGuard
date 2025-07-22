//
//  MainViewModel.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 08.03.2025.
//

import RxSwift
import RxCocoa

protocol MainViewModelProtocol: AnyObject {
    var input: MainViewModel.Input { get }
    var output: MainViewModel.Output { get }
    func fetchData()
    func handlePeriodSelection(index: Int)
}

final class MainViewModel: MainViewModelProtocol {
    // MARK: - Public properties
    let input: Input
    let output: Output
    
    // MARK: - Private properties
    private let coreDataService: CoreDataTransactionProtocol
    private let disposeBag: DisposeBag = .init()
    
    // MARK: - init
    init(coreDataService: CoreDataTransactionProtocol = CoreDataService.shared) {
        self.coreDataService = coreDataService
        self.input = .init()
        self.output = .init()
        setupDefaultTemplatesIfNeeded()
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
        case 0: output.period.accept(.day)
        case 1: output.period.accept(.week)
        case 2: output.period.accept(.month)
        case 3: input.showDatePickerTrigger.accept(())
        default:
            break
        }
    }
}

// MARK: - Private methods
private extension MainViewModel {
    func setupDefaultTemplatesIfNeeded() {
        if !coreDataService.isFirstLaunch() {
            coreDataService.createDefaultData()
                .subscribe(onCompleted: { [weak self] in
                    self?.coreDataService.markFirstLaunch()
                }, onError: { [weak self] _ in
                    self?.output.error.onNext(CustomError.failedToCreateDefaultData)
                })
                .disposed(by: disposeBag)
        }
    }

    func setupBindings() {
        input.currentTransactionType
            .subscribe(with: self, onNext: { viewModel, _ in
                viewModel.fetchData()
            })
            .disposed(by: disposeBag)
        
        input.selectedAccount
            .subscribe(with: self, onNext: { viewModel, account in
                viewModel.fetchTransactions()
            })
            .disposed(by: disposeBag)
        
        output.period
            .subscribe(with: self, onNext: { viewModel, _ in
                viewModel.fetchTransactions()
            })
            .disposed(by: disposeBag)
    }
    
    func fetchTransactions() {
        output.isLoading.accept(true)
        
        coreDataService.fetchTransactions(
            by: input.currentTransactionType.value,
            periodType: output.period.value,
            accountId: input.selectedAccount.value?.id,
            categotyId: nil
        )
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
        .observe(on: MainScheduler.asyncInstance)
        .subscribe(with: self, onNext: { viewModel, transactions in
            viewModel.groupTransactions(transactions)
            viewModel.output.isLoading.accept(false)
        }, onError: { viewModel, _ in
            viewModel.output.isLoading.accept(false)
            viewModel.output.error.onNext(CustomError.failedToFetchTransactions)
        })
        .disposed(by: disposeBag)
    }
    
    func fetchAccounts() {
        output.isLoading.accept(true)
        
        coreDataService.fetchAccounts(by: input.currentTransactionType.value)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self, onNext: { viewModel, accounts in
                viewModel.output.accounts.accept(accounts)
                
                if let defaultAccount = accounts.first(
                    where: {$0.name == .Localized.Common.accountTitle.localized}) {
                    viewModel.input.selectedAccount.accept(defaultAccount)
                }
                
                viewModel.output.isLoading.accept(false)
            }, onError: { viewModel, _ in
                viewModel.output.error.onNext(CustomError.failedToFetchAccounts)
                viewModel.output.isLoading.accept(false)
            })
            .disposed(by: disposeBag)
    }

    func groupTransactions(_ transactions: [TransactionDomainModel]) {
        let totalAmount: Double = transactions.reduce(0) { $0 + $1.amount }
        let groupTransactions: [String: [TransactionDomainModel]] = Dictionary(grouping: transactions, by: { $0.category?.name ?? .Localized.TransactionCategories.other.localized })
        
        let sections: [TransactionSection] = groupTransactions.map { key, value in
            let categoryAmount: Double = value.reduce(0) { $0 + $1.amount }
            let percentage: Double = (categoryAmount / totalAmount) * 100
            
            return TransactionSection(categoryName: key,percentage: String(format: "%.0f% %", percentage),
                                      transactions: value)
        }
        .sorted { $0.categoryName < $1.categoryName}
        
        let segments: [SegmentDataModel] = groupTransactions.map { key, value in
            let total: Double = value.reduce(.zero) { $0 + $1.amount }
            let color: String? = value.first?.category?.color
            
            return SegmentDataModel(value: CGFloat(total), color: color, categoryName: key)
        }
        .sorted { $0.value > $1.value }
        
        output.sections.accept(sections)
        output.segmentsDiagram.accept(segments)
    }
}

// MARK: - Input, Output
extension MainViewModel {
    struct Input {
        let selectedAccount: BehaviorRelay<AccountDomainModel?> = .init(value: nil)
        let showDatePickerTrigger: PublishRelay<Void> = .init()
        let currentTransactionType: BehaviorRelay<TransactionType?> = .init(value: nil)
    }
    
    struct Output {
        let showNotification: PublishSubject<Void> = .init()
        let segmentsDiagram: BehaviorRelay<[SegmentDataModel]> = .init(value: [])
        let sections: BehaviorRelay<[TransactionSection]> = .init(value: [])
        let accounts: BehaviorRelay<[AccountDomainModel]> = .init(value: [])
        let period: BehaviorRelay<PeriodType> = .init(value: .day)
        let error: PublishSubject<Error> = .init()
        let isLoading: BehaviorRelay<Bool> = .init(value: false)
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

// MARK: - Error
private enum CustomError: Error, LocalizedError  {
    case failedToCreateDefaultData
    case failedToFetchTransactions
    case failedToFetchAccounts
    
    var errorDescription: String? {
        switch self {
        case .failedToCreateDefaultData:
            return .Localized.Error.failedToCreateDefaultData.localized
        case .failedToFetchTransactions:
            return .Localized.Error.transactionFetchFailed.localized
        case .failedToFetchAccounts:
            return .Localized.Error.accountFetchFailed.localized
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
