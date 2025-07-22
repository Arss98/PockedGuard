//
//  TransactionRowCell.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 16.07.2025.
//

import UIKit

final class TransactionRowCell: UITableViewCell {
    // MARK: - UI Elements
    private lazy var dotView: UIView = {
        let view: UIView = .init()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = Constants.Layout.dotSize / 2
        view.backgroundColor = .appForegroundSecondary
        return view
    }()
    
    private lazy var dateLabel: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.Text.fontSize, weight: .regular)
        label.textColor = .white
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.Text.fontSize, weight: .regular)
        label.textColor = .appForegroundSecondary
        label.textAlignment = .right
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private lazy var amountLabel: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.Text.fontSize, weight: .regular)
        label.textColor = .white
        return label
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dateLabel.text = nil
        descriptionLabel.text = nil
        amountLabel.text = nil
    }
    
    // MARK: - Configure
    func configure(with transaction: TransactionDomainModel) {
        dateLabel.text = DateFormatter.dateShort.string(from: transaction.date)
        descriptionLabel.text = transaction.notes
        amountLabel.text = String(format: "%.0f% ₽", transaction.amount)
    }
}

// MARK: - Private methods
private extension TransactionRowCell {
    func setupUI() {
        backgroundColor = .clear
        [dotView, dateLabel, descriptionLabel, amountLabel].forEach { addSubview($0) }
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            dotView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.Layout.padding),
            dotView.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            dotView.widthAnchor.constraint(equalToConstant: Constants.Layout.dotSize),
            dotView.heightAnchor.constraint(equalToConstant: Constants.Layout.dotSize),
            
            dateLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.Layout.padding),
            dateLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.Layout.padding),
            dateLabel.leadingAnchor.constraint(equalTo: dotView.trailingAnchor, constant: Constants.Layout.spacing),
            
            descriptionLabel.trailingAnchor.constraint(lessThanOrEqualTo: amountLabel.leadingAnchor, constant: -Constants.Layout.spacing),
            descriptionLabel.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: Constants.Layout.spacing),
            descriptionLabel.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            
            amountLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            amountLabel.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
        ])
    }
}

// MARK: - Constants
private enum Constants {
    enum Layout {
        static let dotSize: CGFloat = 8
        static let spacing: CGFloat = 8
        static let padding: CGFloat = 16
    }
    
    enum Text {
        static let fontSize: CGFloat = 16
    }
}
