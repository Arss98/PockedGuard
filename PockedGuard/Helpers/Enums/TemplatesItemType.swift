//
//  TemplatesItemType.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 20.09.2025.
//

import Foundation

enum TemplatesItemType {
    case template(TemplateDomainModel)
    case add
}

extension TemplatesItemType: Hashable {
    static func == (lhs: TemplatesItemType, rhs: TemplatesItemType) -> Bool {
        switch (lhs, rhs) {
        case (.template(let lhsTemplate), .template(let rhsTemplate)):
            return lhsTemplate == rhsTemplate
        case (.add, .add):
            return true
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .template(let template):
            hasher.combine(template)
        case .add:
            hasher.combine("add")
        }
    }
}
