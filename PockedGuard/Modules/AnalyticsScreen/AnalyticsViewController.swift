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
    
    private lazy var financeSegmentedControl: CustomSegmentedControl =  {
        let segmentedControl: CustomSegmentedControl = .init(items: Constants.SegmentedControl.financeItems,
                                                             fontSize: Constants.Text.fontSize,
                                                             segmentedBig: false)
        segmentedControl.backgroundColor = .appCardFieldSecondary
        return segmentedControl
    }()
    
    private lazy var barChartHostingController: UIHostingController<FinancialBarChart> = {
        let chartView: FinancialBarChart = .init()
        let hostingController: UIHostingController<FinancialBarChart> = .init(rootView: chartView)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear
        return hostingController
    }()
    
    private lazy var summaryCardStackView: UIStackView = {
        let stack: UIStackView = .init()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        return stack
    }()
    
    private lazy var lineChartHostingController: UIHostingController<FinancialLineChart> = {
        let chartView: FinancialLineChart = .init()
        let hostingController: UIHostingController<FinancialLineChart> = .init(rootView: chartView)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear
        return hostingController
    }()
    
    private lazy var lineChartContainerView: UIView = {
        let view: UIView = .init()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .appCardAndField
        view.layer.cornerRadius = Constants.Layout.cornerRadius
        return view
    }()
    
    
    private lazy var emptyAnalyticsContainerView: UIView = {
        let view: UIView = .init()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .appCardAndField
        view.layer.cornerRadius = Constants.Layout.cornerRadius
        view.layer.masksToBounds = true
        view.alpha = .zero
        return view
    }()
    
    private lazy var emptyAnalyticsLabel: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.textAlignment = .center
        label.text = L10n.Analytics.empty
        label.numberOfLines = .zero
        label.font = .systemFont(ofSize: Constants.Text.emptyLabelFontSize, weight: .regular)
        return label
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
        createSummaryCard()
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
            .distinctUntilChanged()
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
        
        financeSegmentedControl.selectedIndex
            .distinctUntilChanged()
            .compactMap { TransactionType(rawValue: Int16($0))}
            .bind(to: viewModel.input.transactionType)
            .disposed(by: disposeBag)
    }
    
    func setupOutputBindings() {
        viewModel.output.barChartTransaction
            .subscribe(with: self) { view, data in
                view.updateBarChartView(with: data)
            }
            .disposed(by: disposeBag)
        
        viewModel.output.lineChartTransaction
            .subscribe(with: self) { view, data in
                view.updateLineChartView(with: data)
            }
            .disposed(by: disposeBag)
        
        viewModel.output.summaryData
            .subscribe(with: self) { view, data in
                view.updateSummaryCard(with: data)
            }
            .disposed(by: disposeBag)
        
        viewModel.output.isShowEmptyView
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { view, isShow in
                view.showSummaryCard(isShow: isShow)
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - UI Setup
private extension AnalyticsViewController {
    func setupUI () {
        title = L10n.Common.analytics
        
        emptyAnalyticsContainerView.addSubview(emptyAnalyticsLabel)
        
        [barChartHostingController, lineChartHostingController].forEach { addChild($0) }
        [periodSegmentedControl, barChartHostingController.view, summaryCardStackView, lineChartContainerView,
         emptyAnalyticsContainerView].forEach { view.addSubview($0) }
        [lineChartHostingController.view, financeSegmentedControl].forEach { lineChartContainerView.addSubview($0) }
        
        barChartHostingController.didMove(toParent: self)
        lineChartHostingController.didMove(toParent: self)
    }
    
    func updateBarChartView(with data: [FinancialBarChartData]) {        
        barChartHostingController.rootView.data = data
        barChartHostingController.rootView.periodType = viewModel.input.selectedPeriod.value
    }
    
    func updateLineChartView(with data: [FinancialLineChartData]) {
        lineChartHostingController.rootView.data = data
        lineChartHostingController.rootView.periodType = viewModel.input.selectedPeriod.value
    }
    
    func updateSummaryCard(with summary: [AnalyticsSummary]) {
        summaryCardStackView.arrangedSubviews.enumerated().forEach { index, view in
            guard let card  = view as? FinancePercentageCard else { return }
            card.configure(with: summary[index])
        }
    }
    
    func showSummaryCard(isShow: Bool) {
        UIView.animate(withDuration: Constants.Animation.duration, delay: .zero, options: [.curveEaseInOut]) {
            self.summaryCardStackView.isHidden = !isShow
            self.emptyAnalyticsContainerView.alpha = isShow ? 0 : 1
            self.summaryCardStackView.alpha = isShow ? 1 : 0
            self.view.layoutIfNeeded()
        }
    }
    
    func createSummaryCard() {
        let cardSize: CGFloat = calculateSizeSummaryCard()
        FinancialCategory.allCases.forEach { [weak self] _ in
            guard let self else { return }
            let card: FinancePercentageCard = .init(size: cardSize)
            self.summaryCardStackView.addArrangedSubview(card)
        }
    }
    
    func calculateSizeSummaryCard() -> CGFloat {
        let count: Int = FinancialCategory.allCases.count
        guard count > 0 else { return 0 }
        
        let boundWidth: CGFloat = view.bounds.width
        let totalPadding: CGFloat = Constants.Layout.defaultPadding * 2
        let totalSpacing: CGFloat = Constants.Layout.summaryCardSpacing * CGFloat(count - 1)
        
        return (boundWidth - totalPadding - totalSpacing) / CGFloat(count)
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            periodSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                                        constant: Constants.Layout.defaultPadding / 2),
            periodSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                            constant: Constants.Layout.defaultPadding),
            periodSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                             constant: -Constants.Layout.defaultPadding),
            periodSegmentedControl.heightAnchor.constraint(equalToConstant: Constants.Layout.periodSegmentedControlHeight),
            
            barChartHostingController.view.topAnchor.constraint(equalTo: periodSegmentedControl.bottomAnchor,
                                                             constant: Constants.Layout.chartViewPadding),
            barChartHostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            barChartHostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            summaryCardStackView.topAnchor.constraint(equalTo: barChartHostingController.view.bottomAnchor,
                                                      constant: Constants.Layout.defaultPadding),
            summaryCardStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                          constant: Constants.Layout.defaultPadding),
            summaryCardStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                           constant: -Constants.Layout.defaultPadding),
            
            lineChartContainerView.topAnchor.constraint(equalTo: summaryCardStackView.bottomAnchor,
                                                        constant: Constants.Layout.defaultPadding),
            lineChartContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Layout.defaultPadding),
            lineChartContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Layout.defaultPadding),
            lineChartContainerView.bottomAnchor.constraint(equalTo: lineChartHostingController.view.bottomAnchor),
                                                        
            
            lineChartHostingController.view.topAnchor.constraint(equalTo: lineChartContainerView.topAnchor,
                                                                 constant: Constants.Layout.defaultPadding * 3),
            lineChartHostingController.view.leadingAnchor.constraint(equalTo: lineChartContainerView.leadingAnchor),
            lineChartHostingController.view.trailingAnchor.constraint(equalTo: lineChartContainerView.trailingAnchor),
            
            financeSegmentedControl.topAnchor.constraint(equalTo: lineChartContainerView.topAnchor,
                                                         constant: Constants.Layout.spacing),
            financeSegmentedControl.trailingAnchor.constraint(equalTo: lineChartContainerView.trailingAnchor,
                                                              constant: -Constants.Layout.defaultPadding),
            financeSegmentedControl.heightAnchor.constraint(equalToConstant: Constants.Layout.financeSegmentedControlHeight),
            financeSegmentedControl.widthAnchor.constraint(equalToConstant: Constants.Layout.financeSegmentedControlWidth),
            
            emptyAnalyticsContainerView.topAnchor.constraint(equalTo: barChartHostingController.view.bottomAnchor,
                                                      constant: Constants.Layout.defaultPadding),
            emptyAnalyticsContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                          constant: Constants.Layout.defaultPadding),
            emptyAnalyticsContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                           constant: -Constants.Layout.defaultPadding),
            emptyAnalyticsContainerView.bottomAnchor.constraint(equalTo: lineChartContainerView.topAnchor, constant: -Constants.Layout.defaultPadding),
            
            emptyAnalyticsLabel.centerYAnchor.constraint(equalTo: emptyAnalyticsContainerView.centerYAnchor),
            emptyAnalyticsLabel.leadingAnchor.constraint(equalTo: emptyAnalyticsContainerView.leadingAnchor,
                                                         constant: Constants.Layout.defaultPadding),
            emptyAnalyticsLabel.trailingAnchor.constraint(equalTo: emptyAnalyticsContainerView.trailingAnchor,
                                                          constant: -Constants.Layout.defaultPadding)
        ])
    }
}

// MARK: - Constants
private enum Constants {
    enum Layout {
        static let defaultPadding: CGFloat = 16
        static let summaryCardSpacing: CGFloat = 12
        static let chartViewPadding: CGFloat = 24
        static let spacing: CGFloat = 10
        static let periodSegmentedControlHeight: CGFloat = 44
        static let cornerRadius: CGFloat = 20
        static let financeSegmentedControlWidth: CGFloat = 144
        static let financeSegmentedControlHeight: CGFloat = 26
    }
    
    enum Text {
        static let fontSize: CGFloat = 10
        static let emptyLabelFontSize: CGFloat = 14
    }
    
    enum Animation {
        static let duration: TimeInterval = 0.3
    }
    
    enum SegmentedControl {
        static let financeItems: [String] = [
            L10n.Finance.expenses,
            L10n.Finance.income
        ]
        
        static let periodItems: [String] = [
            L10n.Period.day,
            L10n.Period.week,
            L10n.Period.month,
            L10n.Period.year
        ]
    }
}
