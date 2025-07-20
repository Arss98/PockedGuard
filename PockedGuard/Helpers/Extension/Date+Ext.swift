//
//  Date+Ext.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 04.06.2025.
//

import Foundation

// MARK: - Extension Date
extension Date {
    static func currentWeekDates() -> (start: Date, end: Date) {
        let now = Date()
        let calendar = Calendar.current
        let start = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        let end = calendar.date(byAdding: .day, value: 6, to: start)!
        return (start, end)
    }
    
    static func currentMonthDates() -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month], from: now)
        let startOfMonth = calendar.date(from: components)!
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
        return (startOfMonth, endOfMonth)
    }
}

// MARK: - Extension DateFormatter
extension DateFormatter {
    static var ruDateTimeShort: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }
    
    static var dateShort: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }
}
