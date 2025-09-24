//
//  AddTemplateCell.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 20.09.2025.
//

import RxSwift
import RxCocoa

final class AddTemplateCell: UICollectionViewCell {
    // MARK: - UI Elements
    private lazy var addButton: UIButton = {
        let button: UIButton = .init(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .appMainBlue
        button.layer.cornerRadius = Constants.cornerRadius
        
        return button
    }()
    
    // MARK: - Properties
    let addTemplateTap: PublishSubject<Void> = .init()
    private let disposeBag: DisposeBag = .init()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private methods
private extension AddTemplateCell {
    func setupUI() {
        contentView.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            addButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            addButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            addButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize),
            addButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize)
        ])
    }
    
    func setupBinding() {
        addButton.rx.tap
            .bind(to: addTemplateTap)
            .disposed(by: disposeBag)
    }
}

// MARK: - Constants
private enum Constants {
    static let buttonSize: CGFloat = 60
    static let cornerRadius: CGFloat = 30
}
