//
//  CategoryDomainModel.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 28.06.2025.
//

import Foundation

struct CategoryDomainModel {
    let id: UUID
    let name: String
    let color: String
    let isSystem: Bool
    let type: TransactionType
}
