//
//  TemplatesInfoView.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 14.07.2025.
//

import UIKit

final class TemplatesInfoView: UIView {
    // MARK: - UI Elements
    private lazy var infoLabel: UILabel = {
        let label: UILabel = .init()
        label.numberOfLines = .zero
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = .Localized.Add.templatesInfo.localized
        label.font = .systemFont(ofSize: Constants.fontSize, weight: .regular)
        return label
    }()
    
    var isVisible: Bool = false {
        didSet {
            UIView.animate(withDuration: Constants.animateDuration) {
                self.alpha = self.isVisible ? 1 : .zero
            }
        }
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    private func setupUI() {
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
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: Constants.height),
            widthAnchor.constraint(equalToConstant: Constants.width),
            
            infoLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.padding),
            infoLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.padding),
            infoLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.padding),
            infoLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.padding)
        ])
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
    static let height: CGFloat = 64
    static let width: CGFloat = 240
    static let animateDuration: TimeInterval = 0.3
}
