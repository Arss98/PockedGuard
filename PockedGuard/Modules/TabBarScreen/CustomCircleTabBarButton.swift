//
//  CustomCircleTabBarButton.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 09.03.2025.
//

import UIKit

final class CustomCircleTabBarButton: UIButton {
    private lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer: CAGradientLayer = .init()
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = constants.cornerRadius
        gradientLayer.colors = [UIColor(resource: .appGradientOne).cgColor, UIColor(resource: .appGradientTwo).cgColor]
        gradientLayer.startPoint = constants.gradientStartPoint
        gradientLayer.endPoint = constants.gradientEndPoint
        
        return gradientLayer
    }()
    
    private let constants: Constants = .init()
    
    init() {
        super.init(frame: .zero)
        setupUI()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}

// MARK: - Private methods
private extension CustomCircleTabBarButton {
    func setupUI() {
        setImage(.addIcon, for: .normal)
        tintColor = .white
        translatesAutoresizingMaskIntoConstraints = false
        layer.borderWidth = constants.borderWidth
        layer.borderColor = UIColor(resource: .appCardAndField).cgColor
        layer.cornerRadius = constants.cornerRadius
        layer.insertSublayer(gradientLayer, at: .zero)
        
        guard let imageView else { return }
        bringSubviewToFront(imageView)
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: constants.buttonSize),
            heightAnchor.constraint(equalToConstant: constants.buttonSize)
        ])
    }
}

// MARK: - Constants
private struct Constants {
    let gradientStartPoint: CGPoint = .init(x: 0.25, y: 0.25)
    let gradientEndPoint: CGPoint = .init(x: 0.75, y: 0.75)
    let borderWidth: CGFloat = 4
    let cornerRadius: CGFloat = 33
    let buttonSize: CGFloat = 66
}
