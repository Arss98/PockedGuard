//
//  CircleDiagramView.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 10.03.2025.
//

import SwiftUI

struct CircleDiagramView: View {
    // MARK: - Private properties
    private let segments: [SegmentDataModel]
    private let currencySymbol: String
    private let totalValue: CGFloat
    @State private var selectedSegmentIndex: Int?
    @State private var animationProgress: CGFloat = 0.0
    
    // MARK: - init
    init(segments: [SegmentDataModel] = [], currencySymbol: String = "₽") {
        self.segments = segments
        self.totalValue = segments.reduce(.zero) { $0 + $1.value }
        self.currencySymbol = currencySymbol
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            diagram
            summaryInfo
        }
        .foregroundStyle(.white)
        .onAppear {
            withAnimation(.easeInOut(duration: Constants.Animation.mainDuration)) {
                animationProgress = 1.0
            }
        }
        .onChange(of: segments) { _, _ in
            selectedSegmentIndex = nil
            animationProgress = 0.0
            withAnimation(.easeInOut(duration: Constants.Animation.mainDuration)) {
                animationProgress = 1.0
            }
        }
    }
}

// MARK: - Computed property
private extension CircleDiagramView {
    var diagram: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .stroke(Color.appMainBlue.opacity(Constants.Layout.strokeOpacity), lineWidth: Constants.Layout.lineWidth)
                    .padding(Constants.Layout.lineWidth)
                
                if totalValue == .zero || segments.isEmpty {
                    emptyDiagram(in: geometry)
                } else {
                    animatedSegmentsLayer(in: geometry)
                }
            }
            .shadow(
                color: Color(.black).opacity(Constants.Layout.shadowOpacity),
                radius: Constants.Layout.shadowRadius
            )
        }
        .aspectRatio(1, contentMode: .fit)
        .background(.appCardAndField)
        .cornerRadius(.infinity)
    }
    
    var summaryInfo: some View {
        VStack {
            Text(selectedSegmentName)
                .font(.system(size: Constants.Layout.titleFontSize, weight: .medium))
            Text(selectedValueText)
                .font(.system(size: Constants.Layout.totalAmountFontSize, weight: .regular))
        }
    }
    
    var selectedSegmentName: String {
        guard let index = selectedSegmentIndex,
              !segments.isEmpty,
              totalValue > 0,
              segments.indices.contains(index) else {
            return .Localized.Common.total.localized
        }
        return segments[index].categoryName
    }
    
    var selectedValueText: String {
        guard let index = selectedSegmentIndex,
              !segments.isEmpty,
              totalValue > 0,
              segments.indices.contains(index) else {
            return "\(totalValue.formatted()) \(currencySymbol)"
        }
        return "\(segments[index].value.formatted()) \(currencySymbol)"
    }
}

// MARK: - Private methods
private extension CircleDiagramView {
    func emptyDiagram(in geometry: GeometryProxy) -> some View {
        Circle()
            .trim(from: 0, to: animationProgress)
            .stroke(Color.appMainBlue, lineWidth: Constants.Layout.lineWidth)
            .rotationEffect(.degrees(-90))
            .padding(Constants.Layout.lineWidth)
    }
    
    func animatedSegmentsLayer(in geometry: GeometryProxy) -> some View {
        ZStack {
            ForEach(Array(segments.enumerated().reversed()), id: \.offset) { index, segment in
                AnimatedSegmentView(
                    segment: segment,
                    segments: segments,
                    index: index,
                    animationProgress: animationProgress,
                    isSelected: selectedSegmentIndex == index
                )
                .onTapGesture {
                    withAnimation(.easeInOut(duration: Constants.Animation.selectionDuration)) {
                        selectedSegmentIndex = (selectedSegmentIndex == index) ? nil : index
                    }
                }
            }
        }
    }
}

// MARK: - Animated Segment View
struct AnimatedSegmentView: View {
    let segment: SegmentDataModel
    let segments: [SegmentDataModel]
    let index: Int
    let animationProgress: CGFloat
    let isSelected: Bool
    
    private var totalValue: CGFloat {
        segments.reduce(0) { $0 + $1.value }
    }
    
    private var lineWidth: CGFloat {
        isSelected ? Constants.Layout.lineWidth * 1.2 : Constants.Layout.lineWidth
    }
    
    private var animatedStartPercentage: CGFloat {
        (segments[0..<index].reduce(0) { $0 + $1.value } / totalValue) * animationProgress
    }
    
    private var animatedSegmentLength: CGFloat {
        (segment.value / totalValue) * animationProgress
    }
    
    var body: some View {
        Circle()
            .trim(from: animatedStartPercentage, to: animatedStartPercentage + animatedSegmentLength)
            .stroke(
                Color(hex: segment.color),
                style: StrokeStyle(
                    lineWidth: lineWidth,
                    lineCap: .butt
                )
            )
            .rotationEffect(.degrees(-90))
            .padding(Constants.Layout.lineWidth)
            .animation(.easeInOut(duration: Constants.Animation.selectionDuration), value: isSelected)
    }
}

// MARK: - Constants
private enum Constants {
    enum Layout {
        static let lineWidth: CGFloat = 30
        static let shadowRadius: CGFloat = 8
        static let strokeOpacity: Double = 0.3
        static let shadowOpacity: Double = 0.4
        static let titleFontSize: CGFloat = 20
        static let totalAmountFontSize: CGFloat = 24
    }
    
    enum Animation {
        static let selectionDuration: Double = 0.2
        static let mainDuration: Double = 1.2
    }
}
