//
//  Category+CoreDataClass.swift
//  
//
//  Created by Арсен Дадаев on 12.07.2025.
//
//

import Foundation
import CoreData

@objc(Category)
public class Category: NSManagedObject {

}

extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var color: String?
    @NSManaged public var id: UUID?
    @NSManaged public var isSystem: Bool
    @NSManaged public var name: String?
    @NSManaged public var type: Int16
    @NSManaged public var transaction: NSSet?
    @NSManaged public var template: Templates?

}

// MARK: Generated accessors for transaction
extension Category {

    @objc(addTransactionObject:)
    @NSManaged public func addToTransaction(_ value: Transaction)

    @objc(removeTransactionObject:)
    @NSManaged public func removeFromTransaction(_ value: Transaction)

    @objc(addTransaction:)
    @NSManaged public func addToTransaction(_ values: NSSet)

    @objc(removeTransaction:)
    @NSManaged public func removeFromTransaction(_ values: NSSet)

}

extension Category: DomainConvertible {
    typealias DomainModel = CategoryDomainModel
    
    func toDomain() -> CategoryDomainModel {
        return CategoryDomainModel(
            id: id ?? UUID(),
            name: name ?? "",
            color: color ?? "",
            isSystem: isSystem,
            type: TransactionType(rawValue: type) ?? TransactionType.income
        )
    }
}

extension Category: Identifiable {
    
}
