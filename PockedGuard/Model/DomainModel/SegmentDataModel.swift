//
//  SegmentDataModel.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 16.07.2025.
//

import Foundation

struct SegmentDataModel {
    let value: CGFloat
    let color: String?
    let categoryName: String
    
    static let empty = SegmentDataModel(value: .zero, color: "", categoryName: "")
}
