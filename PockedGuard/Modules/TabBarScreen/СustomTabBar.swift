//
//  СustomTabBar.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 08.03.2025.
//

import RxSwift
import RxCocoa

final class CustomTabBar: UIView {
    // MARK: - UI Elements
    private lazy var addButton: CustomCircleTabBarButton = .init()
    private lazy var stackView: UIStackView = {
        let stackView: UIStackView = .init()
        stackView.distribution = .equalSpacing
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    // MARK: - Properties
    private var tabBarButtons: [UIButton] = []
    private let buttonTapSubject: PublishSubject<Int> = .init()
    private let addButtonTapSubject: PublishSubject<Void> = .init()
    private let disposeBag: DisposeBag = .init()
    
    // MARK: - Public Observables
    var buttonTapped: Observable<Int> { buttonTapSubject.asObservable() }
    var addButtonTapped: Observable<Void> { addButtonTapSubject.asObservable() }
    
    // MARK: - init
    init() {
        super.init(frame: .zero)
        configure()
        setupUI()
        setupBindings()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public method
    func selectButton(at index: Int) {
        tabBarButtons.forEach { $0.tintColor = .white }
        tabBarButtons[index].tintColor = .appSelectedBlue
    }
}

// MARK: - Private methods
private extension CustomTabBar {
    func setupUI() {
        addSubview(stackView)
        backgroundColor = .appCardAndField
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = Constants.tabBarCornerRadius
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = Constants.shadowRadius
        layer.shadowOpacity = Constants.shadowOpacity
    }
    
    func setupBindings() {
        tabBarButtons.enumerated().forEach { index, button in
            button.rx.tap
                .map { index }
                .bind(to: buttonTapSubject)
                .disposed(by: disposeBag)
        }
        
        addButton.rx.tap
            .bind(to: addButtonTapSubject)
            .disposed(by: disposeBag)
    }
    
    func configure() {
        for index in .zero..<Constants.buttonIcons.count {
            if index == Constants.buttonIcons.count / 2 {
                stackView.addArrangedSubview(addButton)
            }
            createTabBarButton(image: Constants.buttonIcons[index], tag: index)
        }
    }
    
    func createTabBarButton(image: UIImage, tag: Int) {
        let button: UIButton = .init(type: .custom)
        button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tag = tag
        button.tintColor = tag == .zero ? .appSelectedBlue : .white
        stackView.addArrangedSubview(button)
        tabBarButtons.append(button)
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: Constants.tabBarHeight),
            
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.sidePadding),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.sidePadding)
        ])
    }
}

// MARK: - Private methods
private enum Constants {
    static let sidePadding: CGFloat = 30
    static let buttonIcons: [UIImage] = [.homeIcon, .categoriesIcon, .analitycsIcon, .profileIcon]
    static let tabBarHeight: CGFloat = 52
    static let tabBarCornerRadius: CGFloat = 26
    static let shadowRadius: CGFloat = 10
    static let shadowOpacity: Float = 0.1
}
