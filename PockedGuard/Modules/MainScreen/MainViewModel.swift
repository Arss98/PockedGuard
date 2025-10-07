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
    func handlePeriodSelection(index: Int)
}

final class MainViewModel: MainViewModelProtocol {
    // MARK: - Public properties
    let input: Input
    let output: Output
    
    // MARK: - Private properties
    private let dataProvider: DataProviderProtocol
    private let disposeBag: DisposeBag = .init()
    
    // MARK: - init
    init(dataProvider: DataProviderProtocol) {
        self.dataProvider = dataProvider
        self.input = .init()
        self.output = .init()
        setupBindings()
        setupRepositoryBindings()
    }
}

// MARK: - MainViewModelProtocol
extension MainViewModel {
    func handlePeriodSelection(index: Int) {
        switch index {
        case 0: output.period.accept(.day())
        case 1: output.period.accept(.week())
        case 2: output.period.accept(.month())
        case 3: input.showDatePickerTrigger.accept(())
        default:
            break
        }
    }
}

// MARK: - Private methods
private extension MainViewModel {
    func setupBindings() {
        Observable.combineLatest(
            input.transactionType,
            input.selectedAccount,
            output.period
        )
        .subscribe(with: self) { viewModel, tuple in
            viewModel.dataProvider.transaction.setFilters(type: tuple.0, accountId: tuple.1?.id, period: tuple.2)
        }
        .disposed(by: disposeBag)

        input.nextPeriod
            .subscribe(with: self, onNext: { viewModel, _ in
                let currentPeriod = viewModel.output.period.value
                if !currentPeriod.isFuture {
                    viewModel.output.period.accept(currentPeriod.next)
                }
            })
            .disposed(by: disposeBag)
        
        input.previousPeriod
            .subscribe(with: self, onNext: { viewModel, _ in
                let currentPeriod = viewModel.output.period.value
                viewModel.output.period.accept(currentPeriod.previous)
            })
            .disposed(by: disposeBag)
    }
    
    func setupRepositoryBindings() {
        dataProvider.transaction.transactions
            .subscribe(with: self) { viewModel, transactions in
                viewModel.groupTransactions(transactions)
            }
            .disposed(by: disposeBag)
        
        dataProvider.accounts.accounts
            .subscribe(with: self) { viewModel, accounts in
                viewModel.output.accounts.accept(accounts)
            }
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
        let transactionType: BehaviorRelay<TransactionType> = .init(value: .expense)
        let nextPeriod: PublishRelay<Void> = .init()
        let previousPeriod: PublishRelay<Void> = .init()
    }
    
    struct Output {
        let showNotification: PublishSubject<Void> = .init()
        let segmentsDiagram: BehaviorRelay<[SegmentDataModel]> = .init(value: [])
        let sections: BehaviorRelay<[TransactionSection]> = .init(value: [])
        let accounts: BehaviorRelay<[AccountDomainModel]> = .init(value: [])
        let period: BehaviorRelay<PeriodType> = .init(value: .day())
        let error: PublishSubject<Error> = .init()
        let isLoading: BehaviorRelay<Bool> = .init(value: false)
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
