//
//  TransactionDomainModel.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 28.06.2025.
//

import Foundation

struct TransactionDomainModel: Hashable {
    let id: UUID
    let amount: Double
    let date: Date
    let type: TransactionType
    let paymentMethod: PaymentMethod
    let notes: String?
    let category: CategoryDomainModel?
    let account: AccountDomainModel?
}

enum TransactionType: Int16, CaseIterable {
    case expense = 0
    case income = 1
}

enum PaymentMethod: String {
    case cash, card, transfer, crypto
}
