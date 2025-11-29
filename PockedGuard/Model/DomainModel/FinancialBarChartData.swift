//
//  FinancialBarChartData.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 12.10.2025.
//

import SwiftUI

struct FinancialBarChartData: Identifiable, Hashable {
    let id: UUID = UUID()
    let period: Date
    let amount: Double
    let category: FinancialCategory
}

enum FinancialCategory: String, CaseIterable {
    case income = "income"
    case expense = "expense"
    case loss = "loss"
    
    var localizedName: String {
        switch self {
        case .income: return L10n.Finance.income
        case .expense: return L10n.Finance.expenses
        case .loss: return L10n.Finance.loss
        }
    }
    
    var color: Color {
        switch self {
        case .income: return .appIncome
        case .expense: return .appExpense
        case .loss: return .appLoss
        }
    }
}

extension FinancialBarChartData {
    static var mockData: [FinancialBarChartData] {
        let calendar: Calendar = Calendar.current
        let today: Date = Date()
        
        return [
            FinancialBarChartData(period: calendar.date(byAdding: .day, value: -6, to: today)!, amount: 15000, category: .income),
            FinancialBarChartData(period: calendar.date(byAdding: .day, value: -6, to: today)!, amount: 12000, category: .expense),
            FinancialBarChartData(period: calendar.date(byAdding: .day, value: -6, to: today)!, amount: 2000, category: .loss),
            
            FinancialBarChartData(period: calendar.date(byAdding: .day, value: -5, to: today)!, amount: 18000, category: .income),
            FinancialBarChartData(period: calendar.date(byAdding: .day, value: -5, to: today)!, amount: 14500, category: .expense),
            FinancialBarChartData(period: calendar.date(byAdding: .day, value: -5, to: today)!, amount: 2000, category: .loss),
            
            FinancialBarChartData(period: calendar.date(byAdding: .day, value: -4, to: today)!, amount: 12500, category: .income),
            FinancialBarChartData(period: calendar.date(byAdding: .day, value: -4, to: today)!, amount: 13000, category: .expense),
            FinancialBarChartData(period: calendar.date(byAdding: .day, value: -4, to: today)!, amount: 500, category: .loss),
            
            FinancialBarChartData(period: calendar.date(byAdding: .day, value: -3, to: today)!, amount: 22000, category: .income),
            FinancialBarChartData(period: calendar.date(byAdding: .day, value: -3, to: today)!, amount: 18000, category: .expense),
            FinancialBarChartData(period: calendar.date(byAdding: .day, value: -3, to: today)!, amount: 2000, category: .loss),
            
            FinancialBarChartData(period: calendar.date(byAdding: .day, value: -2, to: today)!, amount: 0, category: .income),
            FinancialBarChartData(period: calendar.date(byAdding: .day, value: -2, to: today)!, amount: 0, category: .expense),
            FinancialBarChartData(period: calendar.date(byAdding: .day, value: -2, to: today)!, amount: 0, category: .loss),
            
            FinancialBarChartData(period: calendar.date(byAdding: .day, value: -1, to: today)!, amount: 19000, category: .income),
            FinancialBarChartData(period: calendar.date(byAdding: .day, value: -1, to: today)!, amount: 16500, category: .expense),
            FinancialBarChartData(period: calendar.date(byAdding: .day, value: -1, to: today)!, amount: 2000, category: .loss),
            
            FinancialBarChartData(period: today, amount: 21000, category: .income),
            FinancialBarChartData(period: today, amount: 19500, category: .expense),
            FinancialBarChartData(period: today, amount: 1200, category: .loss)
        ]
    }
}
