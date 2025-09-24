//
//  NotificationDomainModel.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 28.06.2025.
//

import Foundation

struct NotificationDomainModel: Hashable {
    let id: UUID
    let title: String
    let notes: String
    let date: Date
    let isActive: Bool
    let reminderType: ReminderType
}
