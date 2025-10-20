//
//  FinancialLineChart.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 13.10.2025.
//
//
//  FinancialLineChart.swift
//  PockedGuard
//

import SwiftUI
import Charts

struct FinancialLineChart: View {
    // MARK: - Public properties
    var data: [FinancialLineChartData]
    var periodType: PeriodType
    
    // MARK: - Private properties
    @State private var animationProgress: CGFloat = 0.0
    
    // MARK: - Init
    init(data: [FinancialLineChartData] = [], periodType: PeriodType = .day()) {
        self.data = data
        self.periodType = periodType
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: Constants.Layout.defaultSpacing / 2) {
            FinancialLineChartView(
                data: data,
                periodType: periodType,
                animationProgress: animationProgress
            )
            xAxisDates
        }
        .frame(maxHeight: Constants.Layout.maxHeight)
        .background(.clear)
        .onChange(of: data) { _, _ in
            animationProgress = 0.0
            withAnimation(.easeInOut(duration: Constants.Animation.duration)) {
                animationProgress = 1.0
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: Constants.Animation.duration)) {
                animationProgress = 1.0
            }
        }
    }
}

// MARK: - UI Setup
private extension FinancialLineChart {
    var xAxisDates: some View {
        HStack {
            ForEach(periodType.getDisplayDates(), id: \.self) { date in
                VStack(spacing: .zero) {
                    Rectangle()
                        .foregroundStyle(.clear)
                        .frame(height: Constants.Layout.lineHeight)
                    
                    Text(periodType.formatDateForXAxis(date))
                        .font(.system(size: Constants.Text.dateFontSize, weight: .regular))
                        .foregroundStyle(.appForegroundSecondary)
                }
            }
        }
        .padding()
        .padding(.leading)
    }
}

// MARK: - LineChart View
private struct FinancialLineChartView: View {
    // MARK: - Public properties
    var data: [FinancialLineChartData]
    var periodType: PeriodType
    let animationProgress: CGFloat

    // MARK: - Body
    var body: some View {
        Chart {
            ForEach(data) { dataPoint in
                LineMark(
                    x: .value("Период", dataPoint.date, unit: periodType.xAxisStride),
                    y: .value("Сумма", animationProgress * dataPoint.amount)
                )
                .foregroundStyle(.appMainBlue)
                .lineStyle(StrokeStyle(lineWidth: Constants.Layout.lineWidth, lineCap: .round, lineJoin: .round))
                .interpolationMethod(.catmullRom)
                .opacity(animationProgress == 0 ? 0 : 1)
            }
        }
        .chartYScale(domain: yAxisDomain)
        .chartXAxis(.hidden)
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisValueLabel {
                    if let amount = value.as(Int.self) {
                        Text("\(amount / 1000)к")
                            .font(.system(size: Constants.Text.dateFontSize))
                            .foregroundStyle(.appForegroundSecondary)
                    }
                }
            }
        }
        .padding(.horizontal, Constants.Layout.defaultPadding / 2)
    }
}

// MARK: - Private methods and compudet properties
private extension FinancialLineChartView {
    var displayDates: [Date] {
        periodType.getDisplayDates()
    }
    
    var yAxisDomain: ClosedRange<Double> {
        let maxAmount: Double = data.map { $0.amount }.max() ?? .zero
        
        guard maxAmount > 0 else { return 0...10_000}
        
        let roundedMax: Double = roundUpToNiceNumber(maxAmount)
        
        return 0...roundedMax
    }
    
    func roundUpToNiceNumber(_ value: Double) -> Double {
        let orderOfMagnitude: Double = pow(10, floor(log10(value)))
        let scaledValue: Double = value / orderOfMagnitude
        
        let niceNumbers: [Double] = [1, 2, 5, 10]
        let niceScaledMax: Double = niceNumbers.first(where: { $0 >= scaledValue }) ?? 10
        
        return niceScaledMax * orderOfMagnitude
    }
}

// MARK: - Constants
private enum Constants {
    enum Layout {
        static let defaultPadding: CGFloat = 16
        static let defaultSpacing: CGFloat = 8
        static let spacing: CGFloat = 10
        static let lineWidth: CGFloat = 3
        static let maxHeight: CGFloat = 220
        static let lineHeight: CGFloat = 1
    }
    
    enum Text {
        static let dateFontSize: CGFloat = 12
    }
    
    enum Animation {
        static let duration: TimeInterval = 0.8
    }
}
