//
//  Date+Ext.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 04.06.2025.
//

import Foundation

// MARK: - Extension Date
extension Date {
    static func weekDates(for date: Date) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let start = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)) ?? date
        let end = calendar.date(byAdding: .day, value: 6, to: start) ?? date
        return (start, end)
    }
    
    static func monthDates(for date: Date) -> (start: Date, end: Date) {
        let calendar: Calendar = Calendar.current
        let components: DateComponents = calendar.dateComponents([.year, .month], from: date)
        let startOfMonth: Date = calendar.date(from: components)!
        let endOfMonth: Date = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
        return (startOfMonth, endOfMonth)
    }
}

// MARK: - Extension DateFormatter
extension DateFormatter {
    static var ruDateTimeShort: DateFormatter {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }
    
    static var dateShort: DateFormatter {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }
}
