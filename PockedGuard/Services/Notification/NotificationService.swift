//
//  NotificationService.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 08.07.2025.
//

import UserNotifications

protocol NotificationSchedulerProtocol {
    func scheduleNotification(
        id: UUID,
        title: String,
        body: String,
        date: Date,
        reminderType: ReminderType,
        isActive: Bool
    ) throws
    
    func updateNotification(
        id: UUID,
        title: String,
        body: String,
        date: Date,
        reminderType: ReminderType,
        isActive: Bool
    ) throws
    
    func removeNotification(id: UUID)
}

final class NotificationScheduler: NotificationSchedulerProtocol {
    private let notificationCenter: UNUserNotificationCenter
    
    init () {
        notificationCenter = .current()
    }

    // MARK: - Public methods
    func scheduleNotification(
        id: UUID,
        title: String,
        body: String,
        date: Date,
        reminderType: ReminderType,
        isActive: Bool
    ) throws {
        guard isActive else { return }

        var schedulingError: Error?
        let semaphore = DispatchSemaphore(value: 0)
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = createTrigger(for: date, reminderType: reminderType)
        let request = UNNotificationRequest(identifier: id.uuidString, content: content, trigger: trigger)

        notificationCenter.add(request) { error in
            schedulingError = error
            semaphore.signal()
        }
        
        semaphore.wait()
        
        if let error = schedulingError { throw error }
    }

    func updateNotification(
        id: UUID,
        title: String,
        body: String,
        date: Date,
        reminderType: ReminderType,
        isActive: Bool
    ) throws {
        removeNotification(id: id)
        try scheduleNotification(id: id, title: title, body: body, date: date, reminderType: reminderType, isActive: isActive)
    }

    func removeNotification(id: UUID) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [id.uuidString])
    }
}

// MARK: - Private methods
private extension NotificationScheduler {
    func createTrigger(for date: Date, reminderType: ReminderType) -> UNNotificationTrigger {
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)

        switch reminderType {
        case .once:
            return UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        case .everyDay:
            var dailyComponents = components
            dailyComponents.hour = components.hour
            dailyComponents.minute = components.minute
            return UNCalendarNotificationTrigger(dateMatching: dailyComponents, repeats: true)
        case .everyWeek:
            let weekday = Calendar.current.component(.weekday, from: date)
            var weeklyComponents = components
            weeklyComponents.weekday = weekday
            return UNCalendarNotificationTrigger(dateMatching: weeklyComponents, repeats: true)
        case .everyMonth:
            let day = Calendar.current.component(.day, from: date)
            var monthlyComponents = components
            monthlyComponents.day = day
            return UNCalendarNotificationTrigger(dateMatching: monthlyComponents, repeats: true)
        }
    }
}
