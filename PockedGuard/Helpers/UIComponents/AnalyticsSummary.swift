//
//  AnalyticsSummary.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 15.10.2025.
//

import UIKit

struct AnalyticsSummary {
    let type: FinancialCategory
    let percentageChange: Int
    let rating: PerformanceRating
}

enum PerformanceRating {
    case excellent
    case good
    case neutral
    case warning
    
    var message: String {
        switch self {
        case .excellent: return .Localized.Analytics.excellent.localized
        case .good: return .Localized.Analytics.good.localized
        case .neutral: return .Localized.Analytics.neutral.localized
        case .warning: return .Localized.Analytics.warning.localized
        }
    }
    
    var color: UIColor {
        switch self {
        case .excellent, .good, .neutral: return .appSelectedBlue
        case .warning: return .appErrorRed
        }
    }
}
