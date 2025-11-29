//
//  HapticsService.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 21.11.2025.
//

import UIKit

// MARK: - Protocol
protocol HapticsServiceProtocol {
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle)
    func success()
    func error()
    func warning()
    func selection()
}

final class HapticsService: HapticsServiceProtocol {
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator: UIImpactFeedbackGenerator = .init(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
    
    func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
    
    func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}

// MARK: - Mock
final class HapticsServiceMock: HapticsServiceProtocol {
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {}
    func success() {}
    func error() {}
    func warning() {}
    func selection() {}
}

enum Haptics {
    static var service: HapticsServiceProtocol = HapticsService()
    
    // MARK: - Static methods
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        service.impact(style: style)
    }
    
    static func success() {
        service.success()
    }
    
    static func error() {
        service.error()
    }
    
    static func warning() {
        service.warning()
    }
    
    static func selection() {
        service.selection()
    }
    
    static func light()   { impact(.light) }
    static func medium()  { impact(.medium) }
    static func heavy()   { impact(.heavy) }
    static func rigid()   { impact(.rigid) }
    static func soft()    { impact(.soft) }
}
