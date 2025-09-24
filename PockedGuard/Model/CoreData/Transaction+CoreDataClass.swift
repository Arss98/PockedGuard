//
//  Transaction+CoreDataClass.swift
//  
//
//  Created by Арсен Дадаев on 12.07.2025.
//
//

import Foundation
import CoreData

@objc(Transaction)
public class Transaction: NSManagedObject {

}

extension Transaction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }

    @NSManaged public var amount: Double
    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var notes: String?
    @NSManaged public var paymentMethod: String?
    @NSManaged public var type: Int16
    @NSManaged public var account: Account?
    @NSManaged public var category: Category?

}

extension Transaction: DomainConvertible {
    typealias DomainModel = TransactionDomainModel
    
    func toDomain() -> TransactionDomainModel {
        TransactionDomainModel(
            id: id ?? UUID(),
            amount: amount,
            date: date ?? Date(),
            type: TransactionType(rawValue: type) ?? TransactionType.income,
            paymentMethod: PaymentMethod(rawValue: paymentMethod ?? "") ?? PaymentMethod.cash,
            notes: notes,
            category: category?.toDomain(),
            account: account?.toDomain())
    }
}

extension Transaction: Identifiable {
    
}
