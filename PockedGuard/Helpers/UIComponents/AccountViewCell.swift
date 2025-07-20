//
//  AccountViewCell.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 14.07.2025.
//

import RxSwift
import RxCocoa

final class AccountViewCell: UICollectionViewCell {
    // MARK: - UI elements
    private lazy var titleLabel: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: Constants.titleFontSize, weight: .regular)
        label.textAlignment = .left
        return label
    }()
    
    private lazy var amountLabel: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: Constants.amountFontSize, weight: .regular)
        label.textAlignment = .left
        return label
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            updateSelection()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        amountLabel.text = nil
    }
    
    // MARK: - Configure
    func configure(title: String, amount: Double) {
        titleLabel.text = title
        amountLabel.text = "\(Int(amount)) ₽"
    }
}

// MARK: - Private methods
private extension AccountViewCell {
    func setupUI() {
        backgroundColor = .appCardAndField
        layer.cornerRadius = Constants.cornerRadius
        [titleLabel, amountLabel].forEach { addSubview($0) }
    }
    
    func updateSelection() {
        UIView.animate(withDuration: Constants.animationDuration) { [weak self] in
            guard let self else { return }
            self.backgroundColor = self.isSelected ? .appMainBlue : .appCardAndField
        }
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor,
                                            constant: Constants.verticalPadding),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                constant: Constants.horizontalPadding),
            
            amountLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,
                                             constant: Constants.spacing),
            amountLabel.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                 constant: Constants.horizontalPadding),
            amountLabel.bottomAnchor.constraint(equalTo: bottomAnchor,
                                                constant: -Constants.verticalPadding)
        ])
    }
}

// MARK: - Constants
private enum Constants {
    static let titleFontSize: CGFloat = 14
    static let amountFontSize: CGFloat = 16
    static let cornerRadius: CGFloat = 10
    static let verticalPadding: CGFloat = 8
    static let horizontalPadding: CGFloat = 12
    static let spacing: CGFloat = 2
    static let financeCardWidth: CGFloat = 160
    static let animationDuration: TimeInterval = 0.3
}

