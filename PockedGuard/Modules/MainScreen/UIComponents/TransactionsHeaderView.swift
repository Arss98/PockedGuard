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
        label.font = .systemFont(ofSize: Constants.fontSize, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var percentageLabel: UILabel = {
        let label: UILabel = .init()
        label.textColor = .white
        label.font = .systemFont(ofSize: Constants.fontSize, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var amountLabel: UILabel = {
        let label: UILabel = .init()
        label.textColor = .white
        label.font = .systemFont(ofSize: Constants.fontSize, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var separatorView: UIView = {
        let view: UIView = .init()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .appSeparator
        view.alpha = .zero
        return view
    }()
    
    private lazy var separatorBottomConstraint: NSLayoutConstraint = {
        separatorView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: .zero)
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
    
    func updateUI(isExpanded: Bool) {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.separatorView.alpha = isExpanded ? 1 : .zero
            
            if isExpanded {
                self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            } else {
                self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner,
                                            .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            }
        }
    }
}

// MARK: - Private methods
private extension TransactionsHeaderView {
    func setupUI() {
        layer.cornerRadius = Constants.circleSize / 2
        layer.masksToBounds = true
        
        [circleView, titleLabel, percentageLabel, amountLabel, separatorView]
            .forEach { addSubview($0) }
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            circleView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.padding),
            circleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.padding),
            circleView.widthAnchor.constraint(equalToConstant: Constants.circleSize),
            circleView.heightAnchor.constraint(equalToConstant: Constants.circleSize),
            
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.padding),
            titleLabel.leadingAnchor.constraint(equalTo: circleView.trailingAnchor, constant: Constants.padding),
        
            amountLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.padding),
            amountLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.padding),
            
            percentageLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.padding),
            percentageLabel.trailingAnchor.constraint(equalTo: amountLabel.leadingAnchor,
                                                      constant: -Constants.padding),
            
            separatorView.topAnchor.constraint(equalTo: circleView.bottomAnchor, constant: Constants.padding),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.trailingPadding),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.padding),
            separatorView.heightAnchor.constraint(equalToConstant: Constants.lineHeight)
        ])
        
        separatorBottomConstraint.isActive = true
    }
}

// MARK: - Constants
private enum Constants {
    static let padding: CGFloat = 12
    static let trailingPadding: CGFloat = 38
    static let circleSize: CGFloat = 20
    static let fontSize: CGFloat = 16
    static let lineHeight: CGFloat = 1
    static let animationDuration: TimeInterval = 0.5
}
