//
//  CreateAccountViewController.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 20.09.2025.
//

import RxSwift
import RxCocoa

final class CreateAccountViewController: BaseViewController {
    // MARK: - UI elements
    private lazy var dragHandleView: DragHandleView = .init()
    private lazy var titleLabel: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: Constants.Text.titleFontSize, weight: .semibold)
        label.text = .Localized.Add.addAccount.localized
        
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button: UIButton = .init(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private lazy var accountNameTextField: CustomTextField = {
        let textfield: CustomTextField = .init()
        textfield.configure(
            with: .Localized.Add.accountNameLabel.localized,
            placeholder: .Localized.Add.accountNamePlaceholder.localized,
            titleColor: .white
        )
        return textfield
    }()
    
    private lazy var currencyLabel: UILabel = {
        let label: UILabel = .init()
        label.textColor = .white
        label.font = .systemFont(ofSize: Constants.Text.fontSize, weight: .regular)
        label.text = .Localized.Add.accountCurrencyType.localized
        
        return label
    }()
    
    private lazy var currencyButton: UIButton = {
        let button: UIButton = .init(type: .system)
        button.setTitle(.Localized.Common.RUB.localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: Constants.Text.fontSize, weight: .regular)
        return button
    }()
    
    private lazy var currencyStackView: UIStackView = {
        let stackView: UIStackView = .init(arrangedSubviews: [currencyLabel, currencyButton])
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var doneButton: UIButton = {
        let button: UIButton = .init(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(.Localized.Common.done.localized, for: .normal)
        button.backgroundColor = .appMainBlue
        button.tintColor = .white
        button.layer.cornerRadius = Constants.Layout.buttonCornerRadius
        button.layer.masksToBounds = true
        return button
    }()
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture: UITapGestureRecognizer = .init()
        view.addGestureRecognizer(gesture)
        return gesture
    }()
    
    private lazy var doneButtonBottomConstraint: NSLayoutConstraint = {
        doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                           constant: -Constants.Layout.defaultPadding)
    }()
    
    // MARK: - Properties
    private let viewModel: CreateAccountViewModelProtocol
    
    // MARK: - Init
    init(viewModel: CreateAccountViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setupUI()
        setupInitialValues()
        setupBindings()
        setConstraints()
        setupKeyboardHandling()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Keyboard setting
private extension CreateAccountViewController {
    func setupKeyboardHandling() {
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .subscribe(onNext: { [weak self] notification in
                guard let self = self,
                      let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                let keyboardHeight = keyboardFrame.height
                self.updateLayoutForKeyboard(height: keyboardHeight - Constants.Layout.defaultPadding / 2)
            })
            .disposed(by: disposeBag)

        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .subscribe(onNext: { [weak self] _ in
                self?.updateLayoutForKeyboard(height: Constants.Layout.defaultPadding)
            })
            .disposed(by: disposeBag)
    }
    
    func updateLayoutForKeyboard(height: CGFloat) {
        doneButtonBottomConstraint.constant = -height
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - Private methods
private extension CreateAccountViewController {
    func setupUI() {
        [dragHandleView, titleLabel, closeButton, accountNameTextField,
         currencyStackView, doneButton].forEach { view.addSubview($0) }
    }
    
    func setupInitialValues() {
        if case .edit = viewModel.mode {
            accountNameTextField.text = viewModel.input.title.value
            currencyButton.setTitle(viewModel.input.currencyType.value.localizedTitle, for: .normal)
            titleLabel.text = .Localized.Add.editAccount.localized
        }
    }
    
    func setupBindings() {
        viewModel.output.error
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] error in
                self?.showErrorAlert(message: error.localizedDescription)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.isLoading
            .subscribe(with: self) { controller, isLoading in
                controller.showActivityIndicator(isLoading)
            }
            .disposed(by: disposeBag)
        
        closeButton.rx.tap
            .bind(to: viewModel.output.dismiss)
            .disposed(by: disposeBag)
        
        currencyButton.rx.tap
            .flatMapLatest { [weak self] _ -> Observable<CurrencyType?> in
                guard let self else { return .empty() }
                return self.showSelectionSheet(localizedTitleProvider: { $0.localizedTitle})
            }
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] type in
                self?.currencyButton.setTitle(type.localizedTitle, for: .normal)
                self?.viewModel.input.currencyType.accept(type)
            })
            .disposed(by: disposeBag)
        
        accountNameTextField.textFieldRx.text.orEmpty
            .debounce(.microseconds(300), scheduler: MainScheduler.instance)
            .bind(to: viewModel.input.title)
            .disposed(by: disposeBag)
        
        doneButton.rx.tap
            .observe(on: MainScheduler.instance)
            .bind(to: viewModel.input.saveAction)
            .disposed(by: disposeBag)
        
        accountNameTextField.textFieldRx.controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: { [weak self] in
                self?.view.endEditing(true)
            })
            .disposed(by: disposeBag)
        
        tapGesture.rx.event
            .subscribe { [weak self] _ in
                self?.view.endEditing(true)
            }
            .disposed(by: disposeBag)
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            dragHandleView.topAnchor.constraint(equalTo: view.topAnchor,
                                                constant: Constants.Layout.spacing),
            dragHandleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: dragHandleView.bottomAnchor,
                                            constant: Constants.Layout.spacing),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                  constant: -Constants.Layout.defaultPadding),
            
            accountNameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,
                                                      constant: Constants.Layout.defaultPadding * 2),
            accountNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                          constant: Constants.Layout.defaultPadding),
            accountNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                           constant: -Constants.Layout.defaultPadding),
            
            currencyStackView.topAnchor.constraint(equalTo: accountNameTextField.bottomAnchor,
                                                   constant: Constants.Layout.defaultPadding * 2),
            currencyStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                       constant: Constants.Layout.defaultPadding),
            currencyStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                        constant: -Constants.Layout.defaultPadding),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                constant: Constants.Layout.defaultPadding),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                 constant: -Constants.Layout.defaultPadding),
            doneButton.heightAnchor.constraint(equalToConstant: Constants.Layout.buttonHeight),
            doneButtonBottomConstraint
        ])
    }
}

// MARK: - Constants
private enum Constants {
    enum Text {
        static let titleFontSize: CGFloat = 18
        static let fontSize: CGFloat = 16
    }
    
    enum Layout {
        static let spacing: CGFloat = 10
        static let defaultPadding: CGFloat = 16
        static let buttonCornerRadius: CGFloat = 10
        static let buttonHeight: CGFloat = 52
    }
}
