//
//  AccountItemType.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 20.09.2025.
//

import Foundation

enum AccountItemType {
    case account(AccountDomainModel)
    case add 
}

extension AccountItemType: Hashable {
    static func == (lhs: AccountItemType, rhs: AccountItemType) -> Bool {
        switch (lhs, rhs) {
        case (.account(let lhsAccount), .account(let rhsAccount)):
            return lhsAccount == rhsAccount
        case (.add, .add): 
            return true
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .account(let account):
            hasher.combine(account)
        case .add:
            hasher.combine("add")
        }
    }
}
