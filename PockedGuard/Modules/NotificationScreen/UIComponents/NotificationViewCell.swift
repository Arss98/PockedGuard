//
//  NotificationViewCell.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 25.06.2025.
//

import RxSwift
import RxCocoa

final class NotificationViewCell: UICollectionViewCell {
    // MARK: - UI Elements
    private lazy var titleLabel: UILabel = {
        let label: UILabel = .init()
        label.font = .systemFont(ofSize: Constants.titleLabelFontSize, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label: UILabel = .init()
        label.font = .systemFont(ofSize: Constants.descriptionLabelFontSize, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .appForegroundSecondary
        return label
    }()
    
    private lazy var switchView: UISwitch = {
        let switchView: UISwitch = .init()
        switchView.translatesAutoresizingMaskIntoConstraints = false
        switchView.onTintColor = .appSelectedBlue
        switchView.tintColor = .appCardFieldSecondary
        switchView.thumbTintColor = .white
        return switchView
    }()
    
    // MARK: - Properties
    private var disposeBag: DisposeBag = .init()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public method
    func configure(title: String, description: String, isActive: Bool, onSwitchChange: ((Bool) -> Void)? = nil) {
        titleLabel.text = title
        descriptionLabel.text = description
        switchView.setOn(isActive, animated: true)
        
        if let onSwitchChange {
            switchView.rx.isOn
                .skip(1)
                .debounce(.milliseconds(200), scheduler: MainScheduler.instance)
                .subscribe(onNext: { onSwitchChange($0) })
                .disposed(by: disposeBag)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = .init()
        switchView.setOn(false, animated: true)
        titleLabel.text = nil
        descriptionLabel.text = nil
    }
}

// MARK: - Private methods
private extension NotificationViewCell {
    func setupUI() {
        backgroundColor = .appCardAndField
        layer.cornerRadius = Constants.cornerRadius
        layer.masksToBounds = true
        
        [titleLabel, descriptionLabel, switchView].forEach { addSubview($0) }
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.titleTopPadding),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.defaultPadding),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.spacing),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.defaultPadding),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.defaultPadding),
            descriptionLabel.trailingAnchor.constraint(equalTo: switchView.leadingAnchor, constant: -Constants.defaultPadding),
            
            switchView.centerYAnchor.constraint(equalTo: centerYAnchor),
            switchView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.defaultPadding)
        ])
    }
}

// MARK: - Constants
private enum Constants {
    static let titleLabelFontSize: CGFloat = 16
    static let descriptionLabelFontSize: CGFloat = 12
    static let cornerRadius: CGFloat = 12
    static let defaultPadding: CGFloat = 16
    static let spacing: CGFloat = 6
    static let titleTopPadding: CGFloat = 12
    static let switchWidth: CGFloat = 52
}
