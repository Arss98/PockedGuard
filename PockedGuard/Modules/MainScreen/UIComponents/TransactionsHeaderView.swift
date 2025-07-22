//
//  TransactionsHeaderView.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 11.06.2025.
//

import RxSwift
import RxCocoa

final class TransactionsHeaderView: UITableViewHeaderFooterView {
    // MARK: - UI Elements
   private lazy var circleView: CircleView = {
        let circleView: CircleView = .init()
        circleView.translatesAutoresizingMaskIntoConstraints = false
        return circleView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label: UILabel = .init()
        label.textColor = .white
        label.font = .systemFont(ofSize: Constants.Text.titleFontSize, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var percentageLabel: UILabel = {
        let label: UILabel = .init()
        label.textColor = .appForegroundSecondary
        label.font = .systemFont(ofSize: Constants.Text.fontSize, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var amountLabel: UILabel = {
        let label: UILabel = .init()
        label.textColor = .appForegroundSecondary
        label.font = .systemFont(ofSize: Constants.Text.fontSize, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK: - Init
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure
    func configure(categoryName: String, percentage: String, amount: Double, color: String?) {
        titleLabel.text = categoryName
        amountLabel.text = String(format: "%.0f% ₽", amount)
        percentageLabel.text = percentage
        
        if let color = color {
            circleView.strokeColor = UIColor(hexString: color) ?? .appMainBlue
        }
    }
}

// MARK: - Private methods
private extension TransactionsHeaderView {
    func setupUI() {
        [circleView, titleLabel, percentageLabel, amountLabel]
            .forEach { addSubview($0) }
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            circleView.centerYAnchor.constraint(equalTo: centerYAnchor),
            circleView.leadingAnchor.constraint(equalTo: leadingAnchor),
            circleView.widthAnchor.constraint(equalToConstant: Constants.Layout.circleSize),
            circleView.heightAnchor.constraint(equalToConstant: Constants.Layout.circleSize),
            
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: circleView.trailingAnchor, constant: Constants.Layout.padding),
        
            amountLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            amountLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            percentageLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            percentageLabel.trailingAnchor.constraint(equalTo: amountLabel.leadingAnchor, constant: -Constants.Layout.padding)
        ])
    }
}

// MARK: - Constants
private enum Constants {
    enum Layout {
        static let padding: CGFloat = 12
        static let circleSize: CGFloat = 20
    }
    
    enum Text {
        static let titleFontSize: CGFloat = 18
        static let fontSize: CGFloat = 16
    }
}
