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
        case .excellent: return L10n.Analytics.Rating.excellent
        case .good: return L10n.Analytics.Rating.good
        case .neutral: return L10n.Analytics.Rating.neutral
        case .warning: return L10n.Analytics.Rating.warning
        }
    }
    
    var color: UIColor {
        switch self {
        case .excellent, .good, .neutral: return .appSelectedBlue
        case .warning: return .appErrorRed
        }
    }
}
