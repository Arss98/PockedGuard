//
//  AddColorCell.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 24.09.2025.
//

import RxSwift

final class AddColorCell: UICollectionViewCell {
    // MARK: - UI elements
    private lazy var addButton: UIButton = {
        let button: UIButton = .init(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .appMainBlue
        return button
    }()
    
    // MARK: - properties
    let addColorTap: PublishSubject<Void> = .init()
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addButton.layer.cornerRadius = contentView.bounds.height / 2
    }
}

// MARK: - Private methods
private extension AddColorCell {
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
            .bind(to: addColorTap)
            .disposed(by: disposeBag)
    }
}
