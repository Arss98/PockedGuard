//
//  Font+Ext.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 09.10.2025.
//

import UIKit

extension UIFont {
    static func bebasNeueFont(size: CGFloat) -> UIFont {
        guard let font: UIFont = .init(name: "BebasNeueCyrillic.ttf", size: size) else {
          return UIFont.systemFont(ofSize: size)
        }
        return font
    }
}
