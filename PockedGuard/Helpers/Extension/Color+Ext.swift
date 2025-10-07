//
//  Color+Ext.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 13.07.2025.
//

import UIKit

extension UIColor {
    convenience init?(hexString: String, alpha: CGFloat = 1.0) {
        var formattedString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        formattedString = formattedString.replacingOccurrences(of: "#", with: "")
        
        guard formattedString.count == 6 || formattedString.count == 8 else { return nil }
        guard let hexValue = UInt64(formattedString, radix: 16) else { return nil }
        
        let red, green, blue, alphaComponent: CGFloat
        
        if formattedString.count == 8 {
            red = CGFloat((hexValue >> 24) & 0xFF) / 255.0
            green = CGFloat((hexValue >> 16) & 0xFF) / 255.0
            blue = CGFloat((hexValue >> 8) & 0xFF) / 255.0
            alphaComponent = CGFloat(hexValue & 0xFF) / 255.0
        } else {
            red = CGFloat((hexValue >> 16) & 0xFF) / 255.0
            green = CGFloat((hexValue >> 8) & 0xFF) / 255.0
            blue = CGFloat(hexValue & 0xFF) / 255.0
            alphaComponent = alpha
        }
        
        self.init(red: red, green: green, blue: blue, alpha: alphaComponent)
    }
}


extension UIColor {
    func toHex() -> String? {
        guard let components = cgColor.components, components.count >= 3 else {
            return nil
        }
        
        let red = components[0]
        let green = components[1]
        let blue = components[2]
        let alpha = components.count >= 4 ? components[3] : 1.0
        
        let redInt = Int(round(red * 255))
        let greenInt = Int(round(green * 255))
        let blueInt = Int(round(blue * 255))
        let alphaInt = Int(round(alpha * 255))
        
        let hexString = String(format: "#%02X%02X%02X%02X", redInt, greenInt, blueInt, alphaInt)
        return hexString
    }
}

import SwiftUI

extension Color {
    init(hex: String?) {
        guard let hex = hex else {
            self.init(.sRGB, red: 1, green: 1, blue: 1, opacity: 1)
            return
        }
        
        let sanitizedHex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: sanitizedHex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch sanitizedHex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
