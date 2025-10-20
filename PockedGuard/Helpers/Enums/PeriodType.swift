//
//  PeriodType.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 07.09.2025.
//

import Foundation

enum PeriodType: Equatable {
    case day(start: Date = Calendar.current.startOfDay(for: Date()))
    case week(start: Date = Calendar.current.startOfDay(for: Date()))
    case month(start: Date = Calendar.current.startOfDay(for: Date()))
    case year(start: Date = Calendar.current.startOfDay(for: Date()))
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
        case .year: return ""
        }
    }
}

// MARK: - Next, Previous period
extension PeriodType {
    var previous: PeriodType {
        switch self {
        case .day(let start):
            return .day(start: Calendar.current.date(byAdding: .day, value: -1, to: start) ?? Date())
        case .week(let start):
            return .week(start: Calendar.current.date(byAdding: .weekOfYear, value: -1, to: start) ?? Date())
        case .month(let start):
            return .month(start: Calendar.current.date(byAdding: .month, value: -1, to: start) ?? Date())
        default:
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
        default:
            return self
        }
    }
    
    var isFuture: Bool {
        let now: Date = .init()
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
        default:
            return true
        }
    }
}

// MARK: - Analytics Diagram
extension PeriodType {
    func getDisplayDates() -> [Date] {
        let calendar: Calendar = Calendar.current
        var dates: [Date] = []
        
        switch self {
        case .day(let start):
            for dayOffset in (-6)...0 {
                if let date = calendar.date(byAdding: .day, value: dayOffset, to: start) {
                    dates.append(date)
                }
            }
        case .week(let start):
            let startOfWeek: Date = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: start))!
            
            for weekOffset in (-6)...0 {
                if let date = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: startOfWeek) {
                    dates.append(date)
                }
            }
        case .month(let start):
            let startOfMonth: Date = calendar.date(from: calendar.dateComponents([.year, .month], from: start))!
            for monthOffset in (-6)...0 {
                if let date = calendar.date(byAdding: .month, value: monthOffset, to: startOfMonth) {
                    dates.append(date)
                }
            }
        case .year(let start):
            let startOfYear: Date = calendar.date(from: calendar.dateComponents([.year], from: start))!
            for yearOffset in (-6)...0 {
                if let date = calendar.date(byAdding: .year, value: yearOffset, to: startOfYear) {
                    dates.append(date)
                }
            }
        case .custom:
            break
        }
        
        return dates
    }
    
    func formatDateForXAxis(_ date: Date) -> String {
        let formatter: DateFormatter = .init()
        formatter.locale = Locale(identifier: "ru_RU")
        
        switch self {
        case .day:
            formatter.dateFormat = "dd.MM"
            return formatter.string(from: date)
        case .week:
            formatter.dateFormat = "dd.MM"
            return formatter.string(from: date)
        case .month:
            formatter.dateFormat = "MMM"
            formatter.monthSymbols = Constants.monthSymbols
            return formatter.string(from: date)
        case .year:
            formatter.dateFormat = "yyyy"
            return formatter.string(from: date)
        case .custom: return ""
        }
    }
    
    var xAxisStride: Calendar.Component {
        switch self {
        case .day: return .day
        case .week: return .weekOfYear
        case .month: return .month
        case .year: return .year
        case .custom: return .day
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
