//
//  ReminderType.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 21.09.2025.
//

import Foundation

enum ReminderType: Int16, CaseIterable {
    case once = 0
    case everyDay = 1
    case everyWeek = 2
    case everyMonth = 3
    
    var localizedTitle: String {
        switch self {
        case .once: return String.Localized.Notification.once.localized
        case .everyDay: return String.Localized.Notification.everyDay.localized
        case .everyWeek: return String.Localized.Notification.everyWeek.localized
        case .everyMonth: return String.Localized.Notification.everyMonth.localized
        }
    }
}
