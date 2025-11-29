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
        case .once: return L10n.Notifications.once
        case .everyDay: return L10n.Notifications.everyDay
        case .everyWeek: return L10n.Notifications.everyWeek
        case .everyMonth: return L10n.Notifications.everyMonth
        }
    }
}
