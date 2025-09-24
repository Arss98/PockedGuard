//
//  PeriodType.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 07.09.2025.
//

import Foundation

enum PeriodType: Equatable {
    case day(start: Date = Date())
    case week(start: Date = Date())
    case month(start: Date = Date())
    case custom(start: Date, end: Date)
    
    var description: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        
        switch self {
        case .day(let start):
            if Calendar.current.isDateInToday(start) {
                return .Localized.Common.today.localized
            } else {
                formatter.dateFormat = "dd MMMM"
                return formatter.string(from: start)
            }
        case .week(let start):
            formatter.dateFormat = "dd.MM.yyyy"
            let dates: (start: Date, end: Date) = Date.weekDates(for: start)
            return "\(formatter.string(from: dates.start)) - \(formatter.string(from: dates.end))"
        case .month(let start):
            formatter.dateFormat = "MMMM"
            formatter.monthSymbols = Constants.monthSymbols
            return formatter.string(from: start)
        case .custom(let start, let end):
            formatter.dateFormat = "dd.MM.yyyy"
            return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
        }
    }
}

extension PeriodType {
    var previous: PeriodType {
        switch self {
        case .day(let start):
            return .day(start: Calendar.current.date(byAdding: .day, value: -1, to: start) ?? Date())
        case .week(let start):
            return .week(start: Calendar.current.date(byAdding: .weekOfYear, value: -1, to: start) ?? Date())
        case .month(let start):
            return .month(start: Calendar.current.date(byAdding: .month, value: -1, to: start) ?? Date())
        case .custom:
            return self
        }
    }
    
    var next: PeriodType {
        switch self {
        case .day(let start):
            return .day(start: Calendar.current.date(byAdding: .day, value: 1, to: start) ?? Date())
        case .week(let start):
            return .week(start: Calendar.current.date(byAdding: .weekOfYear, value: 1, to: start) ?? Date())
        case .month(let start):
            return .month(start: Calendar.current.date(byAdding: .month, value: 1, to: start) ?? Date())
        case .custom:
            return self
        }
    }
    
    var isFuture: Bool {
        let now = Date()
        switch self {
        case .day(let start):
            let nextDay: Date = Calendar.current.date(byAdding: .day, value: 1, to: start) ?? start
            return nextDay > now
        case .week(let start):
            let end: Date = Calendar.current.date(byAdding: .day, value: 6, to: start) ?? start
            return end > now
        case .month(let start):
            let end: Date = Calendar.current.date(byAdding: .month, value: 1, to: start) ?? start
            return end > now
        case .custom:
            return true
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
