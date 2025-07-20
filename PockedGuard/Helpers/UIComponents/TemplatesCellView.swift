//
//  TemplatesCellView.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 11.07.2025.
//

import UIKit

final class TemplatesCellView: UICollectionViewCell {
    // MARK: - UI elements
    private lazy var icon: UIImageView = {
        let image: UIImageView = .init()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.tintColor = .white
        return image
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: Constants.cellSize, height: Constants.cellSize)
    }
    
    override var isSelected: Bool {
        didSet {
            updateSelection()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isSelected = false
        self.icon.image = nil
    }
    
    // MARK: - Configure
    func configure(with icon: String) {
        self.icon.image = UIImage(named: icon)
    }
}

// MARK: - Private methods
private extension TemplatesCellView {
    func setupUI() {
        backgroundColor = .appCardAndField
        layer.cornerRadius = Constants.cellSize / 2
        addSubview(icon)
        
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: Constants.cellSize),
            heightAnchor.constraint(equalToConstant: Constants.cellSize),
            
            icon.centerXAnchor.constraint(equalTo: centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: Constants.cellSize / 2),
            icon.heightAnchor.constraint(equalToConstant: Constants.cellSize / 2)
        ])
    }
    
    func updateSelection() {
        UIView.animate(withDuration: Constants.animationDuration) { [weak self] in
            guard let self else { return }
            self.backgroundColor = self.isSelected ? .appSelectedBlue : .appCardAndField
        }
    }
}

// MARK: - Constants
private enum Constants {
    static let cellSize: CGFloat = 60
    static let animationDuration: TimeInterval = 0.3
}
