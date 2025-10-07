//
//  InfoTooltipView.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 14.07.2025.
//

import UIKit

final class InfoTooltipView: UIView {
    // MARK: - UI Elements
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .white
        label.font = .systemFont(ofSize: Constants.fontSize, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Public Properties
    var text: String? {
        didSet {
            infoLabel.text = text
            constraintsUpdateIfNeeded()
        }
    }
    
    var isVisible: Bool = false {
        didSet {
            UIView.animate(withDuration: Constants.animateDuration) {
                self.alpha = self.isVisible ? 1 : .zero
            }
        }
    }
    
    // MARK: - Private Properties
    private var heightConstraint: NSLayoutConstraint?
    private var widthConstraint: NSLayoutConstraint?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func configure(with text: String) {
        self.text = text
    }
}

// MARK: - Private Methods
private extension InfoTooltipView {
    func setupUI() {
        isUserInteractionEnabled = false
        backgroundColor = .appCardAndField
        alpha = .zero
        layer.cornerRadius = Constants.cornerRadius
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = Constants.shadowOpacity
        layer.shadowOffset = Constants.shadowOffset
        layer.shadowRadius = Constants.shadowRadius
        layer.masksToBounds = false
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(infoLabel)
        
        heightConstraint = heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.minHeight)
        widthConstraint = widthAnchor.constraint(greaterThanOrEqualToConstant: Constants.minWidth)
        
        NSLayoutConstraint.activate([
            heightConstraint ?? NSLayoutConstraint(),
            widthConstraint ?? NSLayoutConstraint(),
            
            infoLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.padding),
            infoLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.padding),
            infoLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.padding),
            infoLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.padding)
        ])
    }
    
    func constraintsUpdateIfNeeded() {
        let maxWidth = UIScreen.main.bounds.width - Constants.maxWidthMargin
        let maxSize = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        
        let textSize = infoLabel.sizeThatFits(maxSize)
        
        let newWidth = min(max(Constants.minWidth, textSize.width + Constants.padding * 2), maxWidth)
        let newHeight = max(Constants.minHeight, textSize.height + Constants.padding * 2)
        
        widthConstraint?.constant = newWidth
        heightConstraint?.constant = newHeight
        layoutIfNeeded()
    }
}

// MARK: - Constants
private enum Constants {
    static let fontSize: CGFloat = 15
    static let cornerRadius: CGFloat = 12
    static let padding: CGFloat = 12
    static let shadowRadius: CGFloat = 6
    static let shadowOpacity: Float = 0.2
    static let shadowOffset: CGSize = .init(width: 0, height: 3)
    static let minHeight: CGFloat = 64
    static let minWidth: CGFloat = 240
    static let maxWidthMargin: CGFloat = 32
    static let animateDuration: TimeInterval = 0.3
}
