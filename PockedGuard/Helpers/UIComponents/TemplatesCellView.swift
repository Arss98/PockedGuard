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
        image.isUserInteractionEnabled = true
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
        CGSize(width: contentView.bounds.width, height: contentView.bounds.width)
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
        layer.cornerRadius = contentView.bounds.width / 2
        contentView.addSubview(icon)
        
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: contentView.bounds.width),
            heightAnchor.constraint(equalToConstant: contentView.bounds.width),
            
            icon.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: contentView.bounds.width / 2),
            icon.heightAnchor.constraint(equalToConstant: contentView.bounds.width / 2)
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
    static let animationDuration: TimeInterval = 0.3
}
