//
//  DotsView.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 21.11.2025.
//

import UIKit

final class DotsView: UIView {
    // MARK: - UI elements
    private lazy var dotsStack: UIStackView = {
        let stack: UIStackView = .init()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = Constants.Layout.dotSpacing
        stack.distribution = .equalSpacing
        return stack
    }()
    
    // MARK: - Public API
    var filledCount: Int = 0 {
        didSet { updateAppearance(animated: false) }
    }
    
    var isErrorState: Bool = false {
        didSet { updateAppearance(animated: true) }
    }
    
    // MARK: - Private properties
    private var dotViews: [UIView] = []
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        configureDots()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public methods
    func shake() {
        dotViews.forEach { shakeAnimation(for: $0) }
    }
}

// MARK: - UI setting
private extension DotsView {
    func setupUI() {
        addSubview(dotsStack)
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dotsStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            dotsStack.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func configureDots() {
        for _ in 0..<Constants.Layout.dotCount {
            let dot: UIView = .init()
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.widthAnchor.constraint(equalToConstant: Constants.Layout.dotSize).isActive = true
            dot.heightAnchor.constraint(equalToConstant: Constants.Layout.dotSize).isActive = true
            dot.layer.cornerRadius = Constants.Layout.dotSize / 2
            dot.backgroundColor = .appCardAndField
            dot.layer.borderWidth = .zero
            
            dotsStack.addArrangedSubview(dot)
            dotViews.append(dot)
        }
    }
    
    func updateAppearance(animated: Bool) {
        let updateBlock: () -> () = { [weak self] in
            guard let self = self else { return }
            self.resetBorders()
            
            if self.isErrorState {
                self.dotViews.forEach {
                    $0.backgroundColor = .clear
                    $0.layer.borderColor = UIColor.appErrorRed.cgColor
                    $0.layer.borderWidth = Constants.Layout.errorBorderWidth
                }
            } else {
                self.dotViews.enumerated().forEach { index, dot in
                    let isFilled = index < self.filledCount
                    dot.backgroundColor = isFilled ? .appMainBlue : .appCardAndField
                }
            }
        }
        
        if animated {
            UIView.animate(
                withDuration: Constants.Animation.defaultDuration,
                delay: .zero,
                usingSpringWithDamping: Constants.Animation.usingSpringWithDamping,
                initialSpringVelocity: Constants.Animation.initialSpringVelocity,
                options: .curveEaseOut
            ) {
                updateBlock()
                self.layoutIfNeeded()
            }
        } else {
            updateBlock()
        }
    }
    
    func shakeAnimation(for view: UIView) {
        let animation: CAKeyframeAnimation = .init(keyPath: Constants.Animation.shakeKeyPath)
        animation.timingFunctions = [CAMediaTimingFunction(name: .linear)]
        animation.duration = Constants.Animation.duration
        animation.values = Constants.Animation.shakeValue
        
        view.layer.add(animation, forKey: Constants.Animation.shakeKey)
    }
    
    func resetBorders() {
        dotViews.forEach {
            $0.layer.borderColor = nil
            $0.layer.borderWidth = .zero
            $0.backgroundColor = .appCardAndField
        }
    }
}

// MARK: - Constants
private enum Constants {
    enum Layout {
        static let dotSize: CGFloat = 22
        static let dotCount: Int = 4
        static let dotSpacing: CGFloat = 16
        static let errorBorderWidth: CGFloat = 2
    }
    
    enum Animation {
        static let defaultDuration: TimeInterval = 0.35
        static let duration: TimeInterval = 0.6
        static let usingSpringWithDamping: CGFloat = 0.8
        static let initialSpringVelocity: CGFloat = 0.5
        static let shakeValue: [CGFloat] = [-12, 12, -10, 10, -6, 6, -3, 3, 0]
        static let shakeKey: String = "shake"
        static let shakeKeyPath: String = "transform.translation.x"
    }
}
