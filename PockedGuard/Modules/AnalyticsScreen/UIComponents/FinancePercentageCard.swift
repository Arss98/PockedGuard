//
//  FinancePercentageCard.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 14.10.2025.
//

import UIKit

final class FinancePercentageCard: UIView {
    // MARK: - UI Elements
    private lazy var titleLabel: UILabel = {
        let label: UILabel = .init()
        label.textColor = .white
        label.font = .systemFont(ofSize: Constants.Text.titleFontSize, weight: .regular)
        label.numberOfLines = Constants.Layout.numberOfLines
        return label
    }()
    
    private lazy var percentageLabel: UILabel = {
        let label: UILabel = .init()
        label.textColor = .appSelectedBlue
        label.font = .systemFont(ofSize: Constants.Text.percentageFontSize, weight: .regular)
        label.text =  "0%"
        return label
    }()
    
    private lazy var ratingLabel: UILabel = {
        let label: UILabel = .init()
        label.textColor = .white
        label.font = .systemFont(ofSize: Constants.Text.ratingFontSize, weight: .regular)
        label.numberOfLines = Constants.Layout.numberOfLines
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stack: UIStackView = .init(arrangedSubviews: [titleLabel, percentageLabel, ratingLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .equalSpacing
        return stack
    }()
    
    // MARK: - Private properties
    private let cardSize: CGFloat
    
    // MARK: - Init
    init(size: CGFloat) {
        self.cardSize = size
        super.init(frame: .zero)
        setupUI()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public methods
    func configure(with summary: AnalyticsSummary, animated: Bool = true) {
        titleLabel.text = getTitle(type: summary.type, percentage: summary.percentageChange)
        percentageLabel.text = abs(summary.percentageChange).description.appending("%")
        ratingLabel.text = summary.rating.message
        
        percentageLabel.textColor = summary.rating.color
    }
}

// MARK: - Private methods
private extension FinancePercentageCard {
    func setupUI() {
        backgroundColor = .appCardAndField
        layer.cornerRadius = Constants.Layout.cornerRadius
        translatesAutoresizingMaskIntoConstraints = false
        
        [stackView].forEach { addSubview($0) }
    }
    
    func getTitle(type: FinancialCategory, percentage: Int) -> String {
        switch type {
        case .expense:
            return percentage <= 0 ?
                .Localized.Analytics.expensesDecreased.localized : .Localized.Analytics.expensesIncreased.localized
        case .income:
            return percentage >= 0 ?
                .Localized.Analytics.incomeIncreased.localized : .Localized.Analytics.incomeDecreased.localized
        case .loss: return percentage <= 0 ?
                .Localized.Analytics.lossDecreased.localized : .Localized.Analytics.lossIncreased.localized
        }
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: cardSize),
            heightAnchor.constraint(equalToConstant: cardSize),
            
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.Layout.padding),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.Layout.padding),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.Layout.padding),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.Layout.padding)
        ])
    }
}

// MARK: - Constants
private enum Constants {
    enum Text {
        static let titleFontSize: CGFloat = 11
        static let ratingFontSize: CGFloat = 12
        static let percentageFontSize: CGFloat = 30
    }
    
    enum Layout {
        static let numberOfLines: Int = 2
        static let cornerRadius: CGFloat = 14
        static let padding: CGFloat = 10
    }
}
