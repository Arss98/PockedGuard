//
//  View+Ext.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 07.06.2025.
//

import SwiftUI

extension View {
    func datePickerButtonStyle() -> some View {
        self
            .frame(maxWidth: .infinity)
            .padding(.vertical)
            .background(.appMainBlue)
            .foregroundStyle(.white)
            .cornerRadius(8)
    }
}
