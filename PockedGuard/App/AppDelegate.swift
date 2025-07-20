//
//  AppDelegate.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 08.03.2025.
//

import UIKit
import RxSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
        
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        requestNotificationPermissions()
        return true
    }
    
    // MARK: - Private Methods
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        { granted, error in
            if granted {
                print("Разрешение на уведомления получено")
            } else if let error = error {
                print("Ошибка при запросе разрешения: \(error.localizedDescription)")
            }
        }
    }
}
