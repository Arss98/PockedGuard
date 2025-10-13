//
//  FinancialBarChart.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 12.10.2025.
//

import SwiftUI
import Charts

struct FinancialBarChart: View {
    let data: [FinancialBarChartData]
    let periodType: PeriodType
    
    var body: some View {
        VStack(spacing: Constants.Layout.defaultSpacing / 2) {
            FinancialBarChartView(data: data, periodType: periodType)
            xAxisDates
            categoryLegend
        }
        .frame(maxHeight: Constants.Layout.maxHeight)
        .background(.appCardAndField)
        .clipShape(.rect(cornerRadius: Constants.Layout.cornerRadius))
        .padding(.horizontal)
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
                        .font(.system(size: Constants.Text.datefontSize, weight: .regular))
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
    let data: [FinancialBarChartData]
    let periodType: PeriodType
    
    // MARK: - Private properties
    @State private var animationProgress: CGFloat = 0.0
    
    private var displayDates: [Date] {
        periodType.getDisplayDates()
    }
    
    private var xAxisDomain: ClosedRange<Date> {
        guard let firstDate = displayDates.first,
              let lastDate = displayDates.last else {
            let defaultDate: Date = .init()
            return defaultDate...defaultDate
        }
        return firstDate...lastDate
    }
    
    private var yAxisDomain: ClosedRange<Double> {
        let maxAmount = data.map { $0.amount }.max() ?? .zero
        return .zero...(maxAmount * 1.1)
    }
    
    var body: some View {
        Chart(data) { dataPoint in
            BarMark(
                x: .value("Период", dataPoint.period, unit: periodType.xAxisStride),
                y: .value("Сумма", animationProgress * dataPoint.amount)
            )
            .foregroundStyle(dataPoint.category.color)
            .position(by: .value("Категория", dataPoint.category.localizedName),
                      axis: .horizontal
            )
        }
        .chartYScale(domain: yAxisDomain)
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .padding(.horizontal, Constants.Layout.defaultPadding / 2)
        .padding(.top, Constants.Layout.defaultPadding * 2)
        .onAppear {
            withAnimation(.easeInOut(duration: Constants.Animation.duration)) {
                animationProgress = 1.0
            }
        }
        .onChange(of: periodType) { _, _ in
            animationProgress = 0.0
            withAnimation(.easeInOut(duration: Constants.Animation.duration)) {
                animationProgress = 1.0
            }
        }
    }
}

#Preview {
    FinancialBarChart(data: FinancialBarChartData.mockData, periodType: .day(start: Date()))
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
        static let datefontSize: CGFloat = 12
        static let categoryFontSize: CGFloat = 14
    }
    
    enum Animation {
        static let duration: TimeInterval = 0.8
    }
}
