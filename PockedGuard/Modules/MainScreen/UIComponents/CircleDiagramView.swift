//
//  CircleDiagramView.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 10.03.2025.
//

import SwiftUI

struct CircleDiagramView: View {
    private let segments: [SegmentDataModel]
    private let totalValue: CGFloat
    @State private var selectedSegmentIndex: Int?
    
    init(segments: [SegmentDataModel] = []) {
        self.segments = segments
        self.totalValue = segments.reduce(.zero) { $0 + $1.value }
    }
    
    var body: some View {
        ZStack {
            diagram
            summaryInfo
        }
        .foregroundStyle(.white)
    }
}
//"chevron.left"
//"chevron.right"
// MARK: - Computed property
private extension CircleDiagramView {
    var diagram: some View {
        GeometryReader { geometry in
            ZStack {
                if totalValue == .zero || segments.isEmpty {
                    emptyDiagram(in: geometry)
                } else {
                    segmentsLayer(in: geometry)
                }
            }
            .shadow(
                color: Color(.black).opacity(Constants.shadowOpacity),
                radius: Constants.shadowRadius
            )
        }
        .aspectRatio(1, contentMode: .fit)
        .background(.appCardAndField)
        .cornerRadius(.infinity)
    }
    
    var summaryInfo: some View {
        VStack {
            Text(selectedSegmentName)
                .font(.system(size: Constants.titleFontSize, weight: .medium))
            Text(selectedValueText)
                .font(.system(size: Constants.totalAmountFontSize, weight: .regular))
        }
    }
    
    var selectedSegmentName: String {
        guard let index = selectedSegmentIndex, !segments.isEmpty, totalValue > 0 else { return .Localized.Common.total.localized }
        return segments[index].categoryName
    }
    
    var selectedValueText: String {
        if let index = selectedSegmentIndex, !segments.isEmpty, totalValue > 0 {
            return "\(segments[index].value.formatted()) ₽"
        } else {
            return "\(totalValue.formatted()) ₽"
        }
    }
}

// MARK: - Private methods
private extension CircleDiagramView {
    func emptyDiagram(in geometry: GeometryProxy) -> some View {
        let radius = calculateRadius(for: geometry)
        return Circle()
            .stroke(Color.appMainBlue, lineWidth: Constants.lineWidth)
            .frame(width: radius * 2, height: radius * 2)
            .position(centerPoint(for: geometry))
    }
    
    func segmentsLayer(in geometry: GeometryProxy) -> some View {
        ForEach(segments.indices, id: \.self) { index in
            segmentPath(for: index, in: geometry)
                .onTapGesture { selectSegment(index) }
                .animation(.easeInOut(duration: Constants.animationDuration), value: selectedSegmentIndex)
        }
    }
    
    func segmentPath(for index: Int, in geometry: GeometryProxy) -> some View {
        let isSelected = selectedSegmentIndex == index
        let lineWidth = isSelected ? Constants.lineWidth * 1.2 : Constants.lineWidth
        
        return Path { path in
            let (startAngle, endAngle) = calculateAngles(for: index)
            path.addArc(
                center: centerPoint(for: geometry),
                radius: calculateRadius(for: geometry),
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: false
            )
        }
        .stroke(
            Color(hex: segments[index].color),
            style: StrokeStyle(
                lineWidth: lineWidth,
                lineCap: .butt
            )
        )
    }
    
    func calculateAngles(for index: Int) -> (Angle, Angle) {
        let start = segments[0..<index].reduce(0) { $0 + $1.value }
        let startAngle = Angle(radians: 2 * .pi * start / totalValue - .pi/2)
        let endAngle = Angle(radians: startAngle.radians + 2 * .pi * segments[index].value / totalValue)
        return (startAngle, endAngle)
    }
    
    func centerPoint(for geometry: GeometryProxy) -> CGPoint {
        CGPoint(x: geometry.size.width/2, y: geometry.size.height/2)
    }
    
    func calculateRadius(for geometry: GeometryProxy) -> CGFloat {
        min(geometry.size.width, geometry.size.height)/2 - Constants.padding
    }
    
    func percentage(for index: Int) -> Int {
        Int((segments[index].value / totalValue) * 100)
    }
    
    func selectSegment(_ index: Int) {
        selectedSegmentIndex = (selectedSegmentIndex == index) ? nil : index
    }
}

// MARK: - Constants
private enum Constants {
    static let lineWidth: CGFloat = 30
    static let shadowRadius: CGFloat = 8
    static let shadowOpacity: Double = 0.4
    static let padding: CGFloat = 28
    static let animationDuration: Double = 0.3
    static let buttonSize: CGFloat = 32
    static let titleFontSize: CGFloat = 20
    static let totalAmountFontSize: CGFloat = 24
}

#Preview {
    CircleDiagramView()
}
