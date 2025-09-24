//
//  CurrencyType.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 21.09.2025.
//

import Foundation

enum CurrencyType: String, CaseIterable {
    case rub = "RUB", usd = "USD", eur = "EUR"
    
    var localizedTitle: String {
        switch self {
        case .rub: return .Localized.Common.RUB.localized
        case .usd: return .Localized.Common.USD.localized
        case .eur: return .Localized.Common.EUR.localized
        }
    }
    
    var symbol: String {
        switch self {
        case .rub: return "₽"
        case .usd: return "$"
        case .eur: return "€"
        }
    }
}
