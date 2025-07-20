//
//  CategoriesViewCell.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 11.07.2025.
//

import UIKit

final class CategoriesViewCell: UICollectionViewCell {
    // MARK: - UI elements
    private lazy var circleView: CircleView = {
        let circle: CircleView = .init()
        circle.translatesAutoresizingMaskIntoConstraints = false
        return circle
    }()
    
    private lazy var titleLabel: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.fontSize, weight: .regular)
        label.textColor = .white
        return label
    }()
    
    override var isSelected: Bool {
        didSet {
            updateSelection()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isSelected = false
        titleLabel.text = nil
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure
    func configure(title: String, color: String) {
        titleLabel.text = title
        circleView.strokeColor = UIColor(hexString: color) ?? .appSelectedBlue
    }
}

// MARK: - Private methods
private extension CategoriesViewCell {
    func setupUI() {
        backgroundColor = .appCardAndField
        layer.cornerRadius = Constants.cornerRadius
        contentView.layer.cornerRadius = Constants.cornerRadius
        contentView.layer.masksToBounds = true
        layer.masksToBounds = true
        [circleView, titleLabel].forEach { addSubview($0) }
    }
    
    func updateSelection() {
        UIView.animate(withDuration: Constants.animationDuration) { [weak self] in
            guard let self else { return }
            self.contentView.layer.borderWidth = self.isSelected ? Constants.borderWidth : .zero
            self.contentView.layer.borderColor = self.isSelected ? UIColor.appSelectedBlue.cgColor : UIColor.clear.cgColor
        }
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            circleView.topAnchor.constraint(equalTo: topAnchor,
                                            constant: Constants.padding),
            circleView.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                constant: Constants.padding),
            circleView.bottomAnchor.constraint(equalTo: bottomAnchor,
                                               constant: -Constants.padding),
            circleView.widthAnchor.constraint(equalToConstant: Constants.circleSize),
            circleView.heightAnchor.constraint(equalToConstant: Constants.circleSize),
            
            titleLabel.topAnchor.constraint(equalTo: topAnchor,
                                            constant: Constants.padding),
            titleLabel.leadingAnchor.constraint(equalTo: circleView.trailingAnchor,
                                                constant: Constants.spacing),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor,
                                               constant: -Constants.padding)
        ])
    }
}


// MARK: - Constants
private enum Constants {
    static let fontSize: CGFloat = 14
    static let padding: CGFloat = 12
    static let spacing: CGFloat = 10
    static let cornerRadius: CGFloat = 10
    static let circleSize: CGFloat = 20
    static let borderWidth: CGFloat = 1
    static let animationDuration: TimeInterval = 0.3
}
