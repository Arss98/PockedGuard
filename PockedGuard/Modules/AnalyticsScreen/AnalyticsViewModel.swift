//
//  AnalyticsViewModel.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 08.03.2025.
//

import RxSwift
import RxCocoa

protocol AnalyticsViewModelProtocol: AnyObject {
    var input: AnalyticsViewModel.Input { get }
    var output: AnalyticsViewModel.Output { get }
}

final class AnalyticsViewModel: AnalyticsViewModelProtocol {
    // MARK: - Public Properties
    let input: Input
    let output: Output
    
    // MARK: - Private Properties
    private let dataProvider: DataProviderProtocol
    private let disposeBag: DisposeBag = .init()
    
    // MARK: - Init
    init(dataProvider: DataProviderProtocol) {
        self.input = .init()
        self.output = .init()
        self.dataProvider = dataProvider
        setupBinding()
    }
}

// MARK: - Private methods
private extension AnalyticsViewModel {
    func setupBinding() {
        input.selectedPeriod
            .flatMapLatest { [weak self] period -> Observable<[FinancialBarChartData]> in
                guard let self = self else { return .just([]) }
                
                return self.getFinancialData(for: period)
                    .asObservable()
                    .catch { error in
                        print("Ошибка загрузки данных: \(error)")
                        return .just([])
                    }
            }
            .bind(to: output.barChartTransaction)
            .disposed(by: disposeBag)
    }
    
    func getFinancialData(for period: PeriodType) -> Single<[FinancialBarChartData]> {
        return dataProvider.transaction.getTransactionsAnalytics(period: period)
            .map { transactions in
                var financialData: [FinancialBarChartData] = []
                let displayDates: [Date] = period.getDisplayDates()
                
                guard let firstDate = displayDates.first, let lastDate = displayDates.last else {
                    return financialData
                }
                
                var transactionsByDateAndType: [Date: [TransactionType: [TransactionDomainModel]]] = [:]
                
                for transaction in transactions {
                    let normalizedDate: Date = Calendar.current.startOfDay(for: transaction.date)
                    if transactionsByDateAndType[normalizedDate] == nil {
                        transactionsByDateAndType[normalizedDate] = [.income: [], .expense: []]
                    }
                    transactionsByDateAndType[normalizedDate]?[transaction.type, default: []].append(transaction)
                }
                
                for date in displayDates {
                    let normalizedDate: Date = Calendar.current.startOfDay(for: date)
                    let dateTransactions = transactionsByDateAndType[normalizedDate]
                    
                    let income: Double = dateTransactions?[.income]?.reduce(0) { $0 + $1.amount } ?? 0
                    let expense: Double = dateTransactions?[.expense]?.reduce(0) { $0 + $1.amount } ?? 0
                    let loss: Double = max(expense - income, 0)
                    
                    if income > 0 || date == firstDate || date == lastDate {
                        financialData.append(FinancialBarChartData(period: date, amount: income, category: .income))
                    }
                    
                    if expense > 0 || date == firstDate || date == lastDate {
                        financialData.append(FinancialBarChartData(period: date, amount: expense, category: .expense))
                    }
                    
                    if loss > 0 || date == firstDate || date == lastDate {
                        financialData.append(FinancialBarChartData(period: date, amount: loss, category: .loss))
                    }
                }
                
                return financialData
            }
    }
}

// MARK: - Input, Output
extension AnalyticsViewModel {
    struct Input {
        let selectedPeriod: BehaviorRelay<PeriodType> = .init(value: .day())
    }
    
    struct Output {
        let barChartTransaction: BehaviorRelay<[FinancialBarChartData]> = .init(value: [])
    }
}
