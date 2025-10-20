//
//  FinancialBarChart.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 12.10.2025.
//

import SwiftUI
import Charts

struct FinancialBarChart: View {
    // MARK: - Public properties
    var data: [FinancialBarChartData]
    var periodType: PeriodType
    
    // MARK: - Private properties
    @State private var animationProgress: CGFloat = 0.0

    // MARK: - Init
    init(data: [FinancialBarChartData] = [], periodType: PeriodType = .day()) {
        self.data = data
        self.periodType = periodType
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: Constants.Layout.defaultSpacing / 2) {
            FinancialBarChartView(
                data: data,
                periodType: periodType,
                animationProgress: animationProgress
            )
            xAxisDates
            categoryLegend
        }
        .frame(maxHeight: Constants.Layout.maxHeight)
        .background(.appCardAndField)
        .clipShape(.rect(cornerRadius: Constants.Layout.cornerRadius))
        .padding(.horizontal)
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
private extension FinancialBarChart {
    var xAxisDates: some View {
        HStack(spacing: Constants.Layout.defaultSpacing / 2) {
            ForEach(periodType.getDisplayDates(), id: \.self) { date in
                VStack(spacing: Constants.Layout.defaultSpacing / 2) {
                    Rectangle()
                        .foregroundStyle(.appForegroundSecondary)
                        .frame(height: Constants.Layout.lineHeight)
                    
                    Text(periodType.formatDateForXAxis(date))
                        .font(.system(size: Constants.Text.dateFontSize, weight: .regular))
                        .foregroundStyle(.appForegroundSecondary)
                }
            }
        }
        .padding(.horizontal, Constants.Layout.spacing)
    }
    
    var categoryLegend: some View {
        HStack {
            ForEach(FinancialCategory.allCases, id: \.self) { category in
                HStack(spacing: Constants.Layout.defaultSpacing) {
                    Circle()
                        .foregroundStyle(category.color)
                        .frame(width: Constants.Layout.dotViewSize, height: Constants.Layout.dotViewSize)
                    
                    Text(category.localizedName)
                        .font(.system(size: Constants.Text.categoryFontSize, weight: .regular))
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, Constants.Layout.spacing)
            }
        }
        .padding(.top, Constants.Layout.defaultPadding / 2)
        .padding(.bottom)
    }
}

// MARK: - BarChart
private struct FinancialBarChartView: View {
    // MARK: - Public properties
    var data: [FinancialBarChartData]
    var periodType: PeriodType
    let animationProgress: CGFloat
    
    // MARK: - Private properties
    private var displayDates: [Date] {
        periodType.getDisplayDates()
    }
    
    private var yAxisDomain: ClosedRange<Double> {
        let maxAmount: Double = data.map { $0.amount }.max() ?? .zero
        return .zero...maxAmount
    }
    
    // MARK: - Body
    var body: some View {
        Chart(data) { dataPoint in
            BarMark(
                x: .value("Период", dataPoint.period, unit: periodType.xAxisStride),
                yStart: .value("Сумма start", 0),
                yEnd: .value("Сумма end", animationProgress * dataPoint.amount)
            )
            .foregroundStyle(dataPoint.category.color)
            .position(by: .value("Категория", dataPoint.category.localizedName),
                      axis: .horizontal
            )
            .opacity(animationProgress == 0 ? 0 : 1)
        }
        .chartYScale(domain: yAxisDomain)
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .padding(.horizontal, Constants.Layout.defaultPadding / 2)
        .padding(.top, Constants.Layout.defaultPadding * 2)

    }
}

// MARK: - Constants
private enum Constants {
    enum Layout {
        static let defaultPadding: CGFloat = 16
        static let defaultSpacing: CGFloat = 8
        static let spacing: CGFloat = 10
        static let lineHeight: CGFloat = 1
        static let dotViewSize: CGFloat = 10
        static let cornerRadius: CGFloat = 20
        static let maxHeight: CGFloat = 220
        static let xAxisOffsetEnd: CGFloat = 36
    }
    
    enum Text {
        static let dateFontSize: CGFloat = 12
        static let categoryFontSize: CGFloat = 14
    }
    
    enum Animation {
        static let duration: TimeInterval = 0.8
    }
}
