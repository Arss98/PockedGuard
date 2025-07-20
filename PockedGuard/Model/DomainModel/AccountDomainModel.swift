//
//  AccountDomainModel.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 28.06.2025.
//

import Foundation

struct AccountDomainModel {
    let id: UUID
    let name: String
    let balance: Double
    let type: AccountType
    let currency: Currency
}

enum AccountType: Int16 {
    case cash, debitCard, creditCard, savings
}

enum Currency: String {
    case rub = "RUB", usd = "USD", eur = "EUR"
}
