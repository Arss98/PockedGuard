//
//  ColorStorageService.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 27.09.2025.
//

import Foundation

protocol ColorStorageServiceProtocol {
    func getColors() -> [String]
    func addColor(_ color: String)
    func containsColor(_ color: String) -> Bool
}

final class ColorStorageService: ColorStorageServiceProtocol {
    private let userDefaultsKey = "customColors"
    private let defaultColors = ["#FF5733", "#33FF57", "#3357FF", "#F033FF", "#FF33A8", "#33FFF5", "#8A33FF"]
    private let maxColors = 7
    
    init() {
        setupDefaultColorsIfNeeded()
    }
    
    private func setupDefaultColorsIfNeeded() {
        let savedColors = UserDefaults.standard.stringArray(forKey: userDefaultsKey)
        if savedColors == nil || savedColors?.isEmpty == true {
            UserDefaults.standard.set(defaultColors, forKey: userDefaultsKey)
        }
    }
    
    func getColors() -> [String] {
        return UserDefaults.standard.stringArray(forKey: userDefaultsKey) ?? defaultColors
    }
    
    func addColor(_ color: String) {
        var colors = getColors()
        
        colors.removeAll { $0.lowercased() == color.lowercased() }
        colors.insert(color, at: 0)
        
        if colors.count > maxColors {
            colors = Array(colors.prefix(maxColors))
        }
        
        UserDefaults.standard.set(colors, forKey: userDefaultsKey)
    }
    
    func containsColor(_ color: String) -> Bool {
        return getColors().contains { $0.lowercased() == color.lowercased() }
    }
}
