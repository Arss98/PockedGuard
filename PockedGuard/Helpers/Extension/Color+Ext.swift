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
        
        guard formattedString.count == 6 else { return nil }
        
        guard let hexValue = Int(formattedString, radix: 16) else { return nil }
        
        let red = CGFloat((hexValue >> 16) & 0xFF) / 255.0
        let green = CGFloat((hexValue >> 8) & 0xFF) / 255.0
        let blue = CGFloat(hexValue & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
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
