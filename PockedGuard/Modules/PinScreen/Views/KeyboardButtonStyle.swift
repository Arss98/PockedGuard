//
//  KeyboardButtonStyle.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 21.11.2025.
//

import SwiftUI

struct CustomFilledButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? .appSelectedBlue : .appCardAndField)
            .clipShape(.circle)
            .foregroundColor(.white)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct CustomOutlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .background(.clear)
            .foregroundStyle(configuration.isPressed ? .appSelectedBlue : .white)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}
