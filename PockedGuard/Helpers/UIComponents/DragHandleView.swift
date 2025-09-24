//
//  DragHandleView.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 20.09.2025.
//

import UIKit

final class DragHandleView: UIView {
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        backgroundColor = .appForegroundSecondary
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = Constants.dragHandleHeight / 2
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: Constants.dragHandleHeight),
            widthAnchor.constraint(equalToConstant: Constants.dragHandleWidth)
        ])
    }
}

// MARK: - Constants
private enum Constants {
    static let dragHandleHeight: CGFloat = 5
    static let dragHandleWidth: CGFloat = 40
}
