//
//  TemplatesDomainModel.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 12.07.2025.
//

import Foundation

struct TemplatesDomainModel {
    let id: UUID
    let icon: String
    let amount: Double?
    let type: TransactionType?
    let category: CategoryDomainModel?
}
