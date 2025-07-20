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
        view.layer.cornerRadius = Constants.dotSize / 2
        view.backgroundColor = .appForegroundSecondary
        return view
    }()
    
    private lazy var dateLabel: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.fontSize, weight: .regular)
        label.textColor = .white
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.fontSize, weight: .regular)
        label.textColor = .appForegroundSecondary
        label.textAlignment = .right
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private lazy var amountLabel: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.fontSize, weight: .regular)
        label.textColor = .white
        return label
    }()
    
    private lazy var dotBottomConstraint: NSLayoutConstraint = {
        dotView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.bottomPadding)
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
        layer.cornerRadius = .zero
        dateLabel.text = nil
        descriptionLabel.text = nil
        amountLabel.text = nil
        dotBottomConstraint.constant = -Constants.bottomPadding
    }
    
    // MARK: - Configure
    func configure(with transaction: TransactionDomainModel) {
        dateLabel.text = DateFormatter.dateShort.string(from: transaction.date)
        descriptionLabel.text = transaction.notes
        amountLabel.text = String(format: "%.0f% ₽", transaction.amount)
    }
    
    func updateUI(isLastCell: Bool = false) {
        if isLastCell {
            dotBottomConstraint.constant = -Constants.padding
            layer.cornerRadius = Constants.cornerRadius
            layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
    }
}

// MARK: - Private methods
private extension TransactionRowCell {
    func setupUI() {
        backgroundColor = .appCardAndField
        layer.masksToBounds = false
        [dotView, dateLabel, descriptionLabel, amountLabel].forEach { addSubview($0) }
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([            
            dotView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.leadingPadding),
            dotView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.padding),
            dotView.widthAnchor.constraint(equalToConstant: Constants.dotSize),
            dotView.heightAnchor.constraint(equalToConstant: Constants.dotSize),
            
            dateLabel.leadingAnchor.constraint(equalTo: dotView.trailingAnchor,
                                               constant: Constants.spacing),
            dateLabel.centerYAnchor.constraint(equalTo: dotView.centerYAnchor),
            
            descriptionLabel.trailingAnchor.constraint(lessThanOrEqualTo: amountLabel.leadingAnchor,
                                                               constant: -Constants.spacing),
            descriptionLabel.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor,
                                                      constant: Constants.spacing),
            descriptionLabel.centerYAnchor.constraint(equalTo: dotView.centerYAnchor),
            
            amountLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.trailingPadding),
            amountLabel.centerYAnchor.constraint(equalTo: dotView.centerYAnchor),
        ])
        
        dotBottomConstraint.isActive = true
    }
}

// MARK: - Constants
private enum Constants {
    static let dotSize: CGFloat = 8
    static let fontSize: CGFloat = 16
    static let spacing: CGFloat = 8
    static let bottomPadding: CGFloat = 2
    static let padding: CGFloat = 16
    static let leadingPadding: CGFloat = 38
    static let trailingPadding: CGFloat = 12
    static let cornerRadius: CGFloat = 10
}
