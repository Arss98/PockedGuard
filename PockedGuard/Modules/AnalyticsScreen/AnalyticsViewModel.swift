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
    private var lineChartDataCache: [TransactionType: [FinancialLineChartData]] = [:]
    private let backgroundScheduler = ConcurrentDispatchQueueScheduler(qos: .userInitiated)
    
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
            .bind(to: dataProvider.transaction.periodByAnalytics)
            .disposed(by: disposeBag)
        
        input.transactionType
            .distinctUntilChanged()
            .subscribe(with: self) { viewModel, transactionType in
                viewModel.updateLineChartData(for: transactionType)
            }
            .disposed(by: disposeBag)
        
        dataProvider.transaction.transactionByAnalytics
            .observe(on: backgroundScheduler)
            .map { [weak self] transactions -> (barData: [FinancialBarChartData], summary: [AnalyticsSummary]) in
                guard let self else { return ([], []) }
                let transactionByDateAndType = groupTransactionsByDateAndType(transactions, period: input.selectedPeriod.value)
                
                let barData: [FinancialBarChartData] = self.prepareByBarChart(transactionByDateAndType)
                let summary: [AnalyticsSummary] = self.calculateSummaryData(transactionByDateAndType)
                self.prepareByLineChart(transactionByDateAndType)
                
                return (barData, summary)
            }
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { viewModel, processedData in
                viewModel.output.barChartTransaction.accept(processedData.barData)
                viewModel.updateLineChartData(for: viewModel.input.transactionType.value)
                viewModel.output.summaryData.accept(processedData.summary)
            }
            .disposed(by: disposeBag)
    }
    
    func prepareByBarChart(_ transactions: [Date : [TransactionType : [TransactionDomainModel]]]) -> [FinancialBarChartData] {
        var financialData: [FinancialBarChartData] = []
        let period: PeriodType = input.selectedPeriod.value
        let displayDates = period.getDisplayDates()
        
        guard let firstDate = displayDates.first, let lastDate = displayDates.last else {
            return financialData
        }
                
        for periodDate in displayDates {
            let dateTransactions = transactions[periodDate]
            
            let income: Double = dateTransactions?[.income]?.reduce(0) { $0 + $1.amount } ?? 0
            let expense: Double = dateTransactions?[.expense]?.reduce(0) { $0 + $1.amount } ?? 0
            let loss: Double = max(expense - income, 0)
            
            if income > 0 || periodDate == firstDate || periodDate == lastDate {
                financialData.append(FinancialBarChartData(period: periodDate, amount: income, category: .income))
            }
            
            if expense > 0 || periodDate == firstDate || periodDate == lastDate {
                financialData.append(FinancialBarChartData(period: periodDate, amount: expense, category: .expense))
            }
            
            if loss > 0 || periodDate == firstDate || periodDate == lastDate {
                financialData.append(FinancialBarChartData(period: periodDate, amount: loss, category: .loss))
            }
        }
        
        return financialData
    }
    
    func prepareByLineChart(_ transactions: [Date : [TransactionType : [TransactionDomainModel]]]) {
        let period = input.selectedPeriod.value
        let displayDates = period.getDisplayDates()
        
        var incomeData: [FinancialLineChartData] = []
        var expenseData: [FinancialLineChartData] = []
                
        for periodDate in displayDates {
            let dateTransactions = transactions[periodDate]
            
            let incomeAmount: Double = dateTransactions?[.income]?.reduce(0) { $0 + $1.amount } ?? 0
            let expenseAmount: Double = dateTransactions?[.expense]?.reduce(0) { $0 + $1.amount } ?? 0
            
            incomeData.append(FinancialLineChartData(date: periodDate, amount: incomeAmount))
            expenseData.append(FinancialLineChartData(date: periodDate, amount: expenseAmount))
        }
        
        incomeData.sort { $0.date < $1.date }
        expenseData.sort { $0.date < $1.date }
        
        var cache = lineChartDataCache
        cache[.income] = incomeData
        cache[.expense] = expenseData
        lineChartDataCache = cache
    }
    
    func calculateSummaryData(_ transactions: [Date : [TransactionType : [TransactionDomainModel]]]) -> [AnalyticsSummary] {
        let allDates: [Date] = input.selectedPeriod.value.getDisplayDates()
        let datesWithTransactions: [Date] = getDatesWithTransactions(from: allDates, transactions: transactions)
        
        guard shouldCalculatePercentages(for: datesWithTransactions, transactions: transactions) else {
            output.isShowEmptyView.accept(false)
            return createEmptySummaries()
        }
        
        output.isShowEmptyView.accept(true)
        
        let totalsByDate = calculateTotalsByDate(for: transactions, on: datesWithTransactions)
        let currentDate: Date = datesWithTransactions.last!
        let baseDates: [Date] = Array(datesWithTransactions.dropLast())
        
        var summaries: [AnalyticsSummary] = []
        
        for category in FinancialCategory.allCases {
            let currentAmount = totalsByDate[currentDate]?[category] ?? 0.0
            let baseAmounts = baseDates.compactMap { totalsByDate[$0]?[category] }
            
            let percentageChange: Int = calculatePercentageChange(
                currentAmount: currentAmount,
                baseAmounts: baseAmounts,
                category: category
            )
            
            let rating: PerformanceRating = getPerformanceRating(for: percentageChange, category: category)
            let summary: AnalyticsSummary = .init(type: category, percentageChange: percentageChange, rating: rating)
            summaries.append(summary)
        }
        
        return summaries
    }
}

