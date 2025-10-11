//
//  TransactionSection.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 17.07.2025.
//

import Foundation

struct TransactionSection: Hashable {
    let categoryName: String
    let percentage: String
    let transactions: [TransactionDomainModel]
    let currencySymbol: String
}
