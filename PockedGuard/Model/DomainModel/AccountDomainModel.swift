//
//  AccountDomainModel.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 28.06.2025.
//

import Foundation

struct AccountDomainModel: Equatable {
    let id: UUID
    let name: String
    let balance: Double
    let currency: CurrencyType
}
