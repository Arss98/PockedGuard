//
//  AddCategoryCell.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 20.09.2025.
//

import RxSwift
import RxCocoa

final class AddCategoryCell: UICollectionViewCell {
    // MARK: - UI elements
    private lazy var addButton: UIButton = {
        let button: UIButton = .init(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(L10n.Categories.addCategory, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: Constants.Text.fontSize, weight: .regular)
        button.tintColor = .white
        button.backgroundColor = .appMainBlue
        button.layer.cornerRadius = Constants.Layout.cornerRadius
        return button
    }()
    
    // MARK: - properties
    let addCategoryTap: PublishSubject<Void> = .init()
    var disposeBag: DisposeBag = .init()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = .init()
        setupBinding()
    }
}

// MARK: - Private methods
private extension AddCategoryCell {
    func setupUI() {
        contentView.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            addButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            addButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            addButton.heightAnchor.constraint(equalToConstant: contentView.bounds.height),
            addButton.widthAnchor.constraint(equalToConstant: contentView.bounds.width)
        ])
    }
    
    func setupBinding() {
        addButton.rx.tap
            .bind(to: addCategoryTap)
            .disposed(by: disposeBag)
    }
}

// MARK: - Constants
private enum Constants {
    enum Layout {
        static let cornerRadius: CGFloat = 10
    }
    
    enum Text {
        static let fontSize: CGFloat = 14
    }
}
