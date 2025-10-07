//
//  CategoryItemType.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 20.09.2025.
//

import Foundation

enum CategoryItemType {
    case category(CategoryDomainModel)
    case add
}

extension CategoryItemType: Hashable {
    static func == (lhs: CategoryItemType, rhs: CategoryItemType) -> Bool {
        switch (lhs, rhs) {
        case (.category(let lhsCategory), .category(let rhsCategory)):
            return lhsCategory == rhsCategory
        case (.add, .add):
            return true
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .category(let category):
            hasher.combine(category)
        case .add:
            hasher.combine("add")
        }
    }
}
