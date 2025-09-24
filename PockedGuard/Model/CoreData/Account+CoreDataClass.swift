//
//  Account+CoreDataClass.swift
//
//
//  Created by Арсен Дадаев on 12.07.2025.
//
//

import Foundation
import CoreData

@objc(Account)
public class Account: NSManagedObject {
    
}

extension Account {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Account> {
        return NSFetchRequest<Account>(entityName: "Account")
    }
    
    @NSManaged public var balance: Double
    @NSManaged public var currency: String?
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var date: Date?
    @NSManaged public var transaction: NSSet?
    
}

// MARK: Generated accessors for transaction
extension Account {
    
    @objc(addTransactionObject:)
    @NSManaged public func addToTransaction(_ value: Transaction)
    
    @objc(removeTransactionObject:)
    @NSManaged public func removeFromTransaction(_ value: Transaction)
    
    @objc(addTransaction:)
    @NSManaged public func addToTransaction(_ values: NSSet)
    
    @objc(removeTransaction:)
    @NSManaged public func removeFromTransaction(_ values: NSSet)
    
}

extension Account: DomainConvertible {
    typealias DomainModel = AccountDomainModel
    
    func toDomain() -> AccountDomainModel {
        AccountDomainModel(
            id: id ?? UUID(),
            name: name ?? "",
            balance: balance,
            currency: CurrencyType(rawValue: currency ?? "") ?? CurrencyType.rub
        )
    }
}

extension Account: Identifiable {
    
}
