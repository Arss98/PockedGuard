//
//  CustomSegmentedControl.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 09.03.2025.
//

import RxSwift
import RxCocoa

final class CustomSegmentedControl: UIView {
    // MARK: UI Elements
    private lazy var selectorView: UIView = {
        let view: UIView = .init()
        view.backgroundColor = .appMainBlue
        view.layer.cornerRadius = Constants.selectroViewCornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView: UIStackView = .init(arrangedSubviews: buttons)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Properties
    let items: [String]
    var selectedIndex: Observable<Int> {
        selectedIndexSubject.asObservable()
    }
    
    private var leadingConstraint: NSLayoutConstraint?
    private var buttons: [UIButton] = []
    private let disposeBag: DisposeBag = .init()
    private let selectedIndexSubject: BehaviorSubject<Int> = .init(value: .zero)
    
    // MARK: - Init
    init(items: [String]) {
        self.items = items
        super.init(frame: .zero)
        setupUI()
        createButtons()
        setupBinding()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private methods
private extension CustomSegmentedControl {
    func setupUI() {
        backgroundColor = .appCardAndField
        layer.cornerRadius = Constants.cornerRadius
    }
    
    func createButtons() {
        for (index, item) in items.enumerated() {
            let button: UIButton = .init(type: .custom)
            
            var configuration: UIButton.Configuration = UIButton.Configuration.plain()
            configuration.baseForegroundColor = .white
            configuration.title = item
            configuration.cornerStyle = .medium
            configuration.attributedTitle = AttributedString(NSAttributedString(
                string: item,
                attributes: [.font: UIFont.systemFont(ofSize: Constants.buttonFonsSize, weight: .medium)])
            )
            
            button.configuration = configuration
            button.tag = index
            buttons.append(button)
        }
    }
    
    func setupBinding() {
        buttons.forEach { button in
            button.rx.tap
                .subscribe(onNext: { [weak self] in
                    guard let self else { return }
                    self.handleButtonTap(button)
                })
                .disposed(by: disposeBag)
        }
    }
    
    func handleButtonTap(_ sender: UIButton) {
        selectedIndexSubject.onNext(sender.tag)
        
        let offset: CGFloat = stackView.arrangedSubviews[sender.tag].frame.origin.x
        
        UIView.animate(withDuration: Constants.animationDuration) {
            self.leadingConstraint?.constant = offset
            self.layoutIfNeeded()
        }
    }
    
    func setConstraints() {
        [selectorView, stackView].forEach { addSubview($0) }
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: Constants.segmentedControlHeight),
            
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.defaultSegmentedPadding),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.defaultSegmentedPadding),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.defaultSegmentedPadding),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.defaultSegmentedPadding),
            
            selectorView.topAnchor.constraint(equalTo: stackView.topAnchor),
            selectorView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
            selectorView.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1 / CGFloat(items.count))
        ])
        
        leadingConstraint = selectorView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor)
        leadingConstraint?.isActive = true
    }
}

// MARK: - Constants
private enum Constants {
    static let buttonFonsSize: CGFloat = 13
    static let cornerRadius: CGFloat = 22
    static let selectroViewCornerRadius: CGFloat = 18
    static let animationDuration: TimeInterval = 0.4
    static let segmentedControlHeight: CGFloat = 44
    static let defaultSegmentedPadding: CGFloat = 4
}