// MARK: - Helpers methods
private extension AnalyticsViewModel {
    func updateLineChartData(for type: TransactionType) {
        guard let cachedData = lineChartDataCache[type] else { return }
        output.lineChartTransaction.accept(cachedData)
    }
    
    func createEmptySummaries() -> [AnalyticsSummary] {
        FinancialCategory.allCases.map { category in
            AnalyticsSummary(type: category, percentageChange: 0, rating: .neutral)
        }
    }
    
    func normalizeDate(_ date: Date, for period: PeriodType) -> Date {
        let calendar: Calendar = Calendar.current
        
        switch period {
        case .day, .custom:
            return calendar.startOfDay(for: date)
        case .week:
            return calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
        case .month:
            return calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        case .year:
            return calendar.date(from: calendar.dateComponents([.year], from: date))!
        }
    }

    func groupTransactionsByDateAndType(
        _ transactions: [TransactionDomainModel],
        period: PeriodType
    ) -> [Date: [TransactionType: [TransactionDomainModel]]] {
        
        var transactionsByDateAndType: [Date: [TransactionType: [TransactionDomainModel]]] = [:]
        
        for transaction in transactions {
            let normalizedDate: Date = normalizeDate(transaction.date, for: period)
            
            if transactionsByDateAndType[normalizedDate] == nil {
                transactionsByDateAndType[normalizedDate] = [.income: [], .expense: []]
            }
            transactionsByDateAndType[normalizedDate]?[transaction.type, default: []].append(transaction)
        }
        
        return transactionsByDateAndType
    }
    
    func getDatesWithTransactions(from allDates: [Date], transactions: [Date : [TransactionType : [TransactionDomainModel]]]) -> [Date] {
        return allDates.filter { date in
            guard let dateTransactions = transactions[date] else { return false }
            
            let hasIncome: Bool = (dateTransactions[.income]?.count ?? 0) > 0
            let hasExpense: Bool = (dateTransactions[.expense]?.count ?? 0) > 0
            
            return hasIncome || hasExpense
        }
    }
    
    func shouldCalculatePercentages(for datesWithTransactions: [Date],
                                    transactions: [Date: [TransactionType: [TransactionDomainModel]]]) -> Bool {
        let allDates: [Date] = input.selectedPeriod.value.getDisplayDates()
        
        guard datesWithTransactions.count >= 3 else {
            return false
        }
        
        let totalTransactions: Int  = transactions.values
            .flatMap { $0.values }
            .flatMap { $0 }
            .count
        
        guard totalTransactions >= 5 else {
            return false
        }
        
        let calendar: Calendar = Calendar.current
        
        if let currentDate = datesWithTransactions.last, let lastDate = allDates.last,
           let daysDifference = calendar.dateComponents([.day], from: currentDate, to: lastDate).day,
           daysDifference > 2 {
            return false
        }
        
        return true
    }
    
    func calculatePercentageChange(currentAmount: Double, baseAmounts: [Double], category: FinancialCategory) -> Int {
        guard !baseAmounts.isEmpty else { return 0 }
        
        let averageBaseAmount: Double = baseAmounts.reduce(0, +) / Double(baseAmounts.count)
        
        if averageBaseAmount == 0 {
            return currentAmount > 0 ? 100 : 0
        }
        
        let rawPercentageChange: Double = ((currentAmount - averageBaseAmount) / averageBaseAmount) * 100
        return Int(min(rawPercentageChange, 100))
    }
    
    func getPerformanceRating(for percentage: Int, category: FinancialCategory) -> PerformanceRating {
        switch category {
        case .income:
            if percentage >= 30 { return .excellent }
            else if percentage >= 10 { return .good }
            else if percentage >= 0 { return .neutral }
            else { return .warning }
        case .expense:
            if percentage <= -30 { return .excellent }
            else if percentage <= -10 { return .good }
            else if percentage <= 5 { return .neutral }
            else { return .warning }
            
        case .loss:
            if percentage <= -30 { return .excellent }
            else if percentage <= -10 { return .good }
            else if percentage <= 0 { return .neutral }
            else { return .warning }
        }
    }
    
    func calculateTotalsByDate(for transactions: [Date : [TransactionType : [TransactionDomainModel]]],
                               on dates: [Date]) -> [Date: [FinancialCategory: Double]] {
        var totalsByDate: [Date: [FinancialCategory: Double]] = [:]
        
        for date in dates {
            guard let dateTransactions = transactions[date] else {
                totalsByDate[date] = [.income: 0, .expense: 0, .loss: 0]
                continue
            }
            
            let income: Double = dateTransactions[.income]?.reduce(0) { $0 + $1.amount } ?? 0
            let expense: Double = dateTransactions[.expense]?.reduce(0) { $0 + $1.amount } ?? 0
            let loss: Double = max(expense - income, 0)
            
            totalsByDate[date] = [.income: income, .expense: expense, .loss: loss]
        }
        
        return totalsByDate
    }
}

// MARK: - Input, Output
extension AnalyticsViewModel {
    struct Input {
        let selectedPeriod: BehaviorRelay<PeriodType> = .init(value: .day())
        let transactionType: BehaviorRelay<TransactionType> = .init(value: .income)
    }
    
    struct Output {
        let barChartTransaction: BehaviorRelay<[FinancialBarChartData]> = .init(value: [])
        let lineChartTransaction: BehaviorRelay<[FinancialLineChartData]> = .init(value: [])
        let summaryData: BehaviorRelay<[AnalyticsSummary]> = .init(value: [])
        let isShowEmptyView: BehaviorRelay<Bool> = .init(value: false)
    }
}
