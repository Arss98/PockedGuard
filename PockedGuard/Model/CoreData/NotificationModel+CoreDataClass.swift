//
//  NotificationModel+CoreDataClass.swift
//  
//
//  Created by Арсен Дадаев on 01.07.2025.
//
//

import Foundation
import CoreData

@objc(NotificationModel)
public class NotificationModel: NSManagedObject {

}

extension NotificationModel {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<NotificationModel> {
        return NSFetchRequest<NotificationModel>(entityName: "NotificationModel")
    }

    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var isActive: Bool
    @NSManaged public var notes: String?
    @NSManaged public var reminderType: Int16
    @NSManaged public var title: String?

}

extension NotificationModel {
    func toDomain() -> NotificationDomainModel {
        NotificationDomainModel(
            id: id ?? UUID(),
            title: title ?? "",
            notes: notes ?? "",
            date: date ?? Date(),
            isActive: isActive,
            reminderType: ReminderType(rawValue: reminderType) ?? ReminderType.once
        )
    }
}

extension NotificationModel: Identifiable {

}
