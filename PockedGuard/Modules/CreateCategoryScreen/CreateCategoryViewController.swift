//
//  CreateCategoryViewController.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 24.09.2025.
//

import RxSwift
import RxCocoa

final class CreateCategoryViewController: BaseViewController {
    // MARK: - UI Elements
    private lazy var dragHandleView: DragHandleView = .init()
    private lazy var financeSegmentedControl: CustomSegmentedControl = .init(items: Constants.SegmentedControl.financeItems)
    private lazy var titleLabel: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: Constants.Text.titleFontSize, weight: .semibold)
        label.text = .Localized.Add.addCategory.localized
        
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button: UIButton = .init(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private lazy var categoryNameTextField: CustomTextField = {
        let textfield: CustomTextField = .init()
        textfield.configure(
            with: .Localized.Add.categoryNameLabel.localized,
            placeholder: .Localized.Add.categoryNamePlaceholder.localized,
            titleColor: .white
        )
        return textfield
    }()
    
    private lazy var colorCategoryLabel: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = .Localized.Add.colorCategoryTitle.localized
        label.textColor = .white
        label.font = .systemFont(ofSize: Constants.Text.fontSize, weight: .semibold)
        return label
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
    
    // MARK: - Private properties
    private let viewModel: CreateCategoryViewModelProtocol
    
    // MARK: - Init
    init(viewModel: CreateCategoryViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setupUI()
        setConstraints()
        setupBinding()
        setupKeyboardHandling()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private methods
private extension CreateCategoryViewController {
    func setupBinding() {
        setupOutputBinding()
        setupButtonBinding()
        setupKeyboardBinding()
    }
    
    func setupOutputBinding() {
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
    }
    
    func setupButtonBinding() {
        closeButton.rx.tap
            .bind(to: viewModel.output.dismiss)
            .disposed(by: disposeBag)
        
        doneButton.rx.tap
            .observe(on: MainScheduler.instance)
            .bind(to: viewModel.input.saveAction)
            .disposed(by: disposeBag)
    }
    
    func setupKeyboardBinding() {
        categoryNameTextField.textFieldRx.controlEvent(.editingDidEndOnExit)
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
}

// MARK: - Keyboard setting
private extension CreateCategoryViewController {
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

// MARK: - UI setup methods
private extension CreateCategoryViewController {
    func setupUI() {
        [dragHandleView, titleLabel, closeButton, financeSegmentedControl,
         categoryNameTextField, colorCategoryLabel, doneButton]
            .forEach { view.addSubview($0) }
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
            
            financeSegmentedControl.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,
                                                         constant: Constants.Layout.defaultPadding),
            financeSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            financeSegmentedControl.widthAnchor.constraint(equalToConstant: Constants.Layout.segmentControlWidth),
            
            categoryNameTextField.topAnchor.constraint(equalTo: financeSegmentedControl.bottomAnchor,
                                                       constant: Constants.Layout.defaultPadding * 2),
            categoryNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                           constant: Constants.Layout.defaultPadding),
            categoryNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                            constant: -Constants.Layout.defaultPadding),
            
            colorCategoryLabel.topAnchor.constraint(equalTo: categoryNameTextField.bottomAnchor,
                                                    constant: Constants.Layout.spacing * 2),
            colorCategoryLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                        constant: Constants.Layout.defaultPadding),
            
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
        static let segmentControlWidth: CGFloat = 216
    }
    
    enum SegmentedControl {
        static let financeItems: [String] = [
            .Localized.Common.expenses.localized,
            .Localized.Common.income.localized
        ]
    }
}
