//
//  CustomTextField.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 26.06.2025.
//

import RxSwift
import RxCocoa

final class CustomTextField: UIView {
    // MARK: - UI Elements
    private lazy var titleLabel: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.fontSize, weight: .medium)
        return label
    }()
    
    private lazy var textField: UITextField = {
        let textField: UITextField = .init()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .appCardAndField
        textField.layer.cornerRadius = Constants.cornerRadius
        textField.leftView = UIView(frame: CGRect(x: .zero, y: .zero, width: Constants.leftViewWidth, height: .zero))
        textField.leftViewMode = .always
        textField.textColor = .white
        return textField
    }()
    
    private lazy var errorLabel: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.errorLabelFontSize, weight: .regular)
        label.textColor = .red
        return label
    }()
    
    // MARK: - Properties
    var text: String? {
        get { textField.text }
        set { textField.text = newValue }
    }
    
    var errorText: String = "" {
        didSet {
            errorLabel.text = errorText
        }
    }
    
    var textFieldRx: Reactive<UITextField> {
        return textField.rx
    }
        
    // MARK: - Init
    init() {
        super.init(frame: .zero)
        setupUI()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    func configure(with title: String, placeholder: String, titleColor: UIColor = .appForeground) {
        titleLabel.text = title
        titleLabel.textColor = titleColor
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.appForegroundSecondary])
    }
    
    func setupFirstResponser() {
        self.textField.becomeFirstResponder()
    }
}

// MARK: - Private methods
private extension CustomTextField {
    func setupUI() {
        [titleLabel, textField, errorLabel].forEach { addSubview($0) }
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.spacing),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor),
            textField.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight),
            
            errorLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: Constants.spacing / 2),
            errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.defaultPadding)
        ])
    }
}

// MARK: - Constants
private enum Constants {
    static let fontSize: CGFloat = 16
    static let leftViewWidth: CGFloat = 16
    static let cornerRadius: CGFloat = 12
    static let textFieldHeight: CGFloat = 52
    static let spacing: CGFloat = 8
    static let errorLabelFontSize: CGFloat = 14
    static let defaultPadding: CGFloat = 16
}
