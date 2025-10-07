//
//  CategoryColorCell.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 24.09.2025.
//

import RxSwift
import RxCocoa

final class CategoryColorCell: UICollectionViewCell {
    // MARK: - UI Elements
    private lazy var circleView: CircleView = {
        let view: CircleView = .init()
        view.lineWidth = Constants.circleLineWidth
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var checkmarkImageView: UIImageView = {
        let image: UIImageView = .init()
        image.image = UIImage(systemName: "checkmark")
        image.tintColor = .white
        image.isHidden = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    // MARK: - properties
    let hexColor: BehaviorRelay<String?> = .init(value: nil)
    var disposeBag: DisposeBag = .init()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Ovveride properties
    override var isSelected: Bool {
        didSet {
            updateSelectionState()
            if isSelected, let color: String = circleView.strokeColor.toHex() {
                hexColor.accept(color)
            } else if !isSelected {
                hexColor.accept(nil)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = .init()
    }
    
    // MARK: - Configure method
    func configure(with color: String) {
        circleView.strokeColor = UIColor(hexString: color) ?? .appSelectedBlue
    }
}

// MARK: - Private methods
private extension CategoryColorCell {
    func setupUI() {
        isUserInteractionEnabled = true
        [circleView, checkmarkImageView].forEach { addSubview($0) }
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            circleView.centerYAnchor.constraint(equalTo: centerYAnchor),
            circleView.centerXAnchor.constraint(equalTo: centerXAnchor),
            circleView.heightAnchor.constraint(equalTo: heightAnchor),
            circleView.widthAnchor.constraint(equalTo: widthAnchor),
           
            checkmarkImageView.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
            checkmarkImageView.centerXAnchor.constraint(equalTo: circleView.centerXAnchor)
        ])
    }
    
    func updateSelectionState() {
        if isSelected {
            circleView.backgroundColor = circleView.strokeColor
            checkmarkImageView.isHidden = false
        } else {
            circleView.backgroundColor = .clear
            checkmarkImageView.isHidden = true
        }
    }
}

// MARK: - Constants
private enum Constants {
    static let circleLineWidth: CGFloat = 5
}
