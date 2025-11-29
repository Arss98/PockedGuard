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
        case .rub: return
            L10n.Finance.Currency.rub
        case .usd: return L10n.Finance.Currency.usd
        case .eur: return L10n.Finance.Currency.eur
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
