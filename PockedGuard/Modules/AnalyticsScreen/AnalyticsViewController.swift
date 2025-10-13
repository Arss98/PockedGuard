//
//  AnalyticsViewController.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 08.03.2025.
//

import RxSwift
import RxCocoa
import SwiftUI

final class AnalyticsViewController: BaseViewController {
    // MARK: - UI Elements
    private lazy var periodSegmentedControl: CustomSegmentedControl = .init(items: Constants.SegmentedControl.periodItems)
    
    private lazy var chartHostingController: UIHostingController<FinancialBarChart> = {
        let chartView: FinancialBarChart = .init(data: [], periodType: .day())
        let hostingController: UIHostingController<FinancialBarChart> = .init(rootView: chartView)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear
        return hostingController
    }()
    
    // MARK: - Private properties
    private let viewModel: AnalyticsViewModelProtocol

    // MARK: - Init
    init(viewModel: AnalyticsViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setConstraints()
        setupBindings()
    }
}

// MARK: - Private methods
private extension AnalyticsViewController {
    func setupBindings() {
        setupInputBinings()
        setupOutputBindings()
    }
    
    func setupInputBinings() {
        periodSegmentedControl.selectedIndex
            .map { index -> PeriodType in
                switch index {
                case 0: return .day()
                case 1: return .week()
                case 2: return .month()
                case 3: return .year()
                default: return .day()
                }
            }
            .bind(to: viewModel.input.selectedPeriod)
            .disposed(by: disposeBag)
    }
    
    func setupOutputBindings() {
        viewModel.output.barChartTransaction
            .subscribe(onNext: { [weak self] data in
                self?.updateChartView(with: data)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - UI Setup
private extension AnalyticsViewController {
    func setupUI () {
        title = .Localized.Common.analytics.localized
        
        addChild(chartHostingController)
        [periodSegmentedControl, chartHostingController.view].forEach { view.addSubview($0) }
        
        chartHostingController.didMove(toParent: self)
    }
    
    func updateChartView(with data: [FinancialBarChartData]) {
        let currendPeriod: PeriodType = viewModel.input.selectedPeriod.value
        let newChart: FinancialBarChart = .init(data: data, periodType: currendPeriod)
        chartHostingController.rootView = newChart
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            periodSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                                        constant: Constants.Layout.defaultPadding / 2),
            periodSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                            constant: Constants.Layout.defaultPadding),
            periodSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                             constant: -Constants.Layout.defaultPadding),
            
            chartHostingController.view.topAnchor.constraint(equalTo: periodSegmentedControl.bottomAnchor,
                                                             constant: Constants.Layout.chartViewPadding),
            chartHostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chartHostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
        ])
    }
}


// MARK: - Constants
private enum Constants {
    enum Layout {
        static let defaultPadding: CGFloat = 16
        static let chartViewPadding: CGFloat = 24
    }
    
    enum SegmentedControl {
        static let financeItems: [String] = [
            .Localized.Common.expenses.localized,
            .Localized.Common.income.localized
        ]
        
        static let periodItems: [String] = [
            .Localized.Period.day.localized,
            .Localized.Period.week.localized,
            .Localized.Period.month.localized,
            .Localized.Period.year.localized
        ]
    }
}
