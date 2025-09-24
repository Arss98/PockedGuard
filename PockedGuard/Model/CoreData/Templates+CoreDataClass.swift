//
//  Templates+CoreDataClass.swift
//  
//
//  Created by Арсен Дадаев on 12.07.2025.
//
//

import Foundation
import CoreData

@objc(Templates)
public class Templates: NSManagedObject {

}

extension Templates {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Templates> {
        return NSFetchRequest<Templates>(entityName: "Templates")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var icon: String?
    @NSManaged public var amount: Double
    @NSManaged public var type: Int16
    @NSManaged public var category: Category?

}

extension Templates: DomainConvertible {
    typealias DomainModel = TemplateDomainModel
    
    func toDomain() -> TemplateDomainModel {
        TemplateDomainModel(
            id: id ?? UUID(),
            icon: icon ?? "",
            amount: amount,
            type: TransactionType(rawValue: type) ?? TransactionType.income,
            category: category?.toDomain()
        )
    }
}

extension Templates: Identifiable {
    
}
