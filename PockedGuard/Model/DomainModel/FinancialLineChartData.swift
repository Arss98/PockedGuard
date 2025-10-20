//
//  FinancialLineChartData.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 13.10.2025.
//

import Foundation

struct FinancialLineChartData: Identifiable, Hashable {
    let id: UUID = UUID()
    let date: Date
    let amount: Double
    
    static var mockData: [FinancialLineChartData] {
        let calendar: Calendar = Calendar.current
        let today: Date = Date()
        
        return [
            FinancialLineChartData(date: calendar.date(byAdding: .day, value: -6, to: today)!, amount: 15000),
            FinancialLineChartData(date: calendar.date(byAdding: .day, value: -5, to: today)!, amount: 18000),
            FinancialLineChartData(date: calendar.date(byAdding: .day, value: -4, to: today)!, amount: 12500),
            FinancialLineChartData(date: calendar.date(byAdding: .day, value: -3, to: today)!, amount: 22000),
            FinancialLineChartData(date: calendar.date(byAdding: .day, value: -2, to: today)!, amount: 0),
            FinancialLineChartData(date: calendar.date(byAdding: .day, value: -1, to: today)!, amount: 19000),
            FinancialLineChartData(date: today, amount: 21000)
        ]
    }
}
